import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import '../datasources/pocketbase_service.dart';
import '../models/market_data_models.dart';
import '../../domain/entities/signal.dart';

/// Repository for signal operations using PocketBase
class PocketBaseSignalRepository {
  final PocketBaseService _pocketBase;

  PocketBaseSignalRepository(this._pocketBase);

  /// Get signals with subscription tier filtering
  Future<List<Signal>> getSignals({
    int page = 1,
    int perPage = 20,
    SignalType? type,
    SignalStatus? status,
    String? symbol,
    String sort = '-created',
  }) async {
    try {
      // Build filter based on parameters
      List<String> filters = [];
      
      if (type != null) {
        filters.add('type = "${type.name}"');
      }
      
      if (status != null) {
        filters.add('status = "${status.name}"');
      }
      
      if (symbol != null && symbol.isNotEmpty) {
        filters.add('symbol ~ "$symbol"');
      }

      final filterString = filters.isNotEmpty ? filters.join(' && ') : null;

      final result = await _pocketBase.getSignals(
        page: page,
        perPage: perPage,
        filter: filterString,
        sort: sort,
      );

      return result.items.map((record) => _mapRecordToSignal(record)).toList();
    } catch (e) {
      throw Exception('Failed to fetch signals: $e');
    }
  }

  /// Get single signal by ID
  Future<Signal?> getSignal(String signalId) async {
    try {
      final record = await _pocketBase.getSignal(signalId);
      if (record == null) return null;
      
      return _mapRecordToSignal(record);
    } catch (e) {
      throw Exception('Failed to fetch signal: $e');
    }
  }

  /// Get signals by symbol
  Future<List<Signal>> getSignalsBySymbol(String symbol) async {
    return getSignals(symbol: symbol);
  }

  /// Get active signals
  Future<List<Signal>> getActiveSignals() async {
    return getSignals(status: SignalStatus.active);
  }

  /// Get signals by type
  Future<List<Signal>> getSignalsByType(SignalType type) async {
    return getSignals(type: type);
  }

  /// Subscribe to real-time signal updates
  Stream<Signal> subscribeToSignals({
    SignalType? type,
    SignalStatus? status,
  }) {
    try {
      List<String> filters = [];
      
      if (type != null) {
        filters.add('type = "${type.name}"');
      }
      
      if (status != null) {
        filters.add('status = "${status.name}"');
      }

      final filterString = filters.isNotEmpty ? filters.join(' && ') : null;

      return _pocketBase.subscribeToSignals(filter: filterString)
          .map((record) => _mapRecordToSignal(record));
    } catch (e) {
      throw Exception('Failed to subscribe to signals: $e');
    }
  }

  /// Create new signal (admin only)
  Future<Signal> createSignal(Signal signal) async {
    try {
      final data = _mapSignalToRecord(signal);
      final record = await _pocketBase.createSignal(data);
      return _mapRecordToSignal(record);
    } catch (e) {
      throw Exception('Failed to create signal: $e');
    }
  }

  /// Update signal (admin only)
  Future<Signal> updateSignal(String signalId, Signal signal) async {
    try {
      final data = _mapSignalToRecord(signal);
      final record = await _pocketBase.updateSignal(signalId, data);
      return _mapRecordToSignal(record);
    } catch (e) {
      throw Exception('Failed to update signal: $e');
    }
  }

  /// Map PocketBase record to Signal entity
  Signal _mapRecordToSignal(RecordModel record) {
    return Signal(
      id: record.id,
      symbol: record.data['symbol'] ?? '',
      companyName: record.data['companyName'] ?? '',
      type: SignalType.values.firstWhere(
        (e) => e.name == record.data['type'],
        orElse: () => SignalType.stock,
      ),
      action: SignalAction.values.firstWhere(
        (e) => e.name == record.data['action'],
        orElse: () => SignalAction.buy,
      ),
      currentPrice: (record.data['currentPrice'] ?? 0).toDouble(),
      targetPrice: (record.data['targetPrice'] ?? 0).toDouble(),
      stopLoss: (record.data['stopLoss'] ?? 0).toDouble(),
      confidence: (record.data['confidence'] ?? 0).toDouble(),
      reasoning: record.data['reasoning'] ?? '',
      createdAt: DateTime.parse(record.created),
      expiresAt: record.data['expiresAt'] != null 
          ? DateTime.parse(record.data['expiresAt'])
          : null,
      status: SignalStatus.values.firstWhere(
        (e) => e.name == record.data['status'],
        orElse: () => SignalStatus.active,
      ),
      tags: _parseTagsFromJson(record.data['tags']),
      requiredTier: SubscriptionTier.values.firstWhere(
        (e) => e.name == record.data['requiredTier'],
        orElse: () => SubscriptionTier.free,
      ),
      profitLossPercentage: record.data['profitLossPercentage']?.toDouble(),
      imageUrl: record.data['imageUrl'],
    );
  }

  /// Map Signal entity to PocketBase record data
  Map<String, dynamic> _mapSignalToRecord(Signal signal) {
    return {
      'symbol': signal.symbol,
      'companyName': signal.companyName,
      'type': signal.type.name,
      'action': signal.action.name,
      'currentPrice': signal.currentPrice,
      'targetPrice': signal.targetPrice,
      'stopLoss': signal.stopLoss,
      'confidence': signal.confidence,
      'reasoning': signal.reasoning,
      'expiresAt': signal.expiresAt?.toIso8601String(),
      'status': signal.status.name,
      'tags': signal.tags,
      'requiredTier': signal.requiredTier.name,
      'profitLossPercentage': signal.profitLossPercentage,
      'imageUrl': signal.imageUrl,
    };
  }

  /// Parse tags from JSON
  List<String> _parseTagsFromJson(dynamic tags) {
    if (tags == null) return [];
    if (tags is List) return tags.cast<String>();
    if (tags is String) {
      try {
        final decoded = json.decode(tags);
        if (decoded is List) return decoded.cast<String>();
      } catch (e) {
        // If it's not valid JSON, treat as single tag
        return [tags];
      }
    }
    return [];
  }
}

/// Provider for PocketBase signal repository
final pocketBaseSignalRepositoryProvider = Provider<PocketBaseSignalRepository>((ref) {
  final pocketBase = ref.watch(pocketBaseServiceProvider);
  return PocketBaseSignalRepository(pocketBase);
});

/// Provider for signals list
final signalsProvider = FutureProvider.family<List<Signal>, SignalsFilter>((ref, filter) async {
  final repository = ref.watch(pocketBaseSignalRepositoryProvider);
  
  return repository.getSignals(
    page: filter.page,
    perPage: filter.perPage,
    type: filter.type,
    status: filter.status,
    symbol: filter.symbol,
    sort: filter.sort,
  );
});

/// Provider for single signal
final signalProvider = FutureProvider.family<Signal?, String>((ref, signalId) async {
  final repository = ref.watch(pocketBaseSignalRepositoryProvider);
  return repository.getSignal(signalId);
});

/// Provider for active signals
final activeSignalsProvider = FutureProvider<List<Signal>>((ref) async {
  final repository = ref.watch(pocketBaseSignalRepositoryProvider);
  return repository.getActiveSignals();
});

/// Provider for signals by symbol
final signalsBySymbolProvider = FutureProvider.family<List<Signal>, String>((ref, symbol) async {
  final repository = ref.watch(pocketBaseSignalRepositoryProvider);
  return repository.getSignalsBySymbol(symbol);
});

/// Provider for real-time signals stream
final signalsStreamProvider = StreamProvider.family<Signal, SignalsStreamFilter>((ref, filter) {
  final repository = ref.watch(pocketBaseSignalRepositoryProvider);
  
  return repository.subscribeToSignals(
    type: filter.type,
    status: filter.status,
  );
});

/// Filter class for signals queries
class SignalsFilter {
  final int page;
  final int perPage;
  final SignalType? type;
  final SignalStatus? status;
  final String? symbol;
  final String sort;

  const SignalsFilter({
    this.page = 1,
    this.perPage = 20,
    this.type,
    this.status,
    this.symbol,
    this.sort = '-created',
  });

  SignalsFilter copyWith({
    int? page,
    int? perPage,
    SignalType? type,
    SignalStatus? status,
    String? symbol,
    String? sort,
  }) {
    return SignalsFilter(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      type: type ?? this.type,
      status: status ?? this.status,
      symbol: symbol ?? this.symbol,
      sort: sort ?? this.sort,
    );
  }
}

/// Stream filter for real-time signals
class SignalsStreamFilter {
  final SignalType? type;
  final SignalStatus? status;

  const SignalsStreamFilter({
    this.type,
    this.status,
  });
}