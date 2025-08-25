import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/services/signal_generation_service.dart';
import '../../../data/models/market_data_models.dart';
import '../../theme/app_colors.dart';

class SignalCardWidget extends StatelessWidget {
  final GeneratedSignal signal;
  final SnapshotData? marketData;
  final VoidCallback? onTap;
  final VoidCallback? onUpgrade;
  final bool showUpgradeButton;

  const SignalCardWidget({
    super.key,
    required this.signal,
    this.marketData,
    this.onTap,
    this.onUpgrade,
    this.showUpgradeButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getSignalTypeColor().withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildPriceSection(context),
              const SizedBox(height: 16),
              _buildChart(context),
              const SizedBox(height: 16),
              _buildKeyStats(context),
              const SizedBox(height: 16),
              _buildStrategy(context),
              const SizedBox(height: 16),
              _buildActionSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Signal Type Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getSignalTypeColor(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            signal.type.displayName.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Spacer(),
        // Time Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getSignalTypeColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _formatTimeAgo(signal.generatedAt),
            style: theme.textTheme.labelSmall?.copyWith(
              color: _getSignalTypeColor(),
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Symbol and Strategy
        Row(
          children: [
            Text(
              signal.symbol,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getSignalTypeColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                signal.strategy.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getSignalTypeColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Company Name or Title
        Text(
          signal.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        // Price and Change
        Row(
          children: [
            Text(
              '\$${signal.price.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: signal.isPositive ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                signal.changeString,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: _getSignalTypeColor().withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Chart
          Padding(
            padding: const EdgeInsets.all(10),
            child: LineChart(
              _buildChartData(),
            ),
          ),
          // Event Label
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getSignalTypeColor().withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getEventLabel(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Market Open Line (for pre-market signals)
          if (signal.type == SignalType.preMarket)
            Positioned.fill(
              child: CustomPaint(
                painter: MarketOpenLinePainter(_getSignalTypeColor()),
              ),
            ),
        ],
      ),
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        // Historical data line
        LineChartBarData(
          spots: _generateHistoricalSpots(),
          isCurved: true,
          color: _getSignalTypeColor().withValues(alpha: 0.8),
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
        // Projected/target line
        LineChartBarData(
          spots: _generateProjectedSpots(),
          isCurved: true,
          color: _getSignalTypeColor().withValues(alpha: 0.6),
          barWidth: 2,
          dashArray: [5, 5],
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: _getSignalTypeColor().withValues(alpha: 0.1),
          ),
        ),
        // Stop loss line
        LineChartBarData(
          spots: _generateStopLossSpots(),
          isCurved: false,
          color: AppColors.error.withValues(alpha: 0.6),
          barWidth: 1,
          dashArray: [3, 3],
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }

  List<FlSpot> _generateHistoricalSpots() {
    final spots = <FlSpot>[];
    final basePrice = signal.price * 0.95; // Start slightly lower
    
    for (int i = 0; i < 20; i++) {
      final x = i.toDouble();
      final variance = (signal.change.abs() / 100) * 0.3; // Based on signal change
      final y = basePrice + (i * variance) + (i % 3 == 0 ? variance * 0.5 : 0);
      spots.add(FlSpot(x, y));
    }
    
    return spots;
  }

  List<FlSpot> _generateProjectedSpots() {
    final spots = <FlSpot>[];
    final startPrice = signal.price;
    final targetPrice = signal.targetPrice;
    
    for (int i = 20; i < 40; i++) {
      final x = i.toDouble();
      final progress = (i - 20) / 20;
      final y = startPrice + (targetPrice - startPrice) * progress;
      spots.add(FlSpot(x, y));
    }
    
    return spots;
  }

  List<FlSpot> _generateStopLossSpots() {
    final spots = <FlSpot>[];
    final stopLoss = signal.stopLoss;
    
    for (int i = 20; i < 40; i++) {
      spots.add(FlSpot(i.toDouble(), stopLoss));
    }
    
    return spots;
  }

  Widget _buildKeyStats(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: _buildStat(
            context,
            'Target',
            '\$${signal.targetPrice.toStringAsFixed(2)}',
            AppColors.success,
          ),
        ),
        Expanded(
          child: _buildStat(
            context,
            'Stop Loss',
            '\$${signal.stopLoss.toStringAsFixed(2)}',
            AppColors.error,
          ),
        ),
        Expanded(
          child: _buildStat(
            context,
            'Confidence',
            signal.confidenceString,
            _getSignalTypeColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 11,
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategy(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getSignalTypeColor().withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSignalTypeColor().withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStrategyIcon(),
                color: _getSignalTypeColor(),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                signal.strategy,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: _getSignalTypeColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            signal.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          if (signal.validUntil.isAfter(DateTime.now())) ...[
            const SizedBox(height: 8),
            Text(
              'Valid until ${_formatValidUntil(signal.validUntil)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Confidence indicator
        Expanded(
          child: LinearProgressIndicator(
            value: signal.confidenceScore / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_getSignalTypeColor()),
            minHeight: 6,
          ),
        ),
        const SizedBox(width: 16),
        // Upgrade button (for dynamic signals)
        if (showUpgradeButton && onUpgrade != null)
          ElevatedButton.icon(
            onPressed: onUpgrade,
            icon: const Icon(Icons.upgrade, size: 16),
            label: const Text('Upgrade \$4.99'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.premium,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
        else
          // Action button
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getSignalTypeColor(),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('View Details'),
          ),
      ],
    );
  }

  Color _getSignalTypeColor() {
    switch (signal.type) {
      case SignalType.preMarket:
        return AppColors.warning;
      case SignalType.earnings:
        return AppColors.info;
      case SignalType.momentum:
        return AppColors.success;
      case SignalType.volume:
        return AppColors.primary;
      case SignalType.breakout:
        return AppColors.secondary;
      case SignalType.options:
        return AppColors.accent;
      case SignalType.crypto:
        return AppColors.crypto;
    }
  }

  IconData _getStrategyIcon() {
    switch (signal.type) {
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

  String _getEventLabel() {
    switch (signal.type) {
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'NOW';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  String _formatValidUntil(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }
}

// Custom painter for market open line
class MarketOpenLinePainter extends CustomPainter {
  final Color color;

  MarketOpenLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw vertical dashed line at market open (roughly middle)
    final x = size.width * 0.5;
    const dashHeight = 5.0;
    const dashSpace = 3.0;

    double startY = 10;
    while (startY < size.height - 10) {
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }

    // Add text label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Market Open',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x + 5, 5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}