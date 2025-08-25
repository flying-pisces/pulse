import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/signal_generation_provider.dart';
import '../../providers/market_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../../data/services/signal_generation_service.dart';

class SignalDetailPage extends ConsumerStatefulWidget {
  final String signalId;

  const SignalDetailPage({super.key, required this.signalId});

  @override
  ConsumerState<SignalDetailPage> createState() => _SignalDetailPageState();
}

class _SignalDetailPageState extends ConsumerState<SignalDetailPage> {
  GeneratedSignal? _signal;

  @override
  void initState() {
    super.initState();
    _loadSignal();
  }

  void _loadSignal() {
    final signalsState = ref.read(generatedSignalsProvider);
    _signal = signalsState.signals.firstWhere(
      (signal) => signal.id == widget.signalId,
      orElse: () => throw StateError('Signal not found'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signal = _signal;
    if (signal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Signal Not Found')),
        body: const Center(child: Text('Signal not found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(signal),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildMainCard(signal),
                _buildChartSection(signal),
                _buildKeyMetrics(signal),
                _buildStrategySection(signal),
                _buildTimingSection(signal),
                _buildActionButtons(signal),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(GeneratedSignal signal) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF000000),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getSignalTypeColor(signal.type),
                _getSignalTypeColor(signal.type).withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Signal type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getSignalTypeColor(signal.type),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      signal.type.displayName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Symbol and title
                  Text(
                    signal.symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    signal.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(GeneratedSignal signal) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getSignalTypeColor(signal.type).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Price and change
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${signal.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Current Price',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: signal.isPositive ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  signal.changeString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Strategy badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getSignalTypeColor(signal.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getSignalTypeColor(signal.type).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              signal.strategy,
              style: TextStyle(
                color: _getSignalTypeColor(signal.type),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(GeneratedSignal signal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Chart
          Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: signal.price * 0.02,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[800]!,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Price line
                  LineChartBarData(
                    spots: _generatePriceSpots(signal),
                    isCurved: true,
                    color: _getSignalTypeColor(signal.type),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _getSignalTypeColor(signal.type).withValues(alpha: 0.1),
                    ),
                  ),
                  // Target line
                  LineChartBarData(
                    spots: [
                      FlSpot(30, signal.targetPrice),
                      FlSpot(40, signal.targetPrice),
                    ],
                    isCurved: false,
                    color: AppColors.success,
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                  // Stop loss line
                  LineChartBarData(
                    spots: [
                      FlSpot(30, signal.stopLoss),
                      FlSpot(40, signal.stopLoss),
                    ],
                    isCurved: false,
                    color: AppColors.error,
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          // Event label
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getSignalTypeColor(signal.type),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getEventLabel(signal.type),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(GeneratedSignal signal) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              'Target',
              '\$${signal.targetPrice.toStringAsFixed(2)}',
              Icons.flag,
              AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              'Stop Loss',
              '\$${signal.stopLoss.toStringAsFixed(2)}',
              Icons.stop,
              AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              'Confidence',
              '${signal.confidenceScore.round()}%',
              Icons.verified,
              _getSignalTypeColor(signal.type),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategySection(GeneratedSignal signal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getSignalTypeColor(signal.type).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSignalIcon(signal.type),
                color: _getSignalTypeColor(signal.type),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${signal.strategy} Strategy',
                style: TextStyle(
                  color: _getSignalTypeColor(signal.type),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            signal.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: AppColors.info, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Historical win rate: ${_calculateWinRate(signal.type)}% for this strategy',
                    style: const TextStyle(
                      color: AppColors.info,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingSection(GeneratedSignal signal) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Critical Timing',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimingGrid(signal),
          const SizedBox(height: 16),
          // Countdown
          Center(
            child: Column(
              children: [
                const Text(
                  'Signal expires in',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCountdown(signal.validUntil),
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingGrid(GeneratedSignal signal) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildTimingItem('Entry', 'Market Open', AppColors.success),
        _buildTimingItem('Stop', '\$${signal.stopLoss.toStringAsFixed(2)}', AppColors.error),
        _buildTimingItem('Target 1', '\$${signal.targetPrice.toStringAsFixed(2)}', AppColors.info),
        _buildTimingItem('Target 2', '\$${(signal.targetPrice * 1.03).toStringAsFixed(2)}', AppColors.primary),
      ],
    );
  }

  Widget _buildTimingItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(GeneratedSignal signal) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main action button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _showTradeDialog(signal),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getSignalTypeColor(signal.type),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Execute Trade - ${signal.symbol}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Secondary actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addToWatchlist(signal),
                  icon: const Icon(Icons.bookmark_add, size: 18),
                  label: const Text('Watchlist'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareSignal(signal),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getSignalTypeColor(SignalType type) {
    return AppColors.getSignalTypeColor(type.name);
  }

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

  String _getEventLabel(SignalType type) {
    switch (type) {
      case SignalType.preMarket:
        return 'Pre-Market Alert';
      case SignalType.earnings:
        return 'Earnings Beat';
      case SignalType.momentum:
        return 'Strong Move';
      case SignalType.volume:
        return 'Volume Spike';
      case SignalType.breakout:
        return 'Breakout';
      case SignalType.options:
        return 'Options Flow';
      case SignalType.crypto:
        return 'Crypto Alert';
    }
  }

  int _calculateWinRate(SignalType type) {
    // Mock win rates - in real app, this would come from historical data
    switch (type) {
      case SignalType.preMarket:
        return 72;
      case SignalType.earnings:
        return 68;
      case SignalType.momentum:
        return 75;
      case SignalType.volume:
        return 65;
      case SignalType.breakout:
        return 78;
      case SignalType.options:
        return 82;
      case SignalType.crypto:
        return 58;
    }
  }

  List<FlSpot> _generatePriceSpots(GeneratedSignal signal) {
    final spots = <FlSpot>[];
    final basePrice = signal.price * 0.98;
    
    for (int i = 0; i < 30; i++) {
      final x = i.toDouble();
      final variance = (signal.change.abs() / 100) * 0.1;
      final y = basePrice + (i * variance * 0.5) + (i % 4 == 0 ? variance : 0);
      spots.add(FlSpot(x, y));
    }
    
    return spots;
  }

  String _formatCountdown(DateTime validUntil) {
    final now = DateTime.now();
    final difference = validUntil.difference(now);

    if (difference.isNegative) return '00:00:00';

    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  void _showTradeDialog(GeneratedSignal signal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Execute Trade - ${signal.symbol}',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will redirect you to your broker to execute the trade.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Open broker app or web
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getSignalTypeColor(signal.type),
              foregroundColor: Colors.black,
            ),
            child: const Text('Execute'),
          ),
        ],
      ),
    );
  }

  void _addToWatchlist(GeneratedSignal signal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${signal.symbol} added to watchlist'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _shareSignal(GeneratedSignal signal) {
    // Share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signal shared'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}