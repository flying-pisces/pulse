import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/market_data_provider.dart';
import '../providers/signal_generation_provider.dart';
import '../../core/constants/env_config.dart';
import '../../data/models/market_data_models.dart';
import '../../data/services/signal_generation_service.dart';

class MarketDataTestPage extends ConsumerStatefulWidget {
  const MarketDataTestPage({super.key});

  @override
  ConsumerState<MarketDataTestPage> createState() => _MarketDataTestPageState();
}

class _MarketDataTestPageState extends ConsumerState<MarketDataTestPage> {
  List<String> testSymbols = ['AAPL', 'GOOGL', 'MSFT', 'TSLA'];
  
  @override
  Widget build(BuildContext context) {
    final marketDataState = ref.watch(marketDataProvider);
    final connectionStatus = ref.watch(marketDataConnectionProvider);
    final accountInfo = ref.watch(accountInfoProvider);
    final signalsState = ref.watch(generatedSignalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Data Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(marketDataConnectionProvider);
              ref.invalidate(accountInfoProvider);
              ref.read(marketDataProvider.notifier).refreshData(testSymbols);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configuration Status
            _buildConfigurationCard(),
            const SizedBox(height: 16),
            
            // Connection Status
            _buildConnectionCard(connectionStatus),
            const SizedBox(height: 16),
            
            // Account Information
            _buildAccountCard(accountInfo),
            const SizedBox(height: 16),
            
            // Market Data Testing
            _buildMarketDataCard(marketDataState),
            const SizedBox(height: 16),
            
            // Generated Signals
            _buildSignalsCard(signalsState),
            const SizedBox(height: 16),
            
            // Test Actions
            _buildTestActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationCard() {
    final config = EnvConfig.configSummary;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...config.entries.map((entry) {
              final isOk = entry.value is bool ? entry.value : entry.value != null;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isOk ? Icons.check_circle : Icons.error,
                      color: isOk ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(
                          color: isOk ? Colors.black87 : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard(AsyncValue<bool> connectionStatus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API Connection Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            connectionStatus.when(
              data: (isConnected) => Row(
                children: [
                  Icon(
                    isConnected ? Icons.wifi : Icons.wifi_off,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'Connected to Alpaca API' : 'Failed to connect to Alpaca API',
                    style: TextStyle(
                      color: isConnected ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              loading: () => const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Testing connection...'),
                ],
              ),
              error: (error, stack) => Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connection Error: $error',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(AsyncValue<AccountResponse?> accountInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            accountInfo.when(
              data: (account) {
                if (account == null) {
                  return const Text(
                    'Using mock data (no account info available)',
                    style: TextStyle(color: Colors.orange),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account #: ${account.accountNumber}'),
                    Text('Status: ${account.status}'),
                    Text('Cash: \$${account.cashAmount.toStringAsFixed(2)}'),
                    Text('Portfolio Value: \$${account.portfolioAmount.toStringAsFixed(2)}'),
                    Text('Can Trade: ${account.canTrade ? 'Yes' : 'No'}'),
                  ],
                );
              },
              loading: () => const Text('Loading account information...'),
              error: (error, stack) => Text(
                'Account Error: $error',
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketDataCard(MarketDataState marketDataState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Data Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            if (marketDataState.isLoading)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Loading market data...'),
                ],
              )
            else if (marketDataState.error != null)
              Text(
                'Error: ${marketDataState.error}',
                style: TextStyle(color: Colors.red[700]),
              )
            else if (marketDataState.snapshots.isEmpty)
              const Text('No market data loaded yet')
            else
              Column(
                children: testSymbols.map((symbol) {
                  final snapshot = marketDataState.snapshots[symbol];
                  if (snapshot == null) {
                    return ListTile(
                      leading: const Icon(Icons.error, color: Colors.red),
                      title: Text(symbol),
                      subtitle: const Text('No data available'),
                    );
                  }
                  
                  final price = snapshot.latestTrade?.price ?? 
                              snapshot.dailyBar?.close ?? 0.0;
                  final change = snapshot.dailyChangePercent ?? 0.0;
                  
                  return ListTile(
                    leading: Icon(
                      snapshot.isDailyPositive ? Icons.trending_up : Icons.trending_down,
                      color: snapshot.isDailyPositive ? Colors.green : Colors.red,
                    ),
                    title: Text(symbol),
                    subtitle: Text('\$${price.toStringAsFixed(2)}'),
                    trailing: Text(
                      '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: change >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalsCard(GeneratedSignalsState signalsState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Generated Signals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (signalsState.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    '${signalsState.signals.length} signals',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (signalsState.isLoading && signalsState.signals.isEmpty)
              const Text('Generating signals...')
            else if (signalsState.error != null)
              Text(
                'Error: ${signalsState.error}',
                style: TextStyle(color: Colors.red[700]),
              )
            else if (signalsState.signals.isEmpty)
              const Text('No signals generated yet')
            else
              Column(
                children: signalsState.signals.take(3).map((signal) {
                  return ListTile(
                    leading: Icon(
                      _getSignalIcon(signal.type),
                      color: _getSignalColor(signal.type),
                    ),
                    title: Text(signal.title),
                    subtitle: Text('${signal.symbol} • ${signal.confidenceString} confidence'),
                    trailing: Text(
                      signal.changeString,
                      style: TextStyle(
                        color: signal.isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
            if (signalsState.signals.length > 3)
              Text(
                '... and ${signalsState.signals.length - 3} more signals',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(generatedSignalsProvider.notifier).generateSignals(
                      maxSignals: 10,
                    );
                  },
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Generate Signals'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(marketDataProvider.notifier).loadSnapshots(testSymbols);
                  },
                  child: const Text('Load Snapshots'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(marketDataProvider.notifier).loadNews(
                      symbols: testSymbols,
                      limit: 5,
                    );
                  },
                  child: const Text('Load News'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final repository = ref.read(marketDataRepositoryProvider);
                    repository.getHistoricalBars(
                      symbol: 'AAPL',
                      timeframe: '1Day',
                      start: DateTime.now().subtract(const Duration(days: 30)),
                      end: DateTime.now(),
                      limit: 30,
                    ).then((bars) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Loaded ${bars.length} historical bars for AAPL'),
                        ),
                      );
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error loading historical data: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                  },
                  child: const Text('Test Historical Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for signal display
  IconData _getSignalIcon(SignalType type) {
    switch (type) {
      case SignalType.preMarket:
        return Icons.wb_sunny;
      case SignalType.earnings:
        return Icons.assessment;
      case SignalType.momentum:
        return Icons.trending_up;
      case SignalType.volume:
        return Icons.volume_up;
      case SignalType.breakout:
        return Icons.open_in_full;
      case SignalType.options:
        return Icons.swap_calls;
      case SignalType.crypto:
        return Icons.currency_bitcoin;
    }
  }

  Color _getSignalColor(SignalType type) {
    switch (type) {
      case SignalType.preMarket:
        return Colors.orange;
      case SignalType.earnings:
        return Colors.blue;
      case SignalType.momentum:
        return Colors.green;
      case SignalType.volume:
        return Colors.purple;
      case SignalType.breakout:
        return Colors.red;
      case SignalType.options:
        return Colors.indigo;
      case SignalType.crypto:
        return Colors.amber;
    }
  }
}