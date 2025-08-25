import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/signal_generation_provider.dart';
import '../../providers/market_data_provider.dart';
import '../../widgets/signals/signal_card_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../data/services/signal_generation_service.dart';

class SignalsListPage extends ConsumerStatefulWidget {
  const SignalsListPage({super.key});

  @override
  ConsumerState<SignalsListPage> createState() => _SignalsListPageState();
}

class _SignalsListPageState extends ConsumerState<SignalsListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Auto-generate signals on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateSignals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generateSignals() async {
    await ref.read(generatedSignalsProvider.notifier).generateSignals(
      maxSignals: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    final signalsState = ref.watch(generatedSignalsProvider);
    final signalStats = ref.watch(signalStatsProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        title: Row(
          children: [
            // Logo with gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00FF88), Color(0xFF00D4FF), Color(0xFFFF00FF)],
              ).createShader(bounds),
              child: const Text(
                'SignalPro',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),
            // Stats badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.signal_cellular_alt,
                    color: Color(0xFF00FF88),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${signalStats.activeSignals} Active',
                    style: const TextStyle(
                      color: Color(0xFF00FF88),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Refresh button
          IconButton(
            onPressed: signalsState.isLoading ? null : _generateSignals,
            icon: signalsState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF88)),
                    ),
                  )
                : const Icon(
                    Icons.refresh,
                    color: Color(0xFF00FF88),
                  ),
          ),
          // Settings button
          IconButton(
            onPressed: () {
              // Navigate to signal settings
            },
            icon: const Icon(
              Icons.tune,
              color: Colors.white,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF00FF88),
          labelColor: const Color(0xFF00FF88),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'ALL'),
            Tab(text: 'PRE-MKT'),
            Tab(text: 'EARNINGS'),
            Tab(text: 'MOMENTUM'),
            Tab(text: 'VOLUME'),
            Tab(text: 'BREAKOUT'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats header
          _buildStatsHeader(signalStats),
          // Signals content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllSignalsTab(),
                _buildSignalTypeTab(SignalType.preMarket),
                _buildSignalTypeTab(SignalType.earnings),
                _buildSignalTypeTab(SignalType.momentum),
                _buildSignalTypeTab(SignalType.volume),
                _buildSignalTypeTab(SignalType.breakout),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateSignals,
        backgroundColor: const Color(0xFF00FF88),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.auto_fix_high),
        label: const Text(
          'Generate Signals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatsHeader(SignalStatistics stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FF88).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Signals',
              '${stats.totalSignals}',
              Icons.signal_cellular_alt,
              const Color(0xFF00D4FF),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Active',
              '${stats.activeSignals}',
              Icons.trending_up,
              const Color(0xFF00FF88),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Avg Confidence',
              stats.averageConfidenceString,
              Icons.percent,
              const Color(0xFFFFD93D),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Last Update',
              stats.lastGeneratedString,
              Icons.schedule,
              const Color(0xFF95A5A6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAllSignalsTab() {
    final signalsState = ref.watch(generatedSignalsProvider);
    
    if (signalsState.isLoading && signalsState.signals.isEmpty) {
      return const Center(
        child: LoadingWidget(message: 'Generating signals...'),
      );
    }

    if (signalsState.error != null && signalsState.signals.isEmpty) {
      return Center(
        child: AppErrorWidget(
          error: signalsState.error!,
          onRetry: _generateSignals,
        ),
      );
    }

    if (signalsState.signals.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _generateSignals,
      color: const Color(0xFF00FF88),
      backgroundColor: const Color(0xFF1A1A1A),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Account for FAB
        itemCount: signalsState.signals.length,
        itemBuilder: (context, index) {
          final signal = signalsState.signals[index];
          return SignalCardWidget(
            signal: signal,
            onTap: () => _onSignalTap(signal),
            showUpgradeButton: _shouldShowUpgradeButton(signal),
            onUpgrade: () => _onUpgradeSignal(signal),
          );
        },
      ),
    );
  }

  Widget _buildSignalTypeTab(SignalType type) {
    final signalsState = ref.watch(generatedSignalsProvider);
    final typeSignals = signalsState.signals
        .where((signal) => signal.type == type && signal.isValid)
        .toList();

    if (signalsState.isLoading && typeSignals.isEmpty) {
      return const Center(
        child: LoadingWidget(message: 'Loading signals...'),
      );
    }

    if (typeSignals.isEmpty) {
      return _buildEmptyTypeState(type);
    }

    return RefreshIndicator(
      onRefresh: _generateSignals,
      color: const Color(0xFF00FF88),
      backgroundColor: const Color(0xFF1A1A1A),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Account for FAB
        itemCount: typeSignals.length,
        itemBuilder: (context, index) {
          final signal = typeSignals[index];
          return SignalCardWidget(
            signal: signal,
            onTap: () => _onSignalTap(signal),
            showUpgradeButton: _shouldShowUpgradeButton(signal),
            onUpgrade: () => _onUpgradeSignal(signal),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.signal_cellular_off,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No signals available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the generate button to create new signals',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _generateSignals,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF88),
              foregroundColor: Colors.black,
            ),
            child: const Text('Generate Signals'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTypeState(SignalType type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No ${type.displayName.toLowerCase()} signals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later or try generating new signals',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onSignalTap(GeneratedSignal signal) {
    // Navigate to signal detail page
    context.go('/signal-detail/${signal.id}');
  }

  void _onUpgradeSignal(GeneratedSignal signal) {
    // Show upgrade dialog or navigate to payment
    _showUpgradeDialog(signal);
  }

  bool _shouldShowUpgradeButton(GeneratedSignal signal) {
    // Show upgrade button for high-confidence signals or premium features
    return signal.confidenceScore >= 80.0 && signal.type == SignalType.earnings;
  }

  void _showUpgradeDialog(GeneratedSignal signal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Upgrade to Dynamic Premium',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlock detailed analysis for ${signal.symbol}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              '• Real-time entry/exit alerts',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const Text(
              '• Advanced technical analysis',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const Text(
              '• Risk management guidance',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const Text(
              '• 24/7 monitoring',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Process payment
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B59B6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade \$4.99'),
          ),
        ],
      ),
    );
  }
}