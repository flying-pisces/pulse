import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/signal.dart';
import '../../domain/entities/user.dart';

// Signals State
class SignalsState {
  final List<Signal> signals;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const SignalsState({
    required this.signals,
    required this.isLoading,
    this.error,
    required this.hasMore,
    required this.currentPage,
  });

  SignalsState copyWith({
    List<Signal>? signals,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return SignalsState(
      signals: signals ?? this.signals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Signals State Notifier
class SignalsNotifier extends StateNotifier<SignalsState> {
  SignalsNotifier() : super(const SignalsState(
    signals: [],
    isLoading: false,
    hasMore: true,
    currentPage: 0,
  ));

  Future<void> loadSignals({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        signals: [],
        currentPage: 0,
        hasMore: true,
      );
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final mockSignals = _generateMockSignals();
      
      state = state.copyWith(
        signals: refresh ? mockSignals : [...state.signals, ...mockSignals],
        isLoading: false,
        hasMore: mockSignals.length == 10, // Assume 10 per page
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  List<Signal> _generateMockSignals() {
    final symbols = ['AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN', 'NVDA', 'META', 'BTC', 'ETH', 'AMD'];
    final companies = [
      'Apple Inc.',
      'Alphabet Inc.',
      'Microsoft Corporation',
      'Tesla Inc.',
      'Amazon.com Inc.',
      'NVIDIA Corporation',
      'Meta Platforms Inc.',
      'Bitcoin',
      'Ethereum',
      'Advanced Micro Devices'
    ];
    
    return List.generate(10, (index) {
      final random = DateTime.now().millisecondsSinceEpoch + index;
      final symbol = symbols[index % symbols.length];
      final company = companies[index % companies.length];
      final currentPrice = 100.0 + (random % 500);
      
      return Signal(
        id: 'signal_$random',
        symbol: symbol,
        companyName: company,
        type: index < 7 ? SignalType.stock : SignalType.crypto,
        action: SignalAction.values[random % 3],
        currentPrice: currentPrice,
        targetPrice: currentPrice * (1 + (random % 20 - 10) / 100),
        stopLoss: currentPrice * (1 - (random % 15 + 5) / 100),
        confidence: 0.6 + (random % 40) / 100,
        reasoning: _getRandomReasoning(symbol),
        createdAt: DateTime.now().subtract(Duration(hours: random % 24)),
        expiresAt: DateTime.now().add(Duration(days: random % 7 + 1)),
        status: SignalStatus.active,
        tags: _getRandomTags(),
        requiredTier: SubscriptionTier.values[random % 4],
        profitLossPercentage: (random % 200 - 100) / 10,
      );
    });
  }

  String _getRandomReasoning(String symbol) {
    final reasons = [
      'Strong technical breakout with high volume',
      'Bullish divergence on RSI indicator',
      'Support level holding with bounce pattern',
      'Moving average crossover signal',
      'Earnings momentum expected to drive price',
      'Oversold conditions presenting opportunity',
      'Resistance breakthrough with continuation pattern',
      'Market sentiment shift favoring this sector',
    ];
    
    return 'AI Analysis: ${reasons[DateTime.now().microsecond % reasons.length]} for $symbol. Our algorithm detected a high-probability setup based on multiple technical indicators.';
  }

  List<String> _getRandomTags() {
    final allTags = ['AI Pick', 'High Volume', 'Earnings Play', 'Technical', 'Momentum', 'Breakout', 'Reversal', 'Trend'];
    final count = 2 + (DateTime.now().microsecond % 3);
    
    final tags = <String>[];
    final usedIndices = <int>{};
    
    for (int i = 0; i < count; i++) {
      int index;
      do {
        index = DateTime.now().microsecond % allTags.length;
      } while (usedIndices.contains(index));
      
      usedIndices.add(index);
      tags.add(allTags[index]);
    }
    
    return tags;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final signalsProvider = StateNotifierProvider<SignalsNotifier, SignalsState>((ref) {
  return SignalsNotifier();
});

// Filtered signals providers
final activeSignalsProvider = Provider<List<Signal>>((ref) {
  final signals = ref.watch(signalsProvider);
  return signals.signals.where((signal) => signal.isActive).toList();
});

final profitableSignalsProvider = Provider<List<Signal>>((ref) {
  final signals = ref.watch(signalsProvider);
  return signals.signals.where((signal) => signal.isProfitable).toList();
});

final signalsByTypeProvider = Provider.family<List<Signal>, SignalType>((ref, type) {
  final signals = ref.watch(signalsProvider);
  return signals.signals.where((signal) => signal.type == type).toList();
});