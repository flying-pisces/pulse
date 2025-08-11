import 'package:flutter/material.dart';
import '../../../domain/entities/signal.dart';
import '../../../core/theme/app_colors.dart';

class SignalCard extends StatelessWidget {
  final Signal signal;
  final VoidCallback? onTap;
  final VoidCallback? onWatchlistAdd;

  const SignalCard({
    super.key,
    required this.signal,
    this.onTap,
    this.onWatchlistAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Symbol and Company
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              signal.symbol,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildSignalTypeBadge(context),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          signal.companyName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action Badge
                  _buildActionBadge(context),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Price Info Row
              Row(
                children: [
                  Expanded(
                    child: _buildPriceInfo(context, 'Current', signal.currentPrice),
                  ),
                  Expanded(
                    child: _buildPriceInfo(context, 'Target', signal.targetPrice),
                  ),
                  Expanded(
                    child: _buildPriceInfo(context, 'Stop Loss', signal.stopLoss),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Confidence and P&L
              Row(
                children: [
                  _buildConfidenceBadge(context),
                  const SizedBox(width: 8),
                  if (signal.profitLossPercentage != null)
                    _buildProfitLossBadge(context),
                  const Spacer(),
                  Text(
                    _formatTimeAgo(signal.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Tags
              if (signal.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: signal.tags.map((tag) => _buildTag(context, tag)).toList(),
                ),
                const SizedBox(height: 12),
              ],
              
              // Reasoning
              Text(
                signal.reasoning,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Action Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onWatchlistAdd,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: const Text('Add to Watchlist'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignalTypeBadge(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    
    switch (signal.type) {
      case SignalType.stock:
        color = AppColors.primaryColor;
        break;
      case SignalType.crypto:
        color = AppColors.warningColor;
        break;
      case SignalType.forex:
        color = AppColors.secondaryColor;
        break;
      case SignalType.commodity:
        color = AppColors.infoColor;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        signal.type.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionBadge(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    
    switch (signal.action) {
      case SignalAction.buy:
        color = AppColors.bullColor;
        break;
      case SignalAction.sell:
        color = AppColors.bearColor;
        break;
      case SignalAction.hold:
        color = AppColors.neutralColor;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        signal.action.displayName,
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriceInfo(BuildContext context, String label, double price) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceBadge(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    
    if (signal.confidence >= 0.8) {
      color = AppColors.bullColor;
    } else if (signal.confidence >= 0.6) {
      color = AppColors.warningColor;
    } else {
      color = AppColors.bearColor;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            signal.confidence >= 0.8 ? Icons.trending_up :
            signal.confidence >= 0.6 ? Icons.trending_flat :
            Icons.trending_down,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${(signal.confidence * 100).toInt()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitLossBadge(BuildContext context) {
    if (signal.profitLossPercentage == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final isProfit = signal.profitLossPercentage! > 0;
    final color = isProfit ? AppColors.bullColor : AppColors.bearColor;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${isProfit ? '+' : ''}${signal.profitLossPercentage!.toStringAsFixed(1)}%',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String tag) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: theme.textTheme.labelSmall,
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}