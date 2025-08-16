import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:logger/logger.dart';
import '../lib/data/database/database.dart';
import '../lib/data/database/tables.dart';
import '../lib/core/constants/env_config.dart';

/// Migration script to transfer data from local SQLite to PocketBase
class PocketBaseMigration {
  late final AppDatabase _localDb;
  late final PocketBase _pb;
  final Logger _logger = Logger();
  
  PocketBaseMigration() {
    // Initialize local database
    _localDb = AppDatabase.withExecutor(
      NativeDatabase.memory() // Use in-memory for migration
    );
    
    // Initialize PocketBase
    _pb = PocketBase(EnvConfig.pocketbaseUrl);
  }

  /// Run the complete migration process
  Future<void> migrate({
    String? sqliteDbPath,
    bool dryRun = false,
    bool skipUsers = false,
    bool skipSignals = false,
    bool skipWatchlist = false,
  }) async {
    try {
      _logger.i('Starting PocketBase migration...');
      
      if (dryRun) {
        _logger.w('Running in DRY RUN mode - no data will be written to PocketBase');
      }
      
      // Check PocketBase connection
      await _checkPocketBaseConnection();
      
      // Load SQLite database if path provided
      if (sqliteDbPath != null) {
        await _loadSqliteDatabase(sqliteDbPath);
      }
      
      // Run migrations in order
      if (!skipUsers) {
        await _migrateUsers(dryRun: dryRun);
      }
      
      if (!skipSignals) {
        await _migrateSignals(dryRun: dryRun);
      }
      
      if (!skipWatchlist) {
        await _migrateWatchlistItems(dryRun: dryRun);
      }
      
      _logger.i('Migration completed successfully!');
      
    } catch (e) {
      _logger.e('Migration failed: $e');
      rethrow;
    } finally {
      await _localDb.close();
    }
  }

  /// Check PocketBase connection and health
  Future<void> _checkPocketBaseConnection() async {
    try {
      final health = await _pb.health.check();
      if (health.code != 200) {
        throw Exception('PocketBase health check failed: ${health.message}');
      }
      _logger.i('PocketBase connection successful');
    } catch (e) {
      throw Exception('Failed to connect to PocketBase: $e');
    }
  }

  /// Load SQLite database from file
  Future<void> _loadSqliteDatabase(String dbPath) async {
    if (!File(dbPath).existsSync()) {
      throw Exception('SQLite database file not found: $dbPath');
    }
    
    _logger.i('Loading SQLite database from: $dbPath');
    // Note: For actual file loading, you'd need to create a new database instance
    // with the file path instead of in-memory database
  }

  /// Migrate users from SQLite to PocketBase
  Future<void> _migrateUsers({bool dryRun = false}) async {
    try {
      _logger.i('Migrating users...');
      
      // Get all users from local database
      final users = await _localDb.userDao.getAllUsers();
      _logger.i('Found ${users.length} users to migrate');
      
      for (final user in users) {
        try {
          final userData = {
            'id': user.id,
            'email': user.email,
            'firstName': user.firstName,
            'lastName': user.lastName,
            'profileImageUrl': user.profileImageUrl,
            'isVerified': user.isVerified,
            'subscriptionTier': user.subscriptionTier.name,
            'subscriptionExpiresAt': user.subscriptionExpiresAt?.toIso8601String(),
            'authProvider': user.authProvider.name,
            'providerId': user.providerId,
            'providerData': user.providerData,
          };
          
          if (dryRun) {
            _logger.i('Would migrate user: ${user.email}');
            _logger.d('User data: ${json.encode(userData)}');
          } else {
            // Create user in PocketBase
            await _pb.collection('users').create(body: userData);
            _logger.i('Migrated user: ${user.email}');
          }
          
        } catch (e) {
          _logger.e('Failed to migrate user ${user.email}: $e');
          if (!dryRun) {
            // Continue with other users even if one fails
            continue;
          }
        }
      }
      
      _logger.i('Users migration completed');
    } catch (e) {
      _logger.e('Users migration failed: $e');
      rethrow;
    }
  }

  /// Migrate signals from SQLite to PocketBase
  Future<void> _migrateSignals({bool dryRun = false}) async {
    try {
      _logger.i('Migrating signals...');
      
      // Get all signals from local database
      final signals = await _localDb.signalDao.getAllSignals();
      _logger.i('Found ${signals.length} signals to migrate');
      
      for (final signal in signals) {
        try {
          final signalData = {
            'id': signal.id,
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
            'tags': signal.tags, // Already JSON string
            'requiredTier': signal.requiredTier.name,
            'profitLossPercentage': signal.profitLossPercentage,
            'imageUrl': signal.imageUrl,
          };
          
          if (dryRun) {
            _logger.i('Would migrate signal: ${signal.symbol}');
            _logger.d('Signal data: ${json.encode(signalData)}');
          } else {
            // Create signal in PocketBase
            await _pb.collection('signals').create(body: signalData);
            _logger.i('Migrated signal: ${signal.symbol}');
          }
          
        } catch (e) {
          _logger.e('Failed to migrate signal ${signal.symbol}: $e');
          if (!dryRun) {
            continue;
          }
        }
      }
      
      _logger.i('Signals migration completed');
    } catch (e) {
      _logger.e('Signals migration failed: $e');
      rethrow;
    }
  }

  /// Migrate watchlist items from SQLite to PocketBase
  Future<void> _migrateWatchlistItems({bool dryRun = false}) async {
    try {
      _logger.i('Migrating watchlist items...');
      
      // Get all watchlist items from local database
      final watchlistItems = await _localDb.watchlistDao.getAllWatchlistItems();
      _logger.i('Found ${watchlistItems.length} watchlist items to migrate');
      
      for (final item in watchlistItems) {
        try {
          final watchlistData = {
            'id': item.id,
            'userId': 'temp-user-id', // This would need to be mapped from actual user migration
            'symbol': item.symbol,
            'companyName': item.companyName,
            'type': item.type.name,
            'currentPrice': item.currentPrice,
            'priceChange': item.priceChange,
            'priceChangePercent': item.priceChangePercent,
            'addedAt': item.addedAt.toIso8601String(),
            'isPriceAlertEnabled': item.isPriceAlertEnabled,
            'priceAlertTarget': item.priceAlertTarget,
            'notes': item.notes,
          };
          
          if (dryRun) {
            _logger.i('Would migrate watchlist item: ${item.symbol}');
            _logger.d('Watchlist data: ${json.encode(watchlistData)}');
          } else {
            // Create watchlist item in PocketBase
            await _pb.collection('watchlistItems').create(body: watchlistData);
            _logger.i('Migrated watchlist item: ${item.symbol}');
          }
          
        } catch (e) {
          _logger.e('Failed to migrate watchlist item ${item.symbol}: $e');
          if (!dryRun) {
            continue;
          }
        }
      }
      
      _logger.i('Watchlist items migration completed');
    } catch (e) {
      _logger.e('Watchlist items migration failed: $e');
      rethrow;
    }
  }

  /// Generate migration report
  Future<Map<String, dynamic>> generateMigrationReport() async {
    try {
      final users = await _localDb.userDao.getAllUsers();
      final signals = await _localDb.signalDao.getAllSignals();
      final watchlistItems = await _localDb.watchlistDao.getAllWatchlistItems();
      
      return {
        'source': 'SQLite',
        'destination': 'PocketBase',
        'timestamp': DateTime.now().toIso8601String(),
        'counts': {
          'users': users.length,
          'signals': signals.length,
          'watchlistItems': watchlistItems.length,
        },
        'details': {
          'users': users.map((u) => {
            'id': u.id,
            'email': u.email,
            'subscriptionTier': u.subscriptionTier.name,
          }).toList(),
          'signals': signals.map((s) => {
            'id': s.id,
            'symbol': s.symbol,
            'type': s.type.name,
            'status': s.status.name,
          }).toList(),
          'watchlistItems': watchlistItems.map((w) => {
            'id': w.id,
            'symbol': w.symbol,
            'type': w.type.name,
          }).toList(),
        }
      };
    } catch (e) {
      _logger.e('Failed to generate migration report: $e');
      rethrow;
    }
  }

  /// Verify migration by comparing counts
  Future<bool> verifyMigration() async {
    try {
      _logger.i('Verifying migration...');
      
      // Get local counts
      final localUsers = await _localDb.userDao.getAllUsers();
      final localSignals = await _localDb.signalDao.getAllSignals();
      final localWatchlistItems = await _localDb.watchlistDao.getAllWatchlistItems();
      
      // Get PocketBase counts
      final pbUsers = await _pb.collection('users').getList(page: 1, perPage: 1);
      final pbSignals = await _pb.collection('signals').getList(page: 1, perPage: 1);
      final pbWatchlistItems = await _pb.collection('watchlistItems').getList(page: 1, perPage: 1);
      
      final verification = {
        'users': {
          'local': localUsers.length,
          'pocketbase': pbUsers.totalItems,
          'match': localUsers.length == pbUsers.totalItems,
        },
        'signals': {
          'local': localSignals.length,
          'pocketbase': pbSignals.totalItems,
          'match': localSignals.length == pbSignals.totalItems,
        },
        'watchlistItems': {
          'local': localWatchlistItems.length,
          'pocketbase': pbWatchlistItems.totalItems,
          'match': localWatchlistItems.length == pbWatchlistItems.totalItems,
        },
      };
      
      _logger.i('Migration verification:');
      _logger.i('Users: Local ${verification['users']['local']} vs PocketBase ${verification['users']['pocketbase']} - ${verification['users']['match'] ? 'MATCH' : 'MISMATCH'}');
      _logger.i('Signals: Local ${verification['signals']['local']} vs PocketBase ${verification['signals']['pocketbase']} - ${verification['signals']['match'] ? 'MATCH' : 'MISMATCH'}');
      _logger.i('Watchlist: Local ${verification['watchlistItems']['local']} vs PocketBase ${verification['watchlistItems']['pocketbase']} - ${verification['watchlistItems']['match'] ? 'MATCH' : 'MISMATCH'}');
      
      final allMatch = verification['users']['match'] && 
                      verification['signals']['match'] && 
                      verification['watchlistItems']['match'];
      
      if (allMatch) {
        _logger.i('Migration verification PASSED');
      } else {
        _logger.w('Migration verification FAILED - some counts do not match');
      }
      
      return allMatch;
    } catch (e) {
      _logger.e('Migration verification failed: $e');
      return false;
    }
  }
}

/// CLI interface for migration script
Future<void> main(List<String> args) async {
  final migration = PocketBaseMigration();
  
  try {
    // Parse command line arguments
    bool dryRun = args.contains('--dry-run');
    bool skipUsers = args.contains('--skip-users');
    bool skipSignals = args.contains('--skip-signals');
    bool skipWatchlist = args.contains('--skip-watchlist');
    bool verify = args.contains('--verify');
    bool report = args.contains('--report');
    
    String? dbPath;
    final dbPathIndex = args.indexOf('--db-path');
    if (dbPathIndex != -1 && dbPathIndex + 1 < args.length) {
      dbPath = args[dbPathIndex + 1];
    }
    
    if (report) {
      print('Generating migration report...');
      final reportData = await migration.generateMigrationReport();
      print(json.encode(reportData));
      return;
    }
    
    if (verify) {
      print('Verifying migration...');
      final isValid = await migration.verifyMigration();
      exit(isValid ? 0 : 1);
    }
    
    // Run migration
    await migration.migrate(
      sqliteDbPath: dbPath,
      dryRun: dryRun,
      skipUsers: skipUsers,
      skipSignals: skipSignals,
      skipWatchlist: skipWatchlist,
    );
    
    print('Migration completed successfully!');
    
  } catch (e) {
    print('Migration failed: $e');
    exit(1);
  }
}

/// Usage instructions
void printUsage() {
  print('''
Usage: dart migrate_to_pocketbase.dart [options]

Options:
  --dry-run           Run in dry run mode (no data written)
  --db-path <path>    Path to SQLite database file
  --skip-users        Skip users migration
  --skip-signals      Skip signals migration
  --skip-watchlist    Skip watchlist migration
  --verify            Verify migration by comparing counts
  --report            Generate migration report
  --help              Show this help message

Examples:
  dart migrate_to_pocketbase.dart --dry-run
  dart migrate_to_pocketbase.dart --db-path /path/to/pulse.sqlite
  dart migrate_to_pocketbase.dart --verify
  dart migrate_to_pocketbase.dart --report
''');
}