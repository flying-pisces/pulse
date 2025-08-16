import 'package:drift/drift.dart';
import '../../../domain/entities/signal.dart' as entities;
import '../../../domain/entities/user.dart' as entities;
import '../database.dart';
import '../tables.dart';
import '../converters.dart';

part 'signal_dao.g.dart';

@DriftAccessor(tables: [Signals])
class SignalDao extends DatabaseAccessor<AppDatabase> with _$SignalDaoMixin {
  SignalDao(AppDatabase db) : super(db);

  Future<List<entities.Signal>> getAllSignals() async {
    final query = select(signals)..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    final results = await query.get();
    return results.map(DatabaseConverters.signalFromTable).toList();
  }

  Future<List<entities.Signal>> getActiveSignals() async {
    final query = select(signals)
      ..where((s) => s.status.equals(SignalStatus.active.index))
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    final results = await query.get();
    return results.map(DatabaseConverters.signalFromTable).toList();
  }

  Future<List<entities.Signal>> getSignalsByType(entities.SignalType type) async {
    final dbType = DatabaseConverters.convertSignalTypeToDb(type);
    final query = select(signals)
      ..where((s) => s.type.equals(dbType.index))
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    final results = await query.get();
    return results.map(DatabaseConverters.signalFromTable).toList();
  }

  Future<List<entities.Signal>> getSignalsBySubscriptionTier(entities.SubscriptionTier tier) async {
    final dbTier = DatabaseConverters.convertSubscriptionTierToDb(tier);
    final query = select(signals)
      ..where((s) => s.requiredTier.isSmallerOrEqualValue(dbTier.index))
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    final results = await query.get();
    return results.map(DatabaseConverters.signalFromTable).toList();
  }

  Future<entities.Signal?> getSignalById(String id) async {
    final query = select(signals)..where((s) => s.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? DatabaseConverters.signalFromTable(result) : null;
  }

  Future<entities.Signal> createSignal(entities.Signal signal) async {
    final companion = DatabaseConverters.signalToCompanion(signal);
    await into(signals).insert(companion);
    return signal;
  }

  Future<entities.Signal> updateSignal(entities.Signal signal) async {
    final companion = DatabaseConverters.signalToCompanion(signal);
    await update(signals).replace(companion);
    return signal;
  }

  Future<void> deleteSignal(String id) async {
    await (delete(signals)..where((s) => s.id.equals(id))).go();
  }

  Future<void> deleteAllSignals() async {
    await delete(signals).go();
  }

  Future<List<entities.Signal>> searchSignals(String query) async {
    final searchQuery = '%${query.toLowerCase()}%';
    final results = await customSelect(
      '''
      SELECT * FROM signals 
      WHERE LOWER(symbol) LIKE ? 
         OR LOWER(company_name) LIKE ? 
         OR LOWER(reasoning) LIKE ?
      ORDER BY created_at DESC
      ''',
      variables: [Variable.withString(searchQuery), Variable.withString(searchQuery), Variable.withString(searchQuery)],
      readsFrom: {signals},
    ).get();

    return results.map((row) {
      final table = signals.map(row.data);
      return DatabaseConverters.signalFromTable(table);
    }).toList();
  }

  Stream<List<entities.Signal>> watchActiveSignals() {
    final query = select(signals)
      ..where((s) => s.status.equals(SignalStatus.active.index))
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    
    return query.watch().map(
      (results) => results.map(DatabaseConverters.signalFromTable).toList(),
    );
  }

  Stream<entities.Signal?> watchSignalById(String id) {
    final query = select(signals)..where((s) => s.id.equals(id));
    return query.watchSingleOrNull().map(
      (result) => result != null ? DatabaseConverters.signalFromTable(result) : null,
    );
  }

  Future<int> getSignalsCount() async {
    final count = await customSelect('SELECT COUNT(*) as count FROM signals').getSingle();
    return count.data['count'] as int;
  }

  Future<List<entities.Signal>> getPaginatedSignals({
    int limit = 20,
    int offset = 0,
    entities.SignalStatus? status,
  }) async {
    var query = select(signals);
    
    if (status != null) {
      final dbStatus = DatabaseConverters.convertSignalStatusToDb(status);
      query = query..where((s) => s.status.equals(dbStatus.index));
    }
    
    query = query
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
      ..limit(limit, offset: offset);
    
    final results = await query.get();
    return results.map(DatabaseConverters.signalFromTable).toList();
  }

  Future<void> markExpiredSignals() async {
    await customUpdate(
      '''
      UPDATE signals 
      SET status = ? 
      WHERE expires_at < ? AND status = ?
      ''',
      variables: [
        Variable.withInt(SignalStatus.expired.index),
        Variable.withDateTime(DateTime.now()),
        Variable.withInt(SignalStatus.active.index),
      ],
      updates: {signals},
    );
  }
}