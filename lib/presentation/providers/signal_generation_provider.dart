import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/signal_generation_service.dart';
import '../../data/repositories/pocketbase_signal_repository.dart';
import '../../data/services/pocketbase_service.dart';
import 'market_data_provider.dart';

// Signal Generation Service Provider
final signalGenerationServiceProvider = Provider<SignalGenerationService>((ref) {
  final marketDataRepository = ref.read(marketDataRepositoryProvider);
  return SignalGenerationService(marketDataRepository);
});

// Generated Signals State
class GeneratedSignalsState {
  final List<GeneratedSignal> signals;
  final bool isLoading;
  final String? error;
  final DateTime? lastGenerated;

  const GeneratedSignalsState({
    this.signals = const [],
    required this.isLoading,
    this.error,
    this.lastGenerated,
  });

  GeneratedSignalsState copyWith({
    List<GeneratedSignal>? signals,
    bool? isLoading,
    String? error,
    DateTime? lastGenerated,
  }) {
    return GeneratedSignalsState(
      signals: signals ?? this.signals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastGenerated: lastGenerated ?? this.lastGenerated,
    );
  }
}

// Generated Signals Notifier
class GeneratedSignalsNotifier extends StateNotifier<GeneratedSignalsState> {
  final SignalGenerationService _signalGenerationService;
  final PocketBaseSignalRepository _signalRepository;
  
  GeneratedSignalsNotifier(
    this._signalGenerationService,
    this._signalRepository,
  ) : super(const GeneratedSignalsState(isLoading: false));

  /// Generate new signals
  Future<void> generateSignals({
    List<String>? watchlist,
    int maxSignals = 10,
    bool autoSave = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final signals = await _signalGenerationService.generateSignals(
        watchlist: watchlist,
        maxSignals: maxSignals,
      );
      
      // Auto-save high confidence signals to database
      if (autoSave) {
        await _saveHighConfidenceSignals(signals);
      }
      
      state = state.copyWith(
        signals: signals,
        isLoading: false,
        lastGenerated: DateTime.now(),
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh signals (regenerate)
  Future<void> refreshSignals({
    List<String>? watchlist,
    int maxSignals = 10,
  }) async {
    return generateSignals(
      watchlist: watchlist,
      maxSignals: maxSignals,
    );
  }

  /// Save signal to database
  Future<void> saveSignal(GeneratedSignal signal) async {
    try {
      final signalData = signal.toPocketBaseSignal();
      await _signalRepository.createSignal(signalData);
    } catch (e) {
      // Handle save error - could show notification
      state = state.copyWith(error: 'Failed to save signal: $e');
    }
  }

  /// Save multiple signals to database
  Future<void> saveSignals(List<GeneratedSignal> signals) async {
    for (final signal in signals) {
      try {
        await saveSignal(signal);
      } catch (e) {
        // Continue with other signals even if one fails
        continue;
      }
    }
  }

  /// Auto-save high confidence signals
  Future<void> _saveHighConfidenceSignals(List<GeneratedSignal> signals) async {
    final highConfidenceSignals = signals.where((signal) => 
      signal.confidenceScore >= 75.0 && signal.isValid
    ).toList();
    
    if (highConfidenceSignals.isNotEmpty) {
      await saveSignals(highConfidenceSignals);
    }
  }

  /// Filter signals by type
  List<GeneratedSignal> getSignalsByType(SignalType type) {
    return state.signals.where((signal) => signal.type == type).toList();
  }

  /// Get active (valid) signals only
  List<GeneratedSignal> get activeSignals {
    return state.signals.where((signal) => signal.isValid).toList();
  }

  /// Get signals by symbol
  List<GeneratedSignal> getSignalsForSymbol(String symbol) {
    return state.signals.where((signal) => 
      signal.symbol.toLowerCase() == symbol.toLowerCase()
    ).toList();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear all signals
  void clearSignals() {
    state = state.copyWith(signals: []);
  }
}

// Signal Repository Provider
final signalRepositoryProvider = Provider<PocketBaseSignalRepository>((ref) {
  final pocketBaseService = ref.read(pocketBaseServiceProvider);
  return PocketBaseSignalRepository(pocketBaseService);
});

// Generated Signals Provider
final generatedSignalsProvider = StateNotifierProvider<GeneratedSignalsNotifier, GeneratedSignalsState>((ref) {
  final signalGenerationService = ref.read(signalGenerationServiceProvider);
  final signalRepository = ref.read(signalRepositoryProvider);
  return GeneratedSignalsNotifier(signalGenerationService, signalRepository);
});

// Filtered Signals Providers
final activeSignalsProvider = Provider<List<GeneratedSignal>>((ref) {
  final state = ref.watch(generatedSignalsProvider);
  return state.signals.where((signal) => signal.isValid).toList();
});

final preMarketSignalsProvider = Provider<List<GeneratedSignal>>((ref) {
  final state = ref.watch(generatedSignalsProvider);
  return state.signals.where((signal) => 
    signal.type == SignalType.preMarket && signal.isValid
  ).toList();
});

final earningsSignalsProvider = Provider<List<GeneratedSignal>>((ref) {
  final state = ref.watch(generatedSignalsProvider);
  return state.signals.where((signal) => 
    signal.type == SignalType.earnings && signal.isValid
  ).toList();
});

final momentumSignalsProvider = Provider<List<GeneratedSignal>>((ref) {
  final state = ref.watch(generatedSignalsProvider);
  return state.signals.where((signal) => 
    signal.type == SignalType.momentum && signal.isValid
  ).toList();
});

// Auto Signal Generation Provider (for scheduled generation)
final autoSignalGenerationProvider = FutureProvider<void>((ref) async {
  final signalsNotifier = ref.read(generatedSignalsProvider.notifier);
  
  // Generate signals automatically on app start
  await signalsNotifier.generateSignals(maxSignals: 10);
});

// Signal Statistics Provider
final signalStatsProvider = Provider<SignalStatistics>((ref) {
  final state = ref.watch(generatedSignalsProvider);
  
  return SignalStatistics(
    totalSignals: state.signals.length,
    activeSignals: state.signals.where((s) => s.isValid).length,
    averageConfidence: state.signals.isEmpty 
        ? 0.0 
        : state.signals.map((s) => s.confidenceScore).reduce((a, b) => a + b) / state.signals.length,
    signalsByType: _groupSignalsByType(state.signals),
    lastGenerated: state.lastGenerated,
  );
});

// Helper function to group signals by type
Map<SignalType, int> _groupSignalsByType(List<GeneratedSignal> signals) {
  final grouped = <SignalType, int>{};
  
  for (final signal in signals) {
    grouped[signal.type] = (grouped[signal.type] ?? 0) + 1;
  }
  
  return grouped;
}

// Signal Statistics Model
class SignalStatistics {
  final int totalSignals;
  final int activeSignals;
  final double averageConfidence;
  final Map<SignalType, int> signalsByType;
  final DateTime? lastGenerated;

  SignalStatistics({
    required this.totalSignals,
    required this.activeSignals,
    required this.averageConfidence,
    required this.signalsByType,
    this.lastGenerated,
  });

  String get averageConfidenceString => '${averageConfidence.round()}%';
  
  String get lastGeneratedString {
    if (lastGenerated == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(lastGenerated!);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}