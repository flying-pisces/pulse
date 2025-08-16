import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/signal.dart';
import '../../domain/entities/user.dart';
import '../datasources/local_database_service.dart';

class LocalSignalRepository {
  final LocalDatabaseService _databaseService;

  LocalSignalRepository(this._databaseService);

  Future<List<Signal>> getAllSignals() async {
    return await _databaseService.getAllSignals();
  }

  Future<List<Signal>> getActiveSignals() async {
    return await _databaseService.getActiveSignals();
  }

  Future<List<Signal>> getSignalsByType(SignalType type) async {
    return await _databaseService.getSignalsByType(type);
  }

  Future<List<Signal>> getSignalsForUser(SubscriptionTier userTier) async {
    return await _databaseService.getSignalsBySubscriptionTier(userTier);
  }

  Future<Signal?> getSignalById(String id) async {
    return await _databaseService.getSignalById(id);
  }

  Future<Signal> saveSignal(Signal signal) async {
    final existingSignal = await _databaseService.getSignalById(signal.id);
    if (existingSignal != null) {
      return await _databaseService.updateSignal(signal);
    } else {
      return await _databaseService.createSignal(signal);
    }
  }

  Future<void> deleteSignal(String id) async {
    await _databaseService.deleteSignal(id);
  }

  Future<List<Signal>> searchSignals(String query) async {
    return await _databaseService.searchSignals(query);
  }

  Stream<List<Signal>> watchActiveSignals() {
    return _databaseService.watchActiveSignals();
  }

  Future<List<Signal>> getPaginatedSignals({
    int page = 0,
    int limit = 20,
    SignalStatus? status,
  }) async {
    final offset = page * limit;
    return await _databaseService.getPaginatedSignals(
      limit: limit,
      offset: offset,
      status: status,
    );
  }

  Future<void> markExpiredSignals() async {
    await _databaseService.markExpiredSignals();
  }

  Future<int> getSignalsCount() async {
    return await _databaseService.getSignalsCount();
  }

  Future<void> batchSaveSignals(List<Signal> signals) async {
    await _databaseService.batchInsertSignals(signals);
  }

  Future<void> clearAllSignals() async {
    await _databaseService.deleteAllSignals();
  }
}

final localSignalRepositoryProvider = Provider<LocalSignalRepository>((ref) {
  final databaseService = ref.watch(localDatabaseServiceProvider);
  return LocalSignalRepository(databaseService);
});