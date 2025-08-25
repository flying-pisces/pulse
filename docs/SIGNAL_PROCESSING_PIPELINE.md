# Signal Processing Pipeline - Detailed Design

## Overview

This document details the signal processing pipeline that transforms raw market data into actionable trading signals for the 3-tier user system.

## Pipeline Architecture

```
Raw Market Data → Feature Engineering → ML Models → Signal Generation → Distribution
       ↓                ↓                ↓            ↓                ↓
   WebSocket         Rolling Stats    Ensemble     Risk Scoring    User Tiers
   Kafka Feeds       Technical Ind    XGBoost      Confidence      WebSocket
   REST APIs         News Sentiment   TensorFlow   Expiration      Push Notif
```

## 1. Data Ingestion Layer

### Market Data Sources Configuration

```python
# data_sources.py
from dataclasses import dataclass
from typing import Dict, List, Optional
import asyncio
import websockets
import json

@dataclass
class DataSource:
    name: str
    websocket_url: str
    api_key: str
    symbols: List[str]
    data_types: List[str]  # ['trades', 'quotes', 'bars', 'news']

class MarketDataIngestion:
    def __init__(self, config: Dict[str, DataSource]):
        self.sources = config
        self.kafka_producer = self._setup_kafka()
        
    async def start_streaming(self):
        """Start all WebSocket connections concurrently"""
        tasks = []
        for source in self.sources.values():
            tasks.append(self._stream_source(source))
        await asyncio.gather(*tasks)
    
    async def _stream_source(self, source: DataSource):
        """Stream data from a single source"""
        async with websockets.connect(source.websocket_url) as websocket:
            # Subscribe to symbols
            subscribe_msg = {
                "action": "subscribe",
                "symbols": source.symbols,
                "types": source.data_types
            }
            await websocket.send(json.dumps(subscribe_msg))
            
            async for message in websocket:
                data = json.loads(message)
                await self._process_message(data, source.name)
    
    async def _process_message(self, data: dict, source: str):
        """Process and route message to appropriate Kafka topics"""
        message_type = data.get('type', 'unknown')
        symbol = data.get('symbol', 'UNKNOWN')
        
        # Route to appropriate Kafka topic
        topic = f"market-data-{message_type}"
        
        # Add metadata
        enriched_data = {
            **data,
            'source': source,
            'ingestion_timestamp': time.time(),
            'symbol': symbol.upper()
        }
        
        # Send to Kafka
        await self.kafka_producer.send(topic, enriched_data)

# Configuration for different data sources
DATA_SOURCES = {
    'alpaca': DataSource(
        name='alpaca',
        websocket_url='wss://stream.data.alpaca.markets/v2/iex',
        api_key=os.getenv('ALPACA_API_KEY'),
        symbols=['AAPL', 'TSLA', 'NVDA', 'SPY', 'QQQ'],
        data_types=['trades', 'quotes', 'bars']
    ),
    'polygon': DataSource(
        name='polygon',
        websocket_url='wss://socket.polygon.io/stocks',
        api_key=os.getenv('POLYGON_API_KEY'),
        symbols=['*'],  # All symbols
        data_types=['trades', 'quotes', 'aggs']
    ),
    'binance': DataSource(
        name='binance',
        websocket_url='wss://stream.binance.us:9443/ws',
        api_key='',  # Public feed
        symbols=['BTCUSDT', 'ETHUSDT', 'ADAUSDT'],
        data_types=['trades', 'ticker']
    )
}
```

## 2. Feature Engineering Pipeline

### Real-time Feature Computation

```python
# feature_engine.py
import pandas as pd
import numpy as np
from typing import Dict, List, Any
import talib
from dataclasses import dataclass
from datetime import datetime, timedelta

@dataclass
class FeatureConfig:
    lookback_periods: List[int] = None
    technical_indicators: List[str] = None
    volume_features: bool = True
    price_features: bool = True
    volatility_features: bool = True
    
    def __post_init__(self):
        if self.lookback_periods is None:
            self.lookback_periods = [5, 10, 20, 50, 200]
        if self.technical_indicators is None:
            self.technical_indicators = ['RSI', 'MACD', 'BBANDS', 'STOCH', 'ADX']

class FeatureEngine:
    def __init__(self, config: FeatureConfig, redis_client):
        self.config = config
        self.redis = redis_client
        self.feature_cache = {}
        
    async def compute_features(self, symbol: str, timeframe: str = '1min') -> Dict[str, float]:
        """Compute all features for a symbol"""
        # Get recent price data
        price_data = await self._get_price_data(symbol, timeframe)
        
        if len(price_data) < max(self.config.lookback_periods):
            return {}  # Not enough data
            
        features = {}
        
        # Technical indicators
        features.update(self._compute_technical_indicators(price_data))
        
        # Price-based features
        features.update(self._compute_price_features(price_data))
        
        # Volume features
        features.update(self._compute_volume_features(price_data))
        
        # Volatility features
        features.update(self._compute_volatility_features(price_data))
        
        # Options flow features (if available)
        features.update(await self._compute_options_features(symbol))
        
        # News sentiment features
        features.update(await self._compute_sentiment_features(symbol))
        
        # Cache features
        await self._cache_features(symbol, features)
        
        return features
    
    def _compute_technical_indicators(self, data: pd.DataFrame) -> Dict[str, float]:
        """Compute technical indicators using TA-Lib"""
        features = {}
        
        high = data['high'].values
        low = data['low'].values
        close = data['close'].values
        volume = data['volume'].values
        
        # RSI
        if 'RSI' in self.config.technical_indicators:
            rsi = talib.RSI(close, timeperiod=14)
            features.update({
                'rsi_14': rsi[-1],
                'rsi_overbought': 1 if rsi[-1] > 70 else 0,
                'rsi_oversold': 1 if rsi[-1] < 30 else 0,
                'rsi_momentum': rsi[-1] - rsi[-5],  # 5-period momentum
            })
        
        # MACD
        if 'MACD' in self.config.technical_indicators:
            macd, macd_signal, macd_hist = talib.MACD(close)
            features.update({
                'macd': macd[-1],
                'macd_signal': macd_signal[-1],
                'macd_histogram': macd_hist[-1],
                'macd_cross_bullish': 1 if macd[-1] > macd_signal[-1] and macd[-2] <= macd_signal[-2] else 0,
                'macd_cross_bearish': 1 if macd[-1] < macd_signal[-1] and macd[-2] >= macd_signal[-2] else 0,
            })
        
        # Bollinger Bands
        if 'BBANDS' in self.config.technical_indicators:
            bb_upper, bb_middle, bb_lower = talib.BBANDS(close)
            bb_position = (close[-1] - bb_lower[-1]) / (bb_upper[-1] - bb_lower[-1])
            features.update({
                'bb_position': bb_position,
                'bb_squeeze': 1 if (bb_upper[-1] - bb_lower[-1]) / bb_middle[-1] < 0.1 else 0,
                'bb_breakout_upper': 1 if close[-1] > bb_upper[-1] else 0,
                'bb_breakout_lower': 1 if close[-1] < bb_lower[-1] else 0,
            })
        
        # Stochastic
        if 'STOCH' in self.config.technical_indicators:
            slowk, slowd = talib.STOCH(high, low, close)
            features.update({
                'stoch_k': slowk[-1],
                'stoch_d': slowd[-1],
                'stoch_overbought': 1 if slowk[-1] > 80 else 0,
                'stoch_oversold': 1 if slowk[-1] < 20 else 0,
            })
        
        # ADX (trend strength)
        if 'ADX' in self.config.technical_indicators:
            adx = talib.ADX(high, low, close)
            features.update({
                'adx': adx[-1],
                'strong_trend': 1 if adx[-1] > 25 else 0,
            })
            
        return features
    
    def _compute_price_features(self, data: pd.DataFrame) -> Dict[str, float]:
        """Compute price-based features"""
        features = {}
        close = data['close'].values
        
        # Moving averages and crossovers
        for period in self.config.lookback_periods:
            if len(close) >= period:
                ma = np.mean(close[-period:])
                features[f'ma_{period}'] = ma
                features[f'price_vs_ma_{period}'] = (close[-1] - ma) / ma
                
                # MA slope (trend direction)
                if len(close) >= period + 5:
                    ma_prev = np.mean(close[-(period+5):-5])
                    features[f'ma_{period}_slope'] = (ma - ma_prev) / ma_prev
        
        # Price momentum
        for lookback in [1, 3, 5, 10]:
            if len(close) > lookback:
                momentum = (close[-1] - close[-lookback-1]) / close[-lookback-1]
                features[f'momentum_{lookback}'] = momentum
        
        # Support/Resistance levels
        high_52w = np.max(data['high'].values[-252:]) if len(data) >= 252 else np.max(data['high'].values)
        low_52w = np.min(data['low'].values[-252:]) if len(data) >= 252 else np.min(data['low'].values)
        
        features.update({
            'distance_to_52w_high': (close[-1] - high_52w) / high_52w,
            'distance_to_52w_low': (close[-1] - low_52w) / low_52w,
        })
        
        return features
    
    def _compute_volume_features(self, data: pd.DataFrame) -> Dict[str, float]:
        """Compute volume-based features"""
        features = {}
        volume = data['volume'].values
        close = data['close'].values
        
        # Volume moving averages
        for period in [5, 10, 20]:
            if len(volume) >= period:
                vol_ma = np.mean(volume[-period:])
                features[f'volume_vs_ma_{period}'] = volume[-1] / vol_ma if vol_ma > 0 else 1
        
        # Volume-Price Trend (VPT)
        if len(data) >= 2:
            price_change = (close[-1] - close[-2]) / close[-2]
            vpt = volume[-1] * price_change
            features['vpt'] = vpt
        
        # On-Balance Volume (OBV)
        obv = talib.OBV(close, volume)
        features['obv'] = obv[-1]
        features['obv_trend'] = obv[-1] - obv[-5] if len(obv) >= 5 else 0
        
        return features
    
    def _compute_volatility_features(self, data: pd.DataFrame) -> Dict[str, float]:
        """Compute volatility features"""
        features = {}
        close = data['close'].values
        high = data['high'].values
        low = data['low'].values
        
        # Historical volatility (different periods)
        for period in [5, 10, 20]:
            if len(close) >= period:
                returns = np.diff(np.log(close[-period:]))
                vol = np.std(returns) * np.sqrt(252)  # Annualized
                features[f'volatility_{period}d'] = vol
        
        # True Range and ATR
        tr = talib.TRANGE(high, low, close)
        atr = talib.ATR(high, low, close)
        features.update({
            'true_range': tr[-1],
            'atr_14': atr[-1],
            'atr_position': (close[-1] - low[-1]) / atr[-1] if atr[-1] > 0 else 0.5,
        })
        
        return features
    
    async def _compute_options_features(self, symbol: str) -> Dict[str, float]:
        """Compute options flow features (if data available)"""
        features = {}
        
        # Get options data from cache or API
        options_data = await self._get_options_data(symbol)
        
        if options_data:
            # Unusual options activity
            features['unusual_call_volume'] = options_data.get('unusual_call_volume', 0)
            features['unusual_put_volume'] = options_data.get('unusual_put_volume', 0)
            features['put_call_ratio'] = options_data.get('put_call_ratio', 1.0)
            
            # Implied volatility
            features['iv_rank'] = options_data.get('iv_rank', 0.5)
            features['iv_percentile'] = options_data.get('iv_percentile', 0.5)
        
        return features
    
    async def _compute_sentiment_features(self, symbol: str) -> Dict[str, float]:
        """Compute news sentiment features"""
        features = {}
        
        # Get recent news sentiment
        sentiment_data = await self._get_news_sentiment(symbol)
        
        if sentiment_data:
            features.update({
                'news_sentiment_1h': sentiment_data.get('sentiment_1h', 0.0),
                'news_sentiment_24h': sentiment_data.get('sentiment_24h', 0.0),
                'news_volume_1h': sentiment_data.get('volume_1h', 0),
                'news_volume_24h': sentiment_data.get('volume_24h', 0),
            })
        
        return features
    
    async def _get_price_data(self, symbol: str, timeframe: str) -> pd.DataFrame:
        """Get recent price data from cache/database"""
        # Implementation depends on your data storage solution
        # This would typically query ClickHouse or similar
        pass
    
    async def _get_options_data(self, symbol: str) -> Dict[str, Any]:
        """Get options data if available"""
        # Query options data from external API or cache
        pass
    
    async def _get_news_sentiment(self, symbol: str) -> Dict[str, Any]:
        """Get news sentiment data"""
        # Query sentiment data from news analysis service
        pass
    
    async def _cache_features(self, symbol: str, features: Dict[str, float]):
        """Cache computed features in Redis"""
        key = f"features:{symbol}:{int(datetime.now().timestamp())}"
        await self.redis.hset(key, mapping=features)
        await self.redis.expire(key, 3600)  # 1 hour expiry
```

## 3. ML Model Pipeline

### Ensemble Signal Generation

```python
# signal_models.py
import xgboost as xgb
import lightgbm as lgb
import numpy as np
import pandas as pd
from sklearn.ensemble import VotingClassifier
from sklearn.preprocessing import StandardScaler
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple
import joblib
import asyncio

@dataclass
class SignalPrediction:
    signal_type: str  # 'buy', 'sell', 'hold'
    confidence: float  # 0.0 to 1.0
    target_price: float
    stop_loss: float
    time_horizon: str  # '1d', '3d', '1w', '2w'
    reasoning: str
    features_used: Dict[str, float]

class SignalMLPipeline:
    def __init__(self, model_configs: Dict[str, Any]):
        self.models = {}
        self.scalers = {}
        self.feature_importance = {}
        self.load_models(model_configs)
    
    def load_models(self, configs: Dict[str, Any]):
        """Load pre-trained models"""
        for model_name, config in configs.items():
            model_path = config['model_path']
            scaler_path = config.get('scaler_path')
            
            # Load model
            if 'xgboost' in model_name.lower():
                self.models[model_name] = xgb.Booster()
                self.models[model_name].load_model(model_path)
            elif 'lightgbm' in model_name.lower():
                self.models[model_name] = lgb.Booster(model_file=model_path)
            else:
                self.models[model_name] = joblib.load(model_path)
            
            # Load scaler if exists
            if scaler_path:
                self.scalers[model_name] = joblib.load(scaler_path)
    
    async def generate_signal(
        self, 
        symbol: str, 
        features: Dict[str, float], 
        user_risk_profile: str = 'moderate'
    ) -> Optional[SignalPrediction]:
        """Generate trading signal using ensemble of models"""
        
        # Validate features
        if not self._validate_features(features):
            return None
        
        # Prepare feature vector
        feature_vector = self._prepare_features(features)
        
        # Get predictions from all models
        predictions = {}
        confidences = {}
        
        for model_name, model in self.models.items():
            try:
                pred, conf = await self._predict_with_model(
                    model, model_name, feature_vector
                )
                predictions[model_name] = pred
                confidences[model_name] = conf
            except Exception as e:
                print(f"Error with model {model_name}: {e}")
                continue
        
        if not predictions:
            return None
        
        # Ensemble prediction
        final_signal = self._ensemble_predictions(predictions, confidences)
        
        # Risk adjustment based on user profile
        adjusted_signal = self._adjust_for_risk_profile(final_signal, user_risk_profile)
        
        # Calculate target and stop loss
        current_price = features.get('current_price', 0)
        target_price, stop_loss = self._calculate_levels(
            adjusted_signal, current_price, features
        )
        
        # Generate reasoning
        reasoning = await self._generate_reasoning(
            symbol, adjusted_signal, features, predictions
        )
        
        return SignalPrediction(
            signal_type=adjusted_signal['action'],
            confidence=adjusted_signal['confidence'],
            target_price=target_price,
            stop_loss=stop_loss,
            time_horizon=adjusted_signal['time_horizon'],
            reasoning=reasoning,
            features_used=features
        )
    
    async def _predict_with_model(
        self, 
        model, 
        model_name: str, 
        features: np.ndarray
    ) -> Tuple[str, float]:
        """Get prediction from a single model"""
        
        # Apply scaling if needed
        if model_name in self.scalers:
            features = self.scalers[model_name].transform(features.reshape(1, -1))
        
        # Model-specific prediction logic
        if 'xgboost' in model_name.lower():
            dtest = xgb.DMatrix(features)
            proba = model.predict(dtest)[0]
            
            # Convert to signal
            if proba > 0.7:
                return 'buy', proba
            elif proba < 0.3:
                return 'sell', 1 - proba
            else:
                return 'hold', max(proba, 1 - proba)
                
        elif 'lightgbm' in model_name.lower():
            proba = model.predict(features)[0]
            
            if proba > 0.7:
                return 'buy', proba
            elif proba < 0.3:
                return 'sell', 1 - proba
            else:
                return 'hold', max(proba, 1 - proba)
        
        else:  # sklearn-compatible model
            proba = model.predict_proba(features.reshape(1, -1))[0]
            class_idx = np.argmax(proba)
            classes = ['sell', 'hold', 'buy']
            
            return classes[class_idx], np.max(proba)
    
    def _ensemble_predictions(
        self, 
        predictions: Dict[str, str], 
        confidences: Dict[str, float]
    ) -> Dict[str, Any]:
        """Combine predictions from multiple models"""
        
        # Weighted voting based on model confidence and historical performance
        model_weights = {
            'xgboost_swing': 0.35,
            'lightgbm_day': 0.30,
            'neural_net': 0.20,
            'random_forest': 0.15
        }
        
        action_scores = {'buy': 0, 'sell': 0, 'hold': 0}
        total_weight = 0
        
        for model_name, action in predictions.items():
            weight = model_weights.get(model_name, 0.1)
            confidence = confidences[model_name]
            
            # Weight by confidence and model importance
            weighted_score = weight * confidence
            action_scores[action] += weighted_score
            total_weight += weight
        
        # Normalize scores
        for action in action_scores:
            action_scores[action] /= total_weight
        
        # Select final action
        final_action = max(action_scores, key=action_scores.get)
        final_confidence = action_scores[final_action]
        
        # Determine time horizon based on signal strength
        if final_confidence > 0.8:
            time_horizon = '1d'  # High confidence, short term
        elif final_confidence > 0.6:
            time_horizon = '3d'  # Medium confidence, short-medium term
        else:
            time_horizon = '1w'  # Lower confidence, longer term
        
        return {
            'action': final_action,
            'confidence': final_confidence,
            'time_horizon': time_horizon,
            'action_scores': action_scores
        }
    
    def _adjust_for_risk_profile(
        self, 
        signal: Dict[str, Any], 
        risk_profile: str
    ) -> Dict[str, Any]:
        """Adjust signal based on user's risk profile"""
        
        adjusted = signal.copy()
        
        if risk_profile == 'conservative':
            # Only high-confidence signals
            if signal['confidence'] < 0.7:
                adjusted['action'] = 'hold'
                adjusted['confidence'] = 0.5
            else:
                # Reduce position size implicitly by lowering confidence
                adjusted['confidence'] *= 0.8
                
        elif risk_profile == 'aggressive':
            # Boost confidence for YOLO trades
            if signal['action'] != 'hold':
                adjusted['confidence'] = min(0.95, signal['confidence'] * 1.2)
            
            # Shorter time horizons for aggressive traders
            if signal['time_horizon'] == '1w':
                adjusted['time_horizon'] = '3d'
            elif signal['time_horizon'] == '3d':
                adjusted['time_horizon'] = '1d'
        
        return adjusted
    
    def _calculate_levels(
        self, 
        signal: Dict[str, Any], 
        current_price: float, 
        features: Dict[str, float]
    ) -> Tuple[float, float]:
        """Calculate target price and stop loss levels"""
        
        atr = features.get('atr_14', current_price * 0.02)  # Default to 2% if no ATR
        volatility = features.get('volatility_20d', 0.25)  # Default 25% annualized
        
        if signal['action'] == 'buy':
            # Target based on risk/reward ratio and volatility
            risk_reward_ratio = 2.0  # 2:1 reward:risk
            
            if signal['time_horizon'] == '1d':
                risk_amount = atr * 1.5
                target_price = current_price + (risk_amount * risk_reward_ratio)
                stop_loss = current_price - risk_amount
            elif signal['time_horizon'] == '3d':
                risk_amount = atr * 2.0
                target_price = current_price + (risk_amount * risk_reward_ratio)
                stop_loss = current_price - risk_amount
            else:  # 1w
                risk_amount = atr * 3.0
                target_price = current_price + (risk_amount * risk_reward_ratio)
                stop_loss = current_price - risk_amount
                
        elif signal['action'] == 'sell':
            # Short position targets
            if signal['time_horizon'] == '1d':
                risk_amount = atr * 1.5
                target_price = current_price - (risk_amount * 2.0)
                stop_loss = current_price + risk_amount
            elif signal['time_horizon'] == '3d':
                risk_amount = atr * 2.0
                target_price = current_price - (risk_amount * 2.0)
                stop_loss = current_price + risk_amount
            else:  # 1w
                risk_amount = atr * 3.0
                target_price = current_price - (risk_amount * 2.0)
                stop_loss = current_price + risk_amount
        else:
            # Hold position
            target_price = current_price
            stop_loss = current_price
        
        return round(target_price, 2), round(stop_loss, 2)
    
    async def _generate_reasoning(
        self, 
        symbol: str, 
        signal: Dict[str, Any], 
        features: Dict[str, float], 
        model_predictions: Dict[str, str]
    ) -> str:
        """Generate human-readable reasoning for the signal"""
        
        reasoning_parts = []
        
        # Technical analysis reasoning
        rsi = features.get('rsi_14', 50)
        macd = features.get('macd', 0)
        volume_ratio = features.get('volume_vs_ma_20', 1.0)
        
        if signal['action'] == 'buy':
            if rsi < 40:
                reasoning_parts.append("RSI indicates oversold conditions")
            if macd > 0:
                reasoning_parts.append("MACD showing bullish momentum")
            if volume_ratio > 1.5:
                reasoning_parts.append("Above-average volume supporting the move")
                
        elif signal['action'] == 'sell':
            if rsi > 60:
                reasoning_parts.append("RSI indicates overbought conditions")
            if macd < 0:
                reasoning_parts.append("MACD showing bearish momentum")
            if volume_ratio > 1.5:
                reasoning_parts.append("High volume confirming bearish pressure")
        
        # Model consensus
        buy_votes = sum(1 for pred in model_predictions.values() if pred == 'buy')
        sell_votes = sum(1 for pred in model_predictions.values() if pred == 'sell')
        total_votes = len(model_predictions)
        
        if buy_votes > total_votes * 0.6:
            reasoning_parts.append(f"Strong model consensus ({buy_votes}/{total_votes} models bullish)")
        elif sell_votes > total_votes * 0.6:
            reasoning_parts.append(f"Strong model consensus ({sell_votes}/{total_votes} models bearish)")
        
        # Combine reasoning
        if reasoning_parts:
            reasoning = f"{symbol} - " + ". ".join(reasoning_parts) + f". Confidence: {signal['confidence']:.1%}"
        else:
            reasoning = f"{symbol} - Mixed technical signals. Confidence: {signal['confidence']:.1%}"
        
        return reasoning
    
    def _validate_features(self, features: Dict[str, float]) -> bool:
        """Validate that we have minimum required features"""
        required_features = ['current_price', 'rsi_14', 'macd', 'volume_vs_ma_20']
        return all(feat in features for feat in required_features)
    
    def _prepare_features(self, features: Dict[str, float]) -> np.ndarray:
        """Convert feature dict to numpy array in correct order"""
        # This should match the order used during model training
        feature_order = [
            'rsi_14', 'macd', 'macd_signal', 'macd_histogram',
            'bb_position', 'stoch_k', 'stoch_d', 'adx',
            'momentum_1', 'momentum_3', 'momentum_5',
            'volume_vs_ma_5', 'volume_vs_ma_20',
            'volatility_5d', 'volatility_20d', 'atr_14'
        ]
        
        feature_vector = []
        for feat in feature_order:
            value = features.get(feat, 0.0)  # Default to 0 if missing
            feature_vector.append(value)
        
        return np.array(feature_vector)

# Example usage configuration
MODEL_CONFIGS = {
    'xgboost_swing': {
        'model_path': '/models/xgboost_swing_v1.json',
        'scaler_path': '/models/scaler_swing_v1.pkl'
    },
    'lightgbm_day': {
        'model_path': '/models/lightgbm_day_v1.txt',
        'scaler_path': '/models/scaler_day_v1.pkl'
    },
    'neural_net': {
        'model_path': '/models/neural_net_v1.pkl',
        'scaler_path': '/models/scaler_nn_v1.pkl'
    }
}
```

## 4. Signal Distribution System

### Real-time Signal Broadcasting

```python
# signal_distribution.py
import asyncio
import json
from typing import Dict, List, Set
from dataclasses import asdict
import websockets
from enum import Enum

class SubscriptionTier(Enum):
    FREE = "free"
    PREMIUM = "premium"
    DYNAMIC = "dynamic"

class SignalDistributor:
    def __init__(self, redis_client, websocket_manager):
        self.redis = redis_client
        self.websocket_manager = websocket_manager
        self.active_signals = {}  # Track active signals for dynamic updates
        
    async def distribute_signal(self, signal: SignalPrediction, symbol: str):
        """Distribute signal to appropriate user tiers"""
        
        # Determine signal tier requirements
        signal_tier = self._determine_signal_tier(signal)
        
        # Create signal messages for different tiers
        messages = {
            SubscriptionTier.FREE: await self._create_free_message(signal, symbol),
            SubscriptionTier.PREMIUM: await self._create_premium_message(signal, symbol),
            SubscriptionTier.DYNAMIC: await self._create_dynamic_message(signal, symbol)
        }
        
        # Get eligible users for each tier
        eligible_users = await self._get_eligible_users(signal_tier)
        
        # Send to WebSocket clients
        for tier, users in eligible_users.items():
            message = messages[tier]
            if message:  # Only send if tier has access
                await self._broadcast_to_users(users, message)
        
        # Store signal for tracking
        await self._store_signal(signal, symbol)
    
    def _determine_signal_tier(self, signal: SignalPrediction) -> SubscriptionTier:
        """Determine minimum tier required for signal access"""
        
        # High confidence signals require premium
        if signal.confidence >= 0.8:
            return SubscriptionTier.PREMIUM
        # Medium confidence available to premium
        elif signal.confidence >= 0.6:
            return SubscriptionTier.PREMIUM
        # Low confidence summary for free users
        else:
            return SubscriptionTier.FREE
    
    async def _create_free_message(self, signal: SignalPrediction, symbol: str) -> Dict:
        """Create message for free tier users (historical summary only)"""
        
        # Free users get historical performance data only
        historical_performance = await self._get_historical_performance(symbol)
        
        return {
            "type": "signal_summary",
            "symbol": symbol,
            "data": {
                "historical_performance": historical_performance,
                "signal_count_today": await self._get_signal_count_today(),
                "upgrade_prompt": "Upgrade to Premium for real-time signals",
                "tier_required": "premium"
            },
            "timestamp": int(asyncio.get_event_loop().time())
        }
    
    async def _create_premium_message(self, signal: SignalPrediction, symbol: str) -> Dict:
        """Create message for premium tier users (static signal)"""
        
        # Generate static signal image
        signal_image_url = await self._generate_signal_image(signal, symbol)
        
        return {
            "type": "trading_signal",
            "symbol": symbol,
            "data": {
                "action": signal.signal_type,
                "confidence": signal.confidence,
                "target_price": signal.target_price,
                "stop_loss": signal.stop_loss,
                "time_horizon": signal.time_horizon,
                "reasoning": signal.reasoning,
                "image_url": signal_image_url,
                "dynamic_upgrade_available": True,
                "dynamic_upgrade_price": 4.99
            },
            "expires_at": self._calculate_expiry(signal.time_horizon),
            "timestamp": int(asyncio.get_event_loop().time())
        }
    
    async def _create_dynamic_message(self, signal: SignalPrediction, symbol: str) -> Dict:
        """Create message for dynamic tier users (live updates)"""
        
        # Get additional context for dynamic signals
        news_context = await self._get_news_context(symbol)
        risk_analysis = await self._get_risk_analysis(signal, symbol)
        
        return {
            "type": "dynamic_signal",
            "symbol": symbol,
            "data": {
                "action": signal.signal_type,
                "confidence": signal.confidence,
                "target_price": signal.target_price,
                "stop_loss": signal.stop_loss,
                "time_horizon": signal.time_horizon,
                "reasoning": signal.reasoning,
                "news_context": news_context,
                "risk_analysis": risk_analysis,
                "live_updates": True,
                "features_snapshot": signal.features_used
            },
            "expires_at": self._calculate_expiry(signal.time_horizon),
            "timestamp": int(asyncio.get_event_loop().time()),
            "update_frequency": "real-time"
        }
    
    async def _generate_signal_image(self, signal: SignalPrediction, symbol: str) -> str:
        """Generate static signal visualization"""
        # This would create a chart image showing:
        # - Price action with entry/target/stop levels
        # - Technical indicators
        # - Signal reasoning
        # Return URL to generated image
        pass
    
    async def _get_eligible_users(self, min_tier: SubscriptionTier) -> Dict[SubscriptionTier, List[str]]:
        """Get users eligible for each tier"""
        users = {
            SubscriptionTier.FREE: [],
            SubscriptionTier.PREMIUM: [],
            SubscriptionTier.DYNAMIC: []
        }
        
        # Query user subscriptions from database
        # Implementation depends on your user management system
        
        return users
    
    async def _broadcast_to_users(self, user_ids: List[str], message: Dict):
        """Send message to WebSocket clients"""
        tasks = []
        for user_id in user_ids:
            tasks.append(self.websocket_manager.send_to_user(user_id, message))
        
        if tasks:
            await asyncio.gather(*tasks, return_exceptions=True)
    
    async def update_dynamic_signal(self, signal_id: str, updated_data: Dict):
        """Update dynamic signal with new information"""
        
        if signal_id not in self.active_signals:
            return
        
        # Get users subscribed to this dynamic signal
        dynamic_users = await self._get_dynamic_signal_subscribers(signal_id)
        
        update_message = {
            "type": "signal_update",
            "signal_id": signal_id,
            "updates": updated_data,
            "timestamp": int(asyncio.get_event_loop().time())
        }
        
        await self._broadcast_to_users(dynamic_users, update_message)
    
    def _calculate_expiry(self, time_horizon: str) -> int:
        """Calculate signal expiry timestamp"""
        now = asyncio.get_event_loop().time()
        
        if time_horizon == '1d':
            return int(now + 86400)  # 24 hours
        elif time_horizon == '3d':
            return int(now + 259200)  # 72 hours
        elif time_horizon == '1w':
            return int(now + 604800)  # 1 week
        else:
            return int(now + 86400)  # Default 24 hours
```

## 5. Performance Monitoring

### Signal Performance Tracking

```python
# performance_tracker.py
from dataclasses import dataclass
from typing import Dict, List, Optional
import asyncio
from datetime import datetime, timedelta

@dataclass
class SignalPerformance:
    signal_id: str
    symbol: str
    entry_price: float
    current_price: float
    target_price: float
    stop_loss: float
    pnl_percent: float
    status: str  # 'active', 'hit_target', 'hit_stop', 'expired'
    created_at: datetime
    updated_at: datetime

class PerformanceTracker:
    def __init__(self, database, market_data_service):
        self.db = database
        self.market_data = market_data_service
        
    async def track_signal_performance(self, signal_id: str):
        """Continuously track signal performance until expiry"""
        
        signal = await self._get_signal(signal_id)
        if not signal:
            return
            
        while signal.status == 'active':
            # Get current price
            current_price = await self.market_data.get_current_price(signal.symbol)
            
            # Calculate performance
            pnl_percent = self._calculate_pnl(signal, current_price)
            
            # Check if target or stop hit
            new_status = self._check_exit_conditions(signal, current_price)
            
            # Update performance record
            await self._update_performance(signal_id, current_price, pnl_percent, new_status)
            
            # Send update to dynamic signal subscribers
            if new_status != signal.status:
                await self._notify_signal_update(signal_id, new_status, pnl_percent)
                break
            
            # Wait before next check
            await asyncio.sleep(60)  # Check every minute
    
    def _calculate_pnl(self, signal: SignalPerformance, current_price: float) -> float:
        """Calculate P&L percentage"""
        if signal.entry_price == 0:
            return 0.0
            
        return ((current_price - signal.entry_price) / signal.entry_price) * 100
    
    def _check_exit_conditions(self, signal: SignalPerformance, current_price: float) -> str:
        """Check if signal should be closed"""
        
        # Check target hit
        if ((signal.target_price > signal.entry_price and current_price >= signal.target_price) or
            (signal.target_price < signal.entry_price and current_price <= signal.target_price)):
            return 'hit_target'
        
        # Check stop loss hit
        if ((signal.stop_loss < signal.entry_price and current_price <= signal.stop_loss) or
            (signal.stop_loss > signal.entry_price and current_price >= signal.stop_loss)):
            return 'hit_stop'
        
        return signal.status
```

This signal processing pipeline provides:

1. **Real-time data ingestion** from multiple sources
2. **Comprehensive feature engineering** with technical, volume, volatility, and sentiment features
3. **Ensemble ML models** for robust signal generation
4. **Risk-adjusted signals** based on user profiles
5. **Tiered signal distribution** for different subscription levels
6. **Performance tracking** with real-time updates
7. **Scalable architecture** that can handle high-frequency updates

The pipeline is designed to be modular, allowing for easy addition of new features, models, or data sources as the platform grows.