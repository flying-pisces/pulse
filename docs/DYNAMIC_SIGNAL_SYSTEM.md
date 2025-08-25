# Dynamic Signal Upgrade System

## Overview

The Dynamic Signal Upgrade System enables users to upgrade static premium signals to real-time dynamic signals with enhanced features like live updates, news integration, and AI-powered analysis.

## System Architecture

```
Premium Static Signal → Upgrade Payment → Dynamic Signal Activation → Live Updates
         ↓                     ↓                      ↓                    ↓
   Signal Card UI      Stripe Payment       Enhanced Pipeline        WebSocket Stream
   Upgrade Button     Per-Signal Billing    AI Research Layer        Real-time Updates
   Price Display      Payment Processing    News Integration         Performance Tracking
```

## Core Components

### 1. Signal Upgrade UI/UX Flow

#### Flutter Mobile Implementation

```dart
// lib/presentation/widgets/signal_upgrade_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/signal.dart';
import '../../presentation/providers/signals_provider.dart';
import '../../presentation/providers/payment_provider.dart';

class SignalUpgradeCard extends ConsumerWidget {
  final Signal signal;
  
  const SignalUpgradeCard({
    Key? key,
    required this.signal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signalsState = ref.watch(signalsProvider);
    final paymentState = ref.watch(paymentProvider);
    
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSignalHeader(),
            SizedBox(height: 12),
            _buildSignalContent(),
            SizedBox(height: 16),
            _buildUpgradeSection(context, ref),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSignalHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildSignalTypeChip(),
            SizedBox(width: 8),
            Text(
              signal.symbol,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        _buildConfidenceIndicator(),
      ],
    );
  }
  
  Widget _buildSignalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPriceInfo('Current', '\$${signal.currentPrice.toStringAsFixed(2)}'),
            _buildPriceInfo('Target', '\$${signal.targetPrice.toStringAsFixed(2)}'),
            _buildPriceInfo('Stop', '\$${signal.stopLoss.toStringAsFixed(2)}'),
          ],
        ),
        SizedBox(height: 12),
        Text(
          signal.reasoning,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        if (signal.imageUrl != null) ...[
          SizedBox(height: 12),
          _buildSignalImage(),
        ],
      ],
    );
  }
  
  Widget _buildUpgradeSection(BuildContext context, WidgetRef ref) {
    final isDynamic = signal.isDynamic ?? false;
    
    if (isDynamic) {
      return _buildDynamicSignalFeatures();
    }
    
    return _buildUpgradePrompt(context, ref);
  }
  
  Widget _buildUpgradePrompt(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upgrade, color: Colors.blue.shade600),
              SizedBox(width: 8),
              Text(
                'Upgrade to Dynamic Signal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Get real-time updates, news integration, and AI analysis',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 12),
          _buildDynamicFeaturesList(),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$4.99 for 72 hours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _handleUpgrade(context, ref),
                icon: Icon(Icons.flash_on),
                label: Text('Upgrade Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDynamicFeaturesList() {
    final features = [
      'Real-time price updates',
      'Live news & catalyst alerts',
      'AI-powered analysis updates',
      'Risk management alerts',
      'Performance tracking',
    ];
    
    return Column(
      children: features.map((feature) => Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 8),
            Text(feature, style: TextStyle(fontSize: 13)),
          ],
        ),
      )).toList(),
    );
  }
  
  Widget _buildDynamicSignalFeatures() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.green.shade600),
              SizedBox(width: 8),
              Text(
                'Dynamic Signal Active',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              Spacer(),
              _buildLiveIndicator(),
            ],
          ),
          SizedBox(height: 12),
          _buildLiveUpdatesSection(),
        ],
      ),
    );
  }
  
  Widget _buildLiveIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleUpgrade(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Processing upgrade...'),
            ],
          ),
        ),
      );
      
      // Process payment and upgrade
      final success = await ref.read(paymentProvider.notifier).upgradeSignal(
        signalId: signal.id,
        amount: 4.99,
      );
      
      Navigator.pop(context); // Close loading dialog
      
      if (success) {
        // Show success and refresh signal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signal upgraded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh signal data
        await ref.read(signalsProvider.notifier).refreshSignal(signal.id);
      }
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upgrade failed: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Widget _buildSignalTypeChip() {
    Color chipColor;
    switch (signal.action) {
      case SignalAction.buy:
        chipColor = Colors.green;
        break;
      case SignalAction.sell:
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        signal.action.displayName,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildConfidenceIndicator() {
    return Row(
      children: [
        Text('${(signal.confidence * 100).toInt()}%'),
        SizedBox(width: 4),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.grey[300],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: signal.confidence,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: signal.confidence > 0.7
                    ? Colors.green
                    : signal.confidence > 0.5
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPriceInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSignalImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        signal.imageUrl!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: Center(
              child: Text('Chart unavailable'),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildLiveUpdatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Updates',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        _buildUpdatesList(),
      ],
    );
  }
  
  Widget _buildUpdatesList() {
    // This would be populated from real-time updates
    final updates = [
      'Price update: \$${signal.currentPrice.toStringAsFixed(2)}',
      'Volume spike detected (+15%)',
      'News: Analyst upgrade at Goldman Sachs',
    ];
    
    return Column(
      children: updates.take(3).map((update) => Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(Icons.fiber_manual_record, color: Colors.blue, size: 8),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                update,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
```

### 2. Payment Processing System

#### Stripe Integration for Per-Signal Billing

```dart
// lib/data/datasources/payment_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/payment_result.dart';

class PaymentService {
  final Dio _dio;
  final String _stripePublishableKey;
  final String _backendUrl;
  
  PaymentService()
      : _dio = Dio(),
        _stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '',
        _backendUrl = dotenv.env['BACKEND_URL'] ?? '';

  Future<PaymentResult> processSignalUpgrade({
    required String signalId,
    required double amount,
    required String userId,
  }) async {
    try {
      // Step 1: Create payment intent on backend
      final paymentIntent = await _createPaymentIntent(
        signalId: signalId,
        amount: amount,
        userId: userId,
      );
      
      // Step 2: Process payment with Stripe
      final paymentResult = await _processStripePayment(
        paymentIntentId: paymentIntent['id'],
        clientSecret: paymentIntent['client_secret'],
      );
      
      if (paymentResult.isSuccess) {
        // Step 3: Confirm upgrade on backend
        await _confirmSignalUpgrade(signalId, paymentIntent['id']);
        
        return PaymentResult(
          isSuccess: true,
          transactionId: paymentIntent['id'],
          message: 'Signal upgraded successfully',
        );
      } else {
        return paymentResult;
      }
      
    } catch (error) {
      return PaymentResult(
        isSuccess: false,
        error: error.toString(),
        message: 'Payment processing failed',
      );
    }
  }
  
  Future<Map<String, dynamic>> _createPaymentIntent({
    required String signalId,
    required double amount,
    required String userId,
  }) async {
    final response = await _dio.post(
      '$_backendUrl/api/payments/signal-upgrade/intent',
      data: {
        'signal_id': signalId,
        'amount': (amount * 100).round(), // Convert to cents
        'user_id': userId,
        'currency': 'usd',
        'metadata': {
          'signal_id': signalId,
          'upgrade_type': 'dynamic_signal',
          'duration_hours': 72,
        },
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
          'Content-Type': 'application/json',
        },
      ),
    );
    
    return response.data;
  }
  
  Future<PaymentResult> _processStripePayment({
    required String paymentIntentId,
    required String clientSecret,
  }) async {
    // This would integrate with Stripe Flutter SDK
    // For now, showing the structure
    try {
      // Stripe payment processing would go here
      // Using stripe_flutter package or similar
      
      return PaymentResult(
        isSuccess: true,
        transactionId: paymentIntentId,
        message: 'Payment processed successfully',
      );
      
    } catch (error) {
      return PaymentResult(
        isSuccess: false,
        error: error.toString(),
        message: 'Stripe payment failed',
      );
    }
  }
  
  Future<void> _confirmSignalUpgrade(String signalId, String paymentIntentId) async {
    await _dio.post(
      '$_backendUrl/api/signals/$signalId/upgrade/confirm',
      data: {
        'payment_intent_id': paymentIntentId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      ),
    );
  }
  
  Future<String> _getAuthToken() async {
    // Get auth token from secure storage
    return 'user_auth_token';
  }
}
```

### 3. Backend Signal Upgrade Processing

#### Node.js/Express Backend Service

```javascript
// backend/services/signal-upgrade-service.js
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { PocketBase } = require('pocketbase');
const WebSocketManager = require('./websocket-manager');
const AIAnalysisService = require('./ai-analysis-service');
const NewsService = require('./news-service');

class SignalUpgradeService {
  constructor() {
    this.pb = new PocketBase(process.env.POCKETBASE_URL);
    this.wsManager = new WebSocketManager();
    this.aiService = new AIAnalysisService();
    this.newsService = new NewsService();
    this.activeUpgrades = new Map();
  }
  
  async createUpgradePaymentIntent(data) {
    const { signal_id, amount, user_id, currency } = data;
    
    try {
      // Validate signal exists and user has access
      const signal = await this.pb.collection('signals').getOne(signal_id);
      const user = await this.pb.collection('users').getOne(user_id);
      
      if (!signal || !user) {
        throw new Error('Invalid signal or user');
      }
      
      // Check if user has premium subscription
      if (user.subscriptionTier !== 'premium' && user.subscriptionTier !== 'pro') {
        throw new Error('Premium subscription required');
      }
      
      // Create Stripe payment intent
      const paymentIntent = await stripe.paymentIntents.create({
        amount: amount, // Amount in cents
        currency: currency || 'usd',
        customer: user.stripeCustomerId,
        metadata: {
          signal_id,
          user_id,
          upgrade_type: 'dynamic_signal',
          duration_hours: '72',
        },
        description: `Dynamic signal upgrade for ${signal.symbol}`,
      });
      
      // Store pending upgrade
      await this.pb.collection('signal_upgrades').create({
        signal_id,
        user_id,
        payment_intent_id: paymentIntent.id,
        amount: amount / 100, // Store in dollars
        status: 'pending',
        expires_at: new Date(Date.now() + 72 * 60 * 60 * 1000), // 72 hours
      });
      
      return {
        id: paymentIntent.id,
        client_secret: paymentIntent.client_secret,
        amount: paymentIntent.amount,
        currency: paymentIntent.currency,
      };
      
    } catch (error) {
      console.error('Failed to create payment intent:', error);
      throw error;
    }
  }
  
  async confirmSignalUpgrade(signalId, paymentIntentId) {
    try {
      // Verify payment was successful
      const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
      
      if (paymentIntent.status !== 'succeeded') {
        throw new Error('Payment not completed');
      }
      
      // Get upgrade record
      const upgrade = await this.pb.collection('signal_upgrades')
        .getFirstListItem(`payment_intent_id="${paymentIntentId}"`);
      
      if (!upgrade) {
        throw new Error('Upgrade record not found');
      }
      
      // Update signal to dynamic
      await this.pb.collection('signals').update(signalId, {
        is_dynamic: true,
        dynamic_expires_at: upgrade.expires_at,
        dynamic_user_id: upgrade.user_id,
      });
      
      // Update upgrade status
      await this.pb.collection('signal_upgrades').update(upgrade.id, {
        status: 'confirmed',
        confirmed_at: new Date(),
      });
      
      // Start dynamic tracking
      await this.startDynamicTracking(signalId, upgrade.user_id);
      
      // Send confirmation to user
      await this.wsManager.sendToUser(upgrade.user_id, {
        type: 'signal_upgrade_confirmed',
        signal_id: signalId,
        expires_at: upgrade.expires_at,
      });
      
      return { success: true };
      
    } catch (error) {
      console.error('Failed to confirm upgrade:', error);
      throw error;
    }
  }
  
  async startDynamicTracking(signalId, userId) {
    if (this.activeUpgrades.has(signalId)) {
      return; // Already tracking
    }
    
    const signal = await this.pb.collection('signals').getOne(signalId);
    
    const tracker = {
      signalId,
      userId,
      symbol: signal.symbol,
      interval: null,
      lastUpdate: new Date(),
    };
    
    // Start periodic updates (every 5 minutes)
    tracker.interval = setInterval(async () => {
      await this.processDynamicUpdate(signalId, userId);
    }, 5 * 60 * 1000);
    
    this.activeUpgrades.set(signalId, tracker);
    
    // Send initial enhanced data
    await this.sendEnhancedSignalData(signalId, userId);
  }
  
  async processDynamicUpdate(signalId, userId) {
    try {
      const signal = await this.pb.collection('signals').getOne(signalId);
      
      // Check if upgrade expired
      const upgrade = await this.pb.collection('signal_upgrades')
        .getFirstListItem(`signal_id="${signalId}" && user_id="${userId}"`);
      
      if (new Date() > new Date(upgrade.expires_at)) {
        await this.stopDynamicTracking(signalId);
        return;
      }
      
      // Get latest market data
      const currentPrice = await this.getCurrentPrice(signal.symbol);
      
      // Get AI analysis update
      const aiAnalysis = await this.aiService.analyzeSignalUpdate(signal, currentPrice);
      
      // Get news updates
      const newsUpdates = await this.newsService.getLatestNews(signal.symbol);
      
      // Calculate performance
      const performance = this.calculatePerformance(signal, currentPrice);
      
      // Check for important updates
      const updates = await this.checkForImportantUpdates(signal, currentPrice, newsUpdates);
      
      if (updates.length > 0 || this.shouldSendPeriodicUpdate(signalId)) {
        await this.sendDynamicUpdate(signalId, userId, {
          current_price: currentPrice,
          performance: performance,
          ai_analysis: aiAnalysis,
          news_updates: newsUpdates.slice(0, 3), // Latest 3 news items
          updates: updates,
          timestamp: new Date(),
        });
      }
      
    } catch (error) {
      console.error(`Dynamic update failed for signal ${signalId}:`, error);
    }
  }
  
  async checkForImportantUpdates(signal, currentPrice, newsUpdates) {
    const updates = [];
    
    // Price target/stop loss alerts
    const targetHitPercent = this.calculateTargetProgress(signal, currentPrice);
    if (targetHitPercent >= 0.8) {
      updates.push({
        type: 'target_approaching',
        message: `Target price approaching (${(targetHitPercent * 100).toFixed(0)}% complete)`,
        priority: 'high',
      });
    }
    
    const stopLossDistance = Math.abs(currentPrice - signal.stopLoss) / signal.currentPrice;
    if (stopLossDistance < 0.02) { // Within 2%
      updates.push({
        type: 'stop_loss_alert',
        message: 'Price approaching stop loss level',
        priority: 'critical',
      });
    }
    
    // Volume spike detection
    const volumeSpike = await this.checkVolumeSpike(signal.symbol);
    if (volumeSpike.isSpike) {
      updates.push({
        type: 'volume_spike',
        message: `Volume spike detected (+${volumeSpike.percentIncrease}%)`,
        priority: 'medium',
      });
    }
    
    // Breaking news
    const breakingNews = newsUpdates.filter(news => 
      news.importance === 'high' && 
      new Date(news.publishedAt) > new Date(Date.now() - 30 * 60 * 1000) // Last 30 mins
    );
    
    if (breakingNews.length > 0) {
      updates.push({
        type: 'breaking_news',
        message: `Breaking: ${breakingNews[0].headline}`,
        priority: 'high',
        url: breakingNews[0].url,
      });
    }
    
    return updates;
  }
  
  async sendDynamicUpdate(signalId, userId, updateData) {
    await this.wsManager.sendToUser(userId, {
      type: 'dynamic_signal_update',
      signal_id: signalId,
      data: updateData,
    });
    
    // Store update in database for history
    await this.pb.collection('signal_updates').create({
      signal_id: signalId,
      user_id: userId,
      update_data: updateData,
      created_at: new Date(),
    });
    
    // Update last update timestamp
    const tracker = this.activeUpgrades.get(signalId);
    if (tracker) {
      tracker.lastUpdate = new Date();
    }
  }
  
  async stopDynamicTracking(signalId) {
    const tracker = this.activeUpgrades.get(signalId);
    if (tracker) {
      if (tracker.interval) {
        clearInterval(tracker.interval);
      }
      this.activeUpgrades.delete(signalId);
      
      // Update signal to non-dynamic
      await this.pb.collection('signals').update(signalId, {
        is_dynamic: false,
        dynamic_expires_at: null,
        dynamic_user_id: null,
      });
      
      // Notify user that dynamic period ended
      await this.wsManager.sendToUser(tracker.userId, {
        type: 'dynamic_signal_expired',
        signal_id: signalId,
        message: 'Dynamic signal period has ended',
      });
    }
  }
  
  calculatePerformance(signal, currentPrice) {
    const entryPrice = signal.currentPrice;
    const pnlPercent = ((currentPrice - entryPrice) / entryPrice) * 100;
    
    let status = 'active';
    if (signal.action === 'buy') {
      if (currentPrice >= signal.targetPrice) status = 'target_hit';
      else if (currentPrice <= signal.stopLoss) status = 'stop_hit';
    } else if (signal.action === 'sell') {
      if (currentPrice <= signal.targetPrice) status = 'target_hit';
      else if (currentPrice >= signal.stopLoss) status = 'stop_hit';
    }
    
    return {
      pnl_percent: pnlPercent,
      pnl_amount: (currentPrice - entryPrice).toFixed(2),
      status: status,
      current_price: currentPrice,
      entry_price: entryPrice,
    };
  }
  
  calculateTargetProgress(signal, currentPrice) {
    const entryPrice = signal.currentPrice;
    const targetPrice = signal.targetPrice;
    
    if (signal.action === 'buy') {
      return (currentPrice - entryPrice) / (targetPrice - entryPrice);
    } else {
      return (entryPrice - currentPrice) / (entryPrice - targetPrice);
    }
  }
  
  shouldSendPeriodicUpdate(signalId) {
    const tracker = this.activeUpgrades.get(signalId);
    if (!tracker) return false;
    
    // Send periodic update every 30 minutes even if no significant changes
    const timeSinceLastUpdate = Date.now() - tracker.lastUpdate.getTime();
    return timeSinceLastUpdate > 30 * 60 * 1000;
  }
  
  async getCurrentPrice(symbol) {
    // Integration with market data provider
    // This would call your market data service
    return 150.25; // Placeholder
  }
  
  async checkVolumeSpike(symbol) {
    // Check for unusual volume activity
    // This would analyze recent volume vs historical averages
    return {
      isSpike: false,
      percentIncrease: 0,
    };
  }
}

module.exports = SignalUpgradeService;
```

### 4. Real-time WebSocket Manager

```javascript
// backend/services/websocket-manager.js
const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const { PocketBase } = require('pocketbase');

class WebSocketManager {
  constructor() {
    this.wss = null;
    this.clients = new Map(); // userId -> WebSocket connection
    this.pb = new PocketBase(process.env.POCKETBASE_URL);
  }
  
  initialize(server) {
    this.wss = new WebSocket.Server({ 
      server,
      path: '/ws',
    });
    
    this.wss.on('connection', (ws, request) => {
      this.handleConnection(ws, request);
    });
    
    console.log('WebSocket server initialized');
  }
  
  async handleConnection(ws, request) {
    try {
      // Extract token from query params or headers
      const token = this.extractToken(request);
      if (!token) {
        ws.close(4001, 'Authentication required');
        return;
      }
      
      // Verify JWT token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const userId = decoded.userId;
      
      // Validate user exists and has valid subscription
      const user = await this.pb.collection('users').getOne(userId);
      if (!user || !this.hasValidSubscription(user)) {
        ws.close(4003, 'Invalid subscription');
        return;
      }
      
      // Store connection
      this.clients.set(userId, ws);
      
      // Set up heartbeat
      ws.isAlive = true;
      ws.on('pong', () => {
        ws.isAlive = true;
      });
      
      // Handle messages from client
      ws.on('message', (data) => {
        this.handleClientMessage(userId, data);
      });
      
      // Clean up on disconnect
      ws.on('close', () => {
        this.clients.delete(userId);
        console.log(`User ${userId} disconnected`);
      });
      
      // Send welcome message
      this.sendToUser(userId, {
        type: 'connection_established',
        message: 'Real-time updates active',
        timestamp: new Date(),
      });
      
      console.log(`User ${userId} connected to WebSocket`);
      
    } catch (error) {
      console.error('WebSocket connection error:', error);
      ws.close(4000, 'Connection failed');
    }
  }
  
  extractToken(request) {
    const url = new URL(request.url, `http://${request.headers.host}`);
    return url.searchParams.get('token') || request.headers.authorization?.replace('Bearer ', '');
  }
  
  hasValidSubscription(user) {
    if (user.subscriptionTier === 'free') return false;
    
    if (user.subscriptionExpiresAt) {
      return new Date(user.subscriptionExpiresAt) > new Date();
    }
    
    return true;
  }
  
  handleClientMessage(userId, data) {
    try {
      const message = JSON.parse(data);
      
      switch (message.type) {
        case 'ping':
          this.sendToUser(userId, { type: 'pong' });
          break;
          
        case 'subscribe_signal':
          this.handleSignalSubscription(userId, message.signal_id);
          break;
          
        case 'unsubscribe_signal':
          this.handleSignalUnsubscription(userId, message.signal_id);
          break;
          
        default:
          console.log(`Unknown message type: ${message.type}`);
      }
    } catch (error) {
      console.error('Error handling client message:', error);
    }
  }
  
  async sendToUser(userId, message) {
    const ws = this.clients.get(userId);
    if (ws && ws.readyState === WebSocket.OPEN) {
      try {
        ws.send(JSON.stringify({
          ...message,
          timestamp: message.timestamp || new Date(),
        }));
      } catch (error) {
        console.error(`Failed to send message to user ${userId}:`, error);
        this.clients.delete(userId);
      }
    }
  }
  
  async broadcast(message, userFilter = null) {
    const tasks = [];
    
    for (const [userId, ws] of this.clients.entries()) {
      if (userFilter && !userFilter(userId)) continue;
      
      if (ws.readyState === WebSocket.OPEN) {
        tasks.push(this.sendToUser(userId, message));
      } else {
        this.clients.delete(userId);
      }
    }
    
    await Promise.allSettled(tasks);
  }
  
  startHeartbeat() {
    setInterval(() => {
      for (const [userId, ws] of this.clients.entries()) {
        if (!ws.isAlive) {
          ws.terminate();
          this.clients.delete(userId);
          continue;
        }
        
        ws.isAlive = false;
        ws.ping();
      }
    }, 30000); // 30 seconds
  }
  
  getConnectedUsers() {
    return Array.from(this.clients.keys());
  }
  
  getConnectionCount() {
    return this.clients.size;
  }
}

module.exports = WebSocketManager;
```

### 5. AI-Powered Dynamic Analysis

#### Integration with Multiple LLM Services

```javascript
// backend/services/ai-analysis-service.js
const axios = require('axios');

class AIAnalysisService {
  constructor() {
    this.perplexityClient = axios.create({
      baseURL: 'https://api.perplexity.ai',
      headers: {
        'Authorization': `Bearer ${process.env.PERPLEXITY_API_KEY}`,
        'Content-Type': 'application/json',
      },
    });
    
    this.openaiClient = axios.create({
      baseURL: 'https://api.openai.com/v1',
      headers: {
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
    });
    
    this.anthropicClient = axios.create({
      baseURL: 'https://api.anthropic.com/v1',
      headers: {
        'x-api-key': process.env.ANTHROPIC_API_KEY,
        'Content-Type': 'application/json',
        'anthropic-version': '2023-06-01',
      },
    });
  }
  
  async analyzeSignalUpdate(signal, currentPrice) {
    try {
      // Use different AI services for different aspects
      const [liveResearch, quickAnalysis, deepAnalysis] = await Promise.allSettled([
        this.getLiveResearch(signal.symbol, signal),
        this.getQuickAnalysis(signal, currentPrice),
        this.getDeepAnalysis(signal, currentPrice),
      ]);
      
      return {
        live_research: liveResearch.status === 'fulfilled' ? liveResearch.value : null,
        quick_analysis: quickAnalysis.status === 'fulfilled' ? quickAnalysis.value : null,
        deep_analysis: deepAnalysis.status === 'fulfilled' ? deepAnalysis.value : null,
        analysis_timestamp: new Date(),
      };
      
    } catch (error) {
      console.error('AI analysis failed:', error);
      return {
        error: 'Analysis temporarily unavailable',
        analysis_timestamp: new Date(),
      };
    }
  }
  
  async getLiveResearch(symbol, signal) {
    // Use Perplexity for live research with citations
    const prompt = `Research the latest news, analyst updates, and market developments for ${symbol} in the last 24 hours. 
    Focus on factors that could impact a ${signal.action} signal with target $${signal.targetPrice} and stop loss $${signal.stopLoss}.
    Provide specific, actionable insights with credible sources.`;
    
    try {
      const response = await this.perplexityClient.post('/chat/completions', {
        model: 'pplx-70b-online',
        messages: [
          { role: 'system', content: 'You are a professional financial analyst providing real-time market research.' },
          { role: 'user', content: prompt }
        ],
        max_tokens: 500,
        temperature: 0.1,
      });
      
      return {
        content: response.data.choices[0].message.content,
        sources: response.data.citations || [],
        provider: 'perplexity',
      };
      
    } catch (error) {
      console.error('Perplexity API error:', error);
      throw error;
    }
  }
  
  async getQuickAnalysis(signal, currentPrice) {
    // Use GPT-4.1 Mini for quick, cost-effective analysis
    const pnlPercent = ((currentPrice - signal.currentPrice) / signal.currentPrice * 100).toFixed(2);
    
    const prompt = `Analyze this trading signal update:
    
    Symbol: ${signal.symbol}
    Action: ${signal.action}
    Entry: $${signal.currentPrice}
    Current: $${currentPrice}
    Target: $${signal.targetPrice} 
    Stop: $${signal.stopLoss}
    Current P&L: ${pnlPercent}%
    
    Provide a concise 2-3 sentence analysis of the current position and any recommended actions.`;
    
    try {
      const response = await this.openaiClient.post('/chat/completions', {
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: 'You are a concise trading analyst. Provide brief, actionable insights.' },
          { role: 'user', content: prompt }
        ],
        max_tokens: 200,
        temperature: 0.1,
      });
      
      return {
        content: response.data.choices[0].message.content,
        pnl_percent: parseFloat(pnlPercent),
        provider: 'openai-mini',
      };
      
    } catch (error) {
      console.error('OpenAI API error:', error);
      throw error;
    }
  }
  
  async getDeepAnalysis(signal, currentPrice) {
    // Use Claude for comprehensive analysis when needed
    const prompt = `Provide a comprehensive analysis of this trading signal:
    
    Signal Details:
    - Symbol: ${signal.symbol}
    - Action: ${signal.action}
    - Entry Price: $${signal.currentPrice}
    - Current Price: $${currentPrice}
    - Target Price: $${signal.targetPrice}
    - Stop Loss: $${signal.stopLoss}
    - Original Reasoning: ${signal.reasoning}
    - Time Horizon: ${signal.timeHorizon || '3 days'}
    
    Please analyze:
    1. Current position status and performance
    2. Key risk factors and catalysts to watch
    3. Probability assessment of reaching target vs stop
    4. Recommended position management strategy
    5. Exit strategy considerations
    
    Provide specific, actionable insights for an active trader.`;
    
    try {
      const response = await this.anthropicClient.post('/messages', {
        model: 'claude-3-5-sonnet-20241022',
        max_tokens: 800,
        temperature: 0.1,
        messages: [
          { role: 'user', content: prompt }
        ],
      });
      
      return {
        content: response.data.content[0].text,
        provider: 'claude',
      };
      
    } catch (error) {
      console.error('Claude API error:', error);
      throw error;
    }
  }
  
  async generateRiskAlert(signal, currentPrice, riskLevel) {
    // Generate risk-specific alerts using the most appropriate AI service
    let prompt, model, client;
    
    if (riskLevel === 'critical') {
      // Use GPT-4.1 Mini for fast critical alerts
      prompt = `CRITICAL ALERT: ${signal.symbol} position at immediate risk.
      Entry: $${signal.currentPrice}, Current: $${currentPrice}, Stop: $${signal.stopLoss}
      Generate a brief, urgent risk alert with immediate action required.`;
      
      model = 'gpt-4o-mini';
      client = this.openaiClient;
      
    } else {
      // Use Claude for detailed risk analysis
      prompt = `Risk assessment for ${signal.symbol} position:
      Entry: $${signal.currentPrice}, Current: $${currentPrice}
      Target: $${signal.targetPrice}, Stop: $${signal.stopLoss}
      Risk Level: ${riskLevel}
      
      Provide risk management guidance and position adjustment recommendations.`;
      
      model = 'claude-3-5-sonnet-20241022';
      client = this.anthropicClient;
    }
    
    try {
      const response = await client.post(
        client === this.anthropicClient ? '/messages' : '/chat/completions',
        client === this.anthropicClient ? {
          model,
          max_tokens: 300,
          messages: [{ role: 'user', content: prompt }],
        } : {
          model,
          messages: [{ role: 'user', content: prompt }],
          max_tokens: 300,
        }
      );
      
      const content = client === this.anthropicClient 
        ? response.data.content[0].text 
        : response.data.choices[0].message.content;
      
      return {
        content,
        risk_level: riskLevel,
        provider: client === this.anthropicClient ? 'claude' : 'openai',
        timestamp: new Date(),
      };
      
    } catch (error) {
      console.error('Risk alert generation failed:', error);
      return {
        content: `Risk alert: ${signal.symbol} requires attention. Current price: $${currentPrice}`,
        risk_level: riskLevel,
        provider: 'fallback',
        timestamp: new Date(),
      };
    }
  }
}

module.exports = AIAnalysisService;
```

## Key Features Summary

### Dynamic Signal Upgrade System provides:

1. **Seamless Payment Flow**: One-click upgrade with Stripe integration
2. **Real-time Updates**: Live price, news, and AI analysis via WebSocket
3. **Multi-tier AI Integration**: 
   - Perplexity for live research with citations
   - GPT-4.1 Mini for quick, cost-effective explanations
   - Claude for deep analysis and risk assessment
4. **Performance Tracking**: Real-time P&L and progress monitoring
5. **Smart Alerts**: Critical risk alerts and target approach notifications
6. **Time-bound Access**: 72-hour dynamic access period
7. **Mobile-first UI**: Optimized Flutter interface with live indicators

### Pricing Strategy:
- **Static Signals**: Included with Premium ($19.99/month)
- **Dynamic Upgrade**: $4.99 per signal for 72 hours
- **High-value Signals**: Premium confidence signals justify upgrade cost

This system transforms static trading signals into interactive, AI-powered trading assistants that provide continuous value throughout the trade lifecycle.

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"content": "Analyze current repository architecture and understand existing components", "status": "completed", "activeForm": "Analyzing current repository architecture and understanding existing components"}, {"content": "Review user requirements for 3-tier trading signals app architecture", "status": "completed", "activeForm": "Reviewing user requirements for 3-tier trading signals app architecture"}, {"content": "Identify gaps between current implementation and required architecture", "status": "completed", "activeForm": "Identifying gaps between current implementation and required architecture"}, {"content": "Create comprehensive architecture plan for real-time signal generation system", "status": "completed", "activeForm": "Creating comprehensive architecture plan for real-time signal generation system"}, {"content": "Design signal processing pipeline with ML/AI integration", "status": "completed", "activeForm": "Designing signal processing pipeline with ML/AI integration"}, {"content": "Plan dynamic signal upgrade system with real-time updates", "status": "completed", "activeForm": "Planning dynamic signal upgrade system with real-time updates"}]