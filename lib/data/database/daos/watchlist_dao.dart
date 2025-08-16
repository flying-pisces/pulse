import 'package:drift/drift.dart';
import '../../../domain/entities/watchlist_item.dart' as entities;
import '../../../domain/entities/signal.dart' as entities;
import '../database.dart';
import '../tables.dart';
import '../converters.dart';

part 'watchlist_dao.g.dart';

@DriftAccessor(tables: [WatchlistItems])
class WatchlistDao extends DatabaseAccessor<AppDatabase> with _$WatchlistDaoMixin {
  WatchlistDao(AppDatabase db) : super(db);

  Future<List<entities.WatchlistItem>> getAllWatchlistItems() async {
    final query = select(watchlistItems)..orderBy([(w) => OrderingTerm.desc(w.addedAt)]);
    final results = await query.get();
    return results.map(DatabaseConverters.watchlistItemFromTable).toList();
  }

  Future<List<entities.WatchlistItem>> getWatchlistItemsByType(entities.SignalType type) async {
    final dbType = DatabaseConverters.convertSignalTypeToDb(type);
    final query = select(watchlistItems)
      ..where((w) => w.type.equals(dbType.index))
      ..orderBy([(w) => OrderingTerm.desc(w.addedAt)]);
    final results = await query.get();
    return results.map(DatabaseConverters.watchlistItemFromTable).toList();
  }

  Future<entities.WatchlistItem?> getWatchlistItemById(String id) async {
    final query = select(watchlistItems)..where((w) => w.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? DatabaseConverters.watchlistItemFromTable(result) : null;
  }

  Future<entities.WatchlistItem?> getWatchlistItemBySymbol(String symbol) async {
    final query = select(watchlistItems)..where((w) => w.symbol.equals(symbol));
    final result = await query.getSingleOrNull();
    return result != null ? DatabaseConverters.watchlistItemFromTable(result) : null;
  }

  Future<entities.WatchlistItem> addToWatchlist(entities.WatchlistItem item) async {
    final companion = DatabaseConverters.watchlistItemToCompanion(item);
    await into(watchlistItems).insert(companion);
    return item;
  }

  Future<entities.WatchlistItem> updateWatchlistItem(entities.WatchlistItem item) async {
    final companion = DatabaseConverters.watchlistItemToCompanion(item);
    await update(watchlistItems).replace(companion);
    return item;
  }

  Future<void> removeFromWatchlist(String id) async {
    await (delete(watchlistItems)..where((w) => w.id.equals(id))).go();
  }

  Future<void> removeFromWatchlistBySymbol(String symbol) async {
    await (delete(watchlistItems)..where((w) => w.symbol.equals(symbol))).go();
  }

  Future<void> clearWatchlist() async {
    await delete(watchlistItems).go();
  }

  Future<bool> isInWatchlist(String symbol) async {
    final query = select(watchlistItems)..where((w) => w.symbol.equals(symbol));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  Future<List<entities.WatchlistItem>> searchWatchlist(String query) async {
    final searchQuery = '%${query.toLowerCase()}%';
    final results = await customSelect(
      '''
      SELECT * FROM watchlist_items 
      WHERE LOWER(symbol) LIKE ? 
         OR LOWER(company_name) LIKE ?
         OR LOWER(notes) LIKE ?
      ORDER BY added_at DESC
      ''',
      variables: [
        Variable.withString(searchQuery), 
        Variable.withString(searchQuery),
        Variable.withString(searchQuery)
      ],
      readsFrom: {watchlistItems},
    ).get();

    return results.map((row) {
      final table = watchlistItems.map(row.data);
      return DatabaseConverters.watchlistItemFromTable(table);
    }).toList();
  }

  Stream<List<entities.WatchlistItem>> watchWatchlist() {
    final query = select(watchlistItems)..orderBy([(w) => OrderingTerm.desc(w.addedAt)]);
    return query.watch().map(
      (results) => results.map(DatabaseConverters.watchlistItemFromTable).toList(),
    );
  }

  Stream<entities.WatchlistItem?> watchWatchlistItemById(String id) {
    final query = select(watchlistItems)..where((w) => w.id.equals(id));
    return query.watchSingleOrNull().map(
      (result) => result != null ? DatabaseConverters.watchlistItemFromTable(result) : null,
    );
  }

  Future<int> getWatchlistCount() async {
    final count = await customSelect('SELECT COUNT(*) as count FROM watchlist_items').getSingle();
    return count.data['count'] as int;
  }

  Future<List<entities.WatchlistItem>> getWatchlistItemsWithAlerts() async {
    final query = select(watchlistItems)
      ..where((w) => w.isPriceAlertEnabled.equals(true) & w.priceAlertTarget.isNotNull())
      ..orderBy([(w) => OrderingTerm.desc(w.addedAt)]);
    final results = await query.get();
    return results.map(DatabaseConverters.watchlistItemFromTable).toList();
  }

  Future<List<entities.WatchlistItem>> getTriggeredAlerts() async {
    final results = await customSelect(
      '''
      SELECT * FROM watchlist_items 
      WHERE is_price_alert_enabled = 1 
        AND price_alert_target IS NOT NULL 
        AND current_price >= price_alert_target
      ORDER BY added_at DESC
      ''',
      readsFrom: {watchlistItems},
    ).get();

    return results.map((row) {
      final table = watchlistItems.map(row.data);
      return DatabaseConverters.watchlistItemFromTable(table);
    }).toList();
  }

  Future<void> updatePrices(List<Map<String, dynamic>> priceUpdates) async {
    await batch((batch) {
      for (final update in priceUpdates) {
        final symbol = update['symbol'] as String;
        final currentPrice = update['currentPrice'] as double;
        final priceChange = update['priceChange'] as double;
        final priceChangePercent = update['priceChangePercent'] as double;

        batch.update(
          watchlistItems,
          WatchlistItemsCompanion(
            currentPrice: Value(currentPrice),
            priceChange: Value(priceChange),
            priceChangePercent: Value(priceChangePercent),
          ),
          where: (w) => w.symbol.equals(symbol),
        );
      }
    });
  }

  Future<List<entities.WatchlistItem>> getPaginatedWatchlist({
    int limit = 20,
    int offset = 0,
    entities.SignalType? type,
  }) async {
    var query = select(watchlistItems);
    
    if (type != null) {
      final dbType = DatabaseConverters.convertSignalTypeToDb(type);
      query = query..where((w) => w.type.equals(dbType.index));
    }
    
    query = query
      ..orderBy([(w) => OrderingTerm.desc(w.addedAt)])
      ..limit(limit, offset: offset);
    
    final results = await query.get();
    return results.map(DatabaseConverters.watchlistItemFromTable).toList();
  }
}