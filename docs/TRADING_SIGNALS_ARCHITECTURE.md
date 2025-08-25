# Trading Signals App - Complete Architecture Plan

## Executive Summary

This document outlines the complete architecture for a 3-tier trading signals platform that generates AI-powered trading recommendations with real-time updates and dynamic pricing tiers.

## System Requirements

### User Tiers
1. **Free Tier**: Historical signal summaries with P/L results (no real-time access)
2. **Premium Tier ($19.99/month)**: Real-time static signals based on user risk profile
3. **Dynamic Premium (Pay-per-signal)**: Enhanced signals with live updates, news integration, and real-time predictions

### Core Features
- Real-time signal generation using ML/quant models (not LLM-based core engine)
- Static signal images for premium users
- Dynamic signal upgrades with live data feeds
- User risk profiling (YOLO vs risk-averse)
- Signal expiration management (max 3 months to ER, typically days/weeks)
- News and catalyst integration
- Per-signal dynamic upgrade payments

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Client Applications                          │
├─────────────────────────────────────────────────────────────────┤
│  Flutter Mobile Apps        │  Flutter Web (PWA)                │
│  • iOS App Store            │  • Responsive Design              │
│  • Google Play Store        │  • Offline Capability             │
│  • Real-time Updates        │  • Push Notifications             │
└─────────────────┬───────────────────────────────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
    ▼             ▼             ▼
┌─────────┐ ┌─────────┐ ┌─────────────┐
│   CDN   │ │   API   │ │ WebSocket   │
│ (Vercel)│ │Gateway  │ │   Server    │
│         │ │(PB/FB)  │ │(Real-time)  │
└─────────┘ └─────────┘ └─────────────┘
                  │
    ┌─────────────┼─────────────────────────────┐
    │             │                             │
    ▼             ▼                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Core Services                              │
├─────────────────────────────────────────────────────────────────┤
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│ │   Signal    │ │    User     │ │  Payment    │ │   Risk      ││
│ │  Engine     │ │   Mgmt      │ │  Service    │ │ Profiling   ││
│ │             │ │             │ │             │ │             ││
│ │• ML Models  │ │• Auth/OAuth │ │• Stripe API │ │• Assessment ││
│ │• Quant Algo │ │• Profiles   │ │• Per-signal │ │• Strategies ││
│ │• Backtests  │ │• Tiers      │ │• Billing    │ │• Risk Score ││
│ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
└─────────────────────────────────────────────────────────────────┘
                  │
    ┌─────────────┼─────────────────────────────┐
    │             │                             │
    ▼             ▼                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Data Pipeline                                │
├─────────────────────────────────────────────────────────────────┤
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│ │   Market    │ │    News     │ │ Time Series │ │   Feature   ││
│ │   Data      │ │   & Events  │ │   Storage   │ │    Store    ││
│ │             │ │             │ │             │ │             ││
│ │• Alpaca WS  │ │• News APIs  │ │• ClickHouse │ │• Redis Hot  ││
│ │• Polygon    │ │• SEC Edgar  │ │• TimescaleDB│ │• Feast.dev  ││
│ │• Binance    │ │• Twitter    │ │• S3 Archive │ │• Features   ││
│ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
└─────────────────────────────────────────────────────────────────┘
                  │
    ┌─────────────┼─────────────────────────────┐
    │             │                             │
    ▼             ▼                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AI/ML Layer                                 │
├─────────────────────────────────────────────────────────────────┤
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│ │ Perplexity  │ │   GPT-4.1   │ │   Claude    │ │   Quant     ││
│ │   Online    │ │    Mini     │ │   3.5 Sonnet│ │   Models    ││
│ │             │ │             │ │             │ │             ││
│ │• Live News  │ │• Explanations│ │• Deep       │ │• XGBoost    ││
│ │• Citations  │ │• Summaries  │ │  Analysis   │ │• LightGBM   ││
│ │• Research   │ │• Tool Use   │ │• Long Context│ │• TensorFlow ││
│ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Detailed Component Architecture

### 1. Real-Time Data Ingestion Layer

#### Market Data Sources
```
┌─────────────────────────────────────────────────────────────────┐
│                   Market Data Ingestion                        │
├─────────────────────────────────────────────────────────────────┤
│ Primary Sources:                                                │
│ • Alpaca WebSocket (Stocks/Options)                            │
│ • Polygon.io (Market depth, News)                              │
│ • Binance WebSocket (Crypto)                                   │
│ • IEX Cloud (Backup equity data)                               │
│                                                                 │
│ Transport Layer:                                                │
│ • Kafka/Redpanda (Message streaming)                           │
│ • Redis Streams (Ultra-low latency fanout)                     │
│ • Protocol Buffers (Serialization)                             │
└─────────────────────────────────────────────────────────────────┘
```

#### Data Processing Pipeline
```python
# Example data flow architecture
Market Data → Kafka Topics → Stream Processing → Feature Store → ML Models
     ↓              ↓              ↓               ↓           ↓
  Raw Ticks    Topic Routing   Rolling Windows   Hot Cache   Signals
     ↓              ↓              ↓               ↓           ↓
 Validation    Schema Registry   Aggregations    Redis     Distribution
```

### 2. Signal Generation Engine

#### ML/Quant Pipeline (Core)
```
┌─────────────────────────────────────────────────────────────────┐
│                    Signal Generation Engine                    │
├─────────────────────────────────────────────────────────────────┤
│ Feature Engineering:                                            │
│ • Technical indicators (RSI, MACD, Bollinger)                  │
│ • Price patterns and momentum                                  │
│ • Options flow unusual activity                                │
│ • Volume profile analysis                                      │
│ • News sentiment scores                                        │
│                                                                 │
│ ML Models:                                                      │
│ • XGBoost/LightGBM (Primary classification)                    │
│ • Temporal Fusion Transformer (Time series)                    │
│ • Ensemble models for confidence scoring                       │
│ • Online learning with River (Adaptation)                      │
│                                                                 │
│ Signal Types:                                                   │
│ • Swing signals (1-7 days)                                     │
│ • Day trading signals (intraday)                               │
│ • Event-driven signals (earnings, FDA, etc.)                   │
│ • Options strategies signals                                    │
└─────────────────────────────────────────────────────────────────┘
```

#### Risk Profiling System
```dart
enum RiskProfile {
  conservative,    // Low volatility, high probability trades
  moderate,        // Balanced risk/reward
  aggressive,      // YOLO-style high-risk/high-reward
}

class UserRiskAssessment {
  RiskProfile profile;
  double riskTolerance;  // 0.0 to 1.0
  double maxPositionSize;
  List<String> preferredStrategies;
  Map<String, double> sectorAllocations;
}
```

### 3. LLM Integration Layer (Sidecar Pattern)

#### AI Service Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                      LLM Services Layer                        │
├─────────────────────────────────────────────────────────────────┤
│ Perplexity Online (pplx-70b-online):                          │
│ • Real-time news research with citations                       │
│ • SEC filing analysis                                          │
│ • Catalyst detection and validation                            │
│ • Market sentiment from live sources                           │
│                                                                 │
│ GPT-4.1 Mini (Cost-optimized):                                │
│ • Signal explanation generation                                 │
│ • Risk assessment summaries                                    │
│ • Trade plan formatting                                        │
│ • Tool calling for calculations                                │
│                                                                 │
│ Claude 3.5 Sonnet (Long context):                             │
│ • Deep market analysis reports                                 │
│ • Strategy backtesting narratives                             │
│ • Comprehensive research briefs                               │
│ • Complex multi-factor analysis                               │
└─────────────────────────────────────────────────────────────────┘
```

### 4. Dynamic Signal System

#### Static vs Dynamic Signal Architecture
```
Static Signals (Premium Tier):
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   ML Model      │────▶│  Signal Gen     │────▶│  Static Image   │
│   Prediction    │     │  + Explanation  │     │  + Basic Info   │
└─────────────────┘     └─────────────────┘     └─────────────────┘

Dynamic Signals (Pay-per-signal):
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   ML Model      │────▶│  Enhanced Gen   │────▶│  Live Updates   │
│   + Live Data   │     │  + AI Research  │     │  + News Feed    │
│   + News API    │     │  + Perplexity   │     │  + Predictions  │
│   + Sentiment   │     │  + Deep Analysis│     │  + Risk Mgmt    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### 5. Data Storage Architecture

#### Time Series & OLAP Storage
```
┌─────────────────────────────────────────────────────────────────┐
│                     Storage Architecture                       │
├─────────────────────────────────────────────────────────────────┤
│ Hot Data (Redis):                                              │
│ • Latest prices, greeks                                        │
│ • User sessions, preferences                                   │
│ • Signal cache                                                 │
│ • Real-time features                                           │
│                                                                 │
│ Warm Data (ClickHouse):                                        │
│ • Tick data, quotes, trades                                    │
│ • Feature engineering materialized views                       │
│ • Signal performance history                                   │
│ • User behavior analytics                                      │
│                                                                 │
│ Cold Data (S3/GCS):                                            │
│ • Historical market data archives                              │
│ • Model training datasets                                      │
│ • Backup and compliance data                                   │
│ • Image/video assets for signals                               │
│                                                                 │
│ Application Data (PocketBase):                                 │
│ • User accounts, profiles                                      │
│ • Subscription management                                      │
│ • Signal metadata                                              │
│ • Watchlists, preferences                                      │
└─────────────────────────────────────────────────────────────────┘
```

### 6. Payment & Subscription System

#### Enhanced Subscription Model
```dart
class SubscriptionService {
  // Static tiers
  enum SubscriptionTier {
    free,      // Historical summaries only
    premium,   // $19.99/month - Real-time static signals
  }
  
  // Dynamic signal upgrades
  class DynamicSignalUpgrade {
    String signalId;
    double upgradePrice;  // e.g., $4.99 per signal
    Duration liveDuration;  // e.g., 72 hours
    List<Feature> additionalFeatures;
  }
  
  enum Feature {
    liveUpdates,
    newsIntegration,
    riskAnalysis,
    performanceTracking,
    aiExplanations
  }
}
```

### 7. Real-Time Communication

#### WebSocket Architecture
```typescript
// WebSocket channels for different data types
interface WebSocketChannels {
  // User-specific channels
  userSignals: `user:${userId}:signals`,
  userWatchlist: `user:${userId}:watchlist`,
  userNotifications: `user:${userId}:notifications`,
  
  // Market data channels
  marketData: `market:${symbol}:updates`,
  signalUpdates: `signal:${signalId}:live`,
  
  // Global channels
  systemAlerts: 'system:alerts',
  marketStatus: 'market:status'
}
```

### 8. Monitoring & Observability

#### Performance Metrics
```
Real-time SLAs:
• WebSocket tick → feature update: <25ms
• ML model inference: <5ms  
• LLM explanation (async): <400ms
• Signal generation end-to-end: <100ms
• Dynamic signal upgrade: <2s
```

## Implementation Roadmap

### Phase 1: Foundation (Months 1-2)
- [ ] Set up real-time data ingestion (Kafka/Redis)
- [ ] Implement basic ML signal generation pipeline
- [ ] Add WebSocket server for live updates
- [ ] Integrate Stripe for payments
- [ ] Build risk profiling system

### Phase 2: Core Features (Months 2-3)  
- [ ] Deploy ClickHouse for time-series storage
- [ ] Implement static signal generation
- [ ] Add LLM integration (GPT-4.1 Mini)
- [ ] Build dynamic signal upgrade system
- [ ] Create signal image generation

### Phase 3: Advanced Features (Months 3-4)
- [ ] Integrate Perplexity for live research
- [ ] Add Claude for deep analysis
- [ ] Implement news/catalyst detection
- [ ] Build backtesting system
- [ ] Add performance analytics

### Phase 4: Scale & Optimize (Months 4-6)
- [ ] Production ML model deployment
- [ ] Advanced feature engineering
- [ ] Multi-timeframe signals
- [ ] Options strategies signals
- [ ] Risk management tools

## Technology Stack Summary

### Backend Services
- **API Gateway**: PocketBase (cost-effective, easy deployment)
- **Real-time**: Node.js WebSocket server or Go with gorilla/websocket
- **Message Queue**: Kafka/Redpanda for market data streaming
- **Cache**: Redis for hot data and session management
- **Time Series**: ClickHouse for tick data and features
- **Object Storage**: S3/GCS for assets and archives

### ML/AI Stack
- **Core ML**: Python with XGBoost, LightGBM, scikit-learn
- **Time Series**: TensorFlow/PyTorch with TFT models
- **Feature Store**: Feast.dev or custom Redis-based solution
- **Model Serving**: FastAPI with Ray Serve or NVIDIA Triton
- **LLMs**: 
  - Perplexity API (pplx-70b-online) for live research
  - OpenAI GPT-4.1 Mini for explanations
  - Claude 3.5 Sonnet for deep analysis

### Infrastructure
- **Frontend**: Flutter (iOS/Android/Web)
- **CDN**: Vercel for static assets
- **Deployment**: Docker containers on AWS/GCP
- **Monitoring**: Sentry, DataDog, or Prometheus/Grafana
- **CI/CD**: GitHub Actions

### Cost Optimization
- Use PocketBase instead of expensive managed backends
- Implement intelligent caching strategies  
- Optimize LLM usage with smart prompt engineering
- Use spot instances for ML training workloads
- Implement data lifecycle management

This architecture provides a solid foundation for building a competitive trading signals platform while keeping costs manageable and maintaining the flexibility to scale as the user base grows.

## Next Steps

1. **Immediate**: Set up the real-time data pipeline and basic signal generation
2. **Short-term**: Implement the 3-tier subscription model and payment system
3. **Medium-term**: Add advanced ML models and LLM integration
4. **Long-term**: Scale the platform with advanced analytics and personalization

The modular design allows for incremental development while ensuring each component can be optimized and scaled independently as the product grows.