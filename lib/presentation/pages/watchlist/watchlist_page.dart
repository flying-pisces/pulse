import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/watchlist_item.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class WatchlistPage extends ConsumerStatefulWidget {
  const WatchlistPage({super.key});

  @override
  ConsumerState<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends ConsumerState<WatchlistPage> {
  @override
  void initState() {
    super.initState();
    // Load watchlist on page init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(watchlistProvider.notifier).loadWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom App Bar
          const CustomAppBar(
            title: 'Watchlist',
            showBackButton: false,
          ),
          
          // Stats Header
          _buildStatsHeader(),
          
          // Watchlist Items
          Expanded(
            child: _buildWatchlistContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddToWatchlistDialog,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Consumer(
      builder: (context, ref, child) {
        final stats = ref.watch(watchlistStatsProvider);
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildStatItem('Total', stats['total'].toString(), Icons.bookmark),
              const SizedBox(width: 24),
              _buildStatItem('Up', stats['up'].toString(), Icons.trending_up, 
                color: AppColors.bullColor),
              const SizedBox(width: 24),
              _buildStatItem('Down', stats['down'].toString(), Icons.trending_down, 
                color: AppColors.bearColor),
              const SizedBox(width: 24),
              _buildStatItem('Alerts', stats['alerts'].toString(), Icons.notifications),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color ?? Colors.white.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistContent() {
    return Consumer(
      builder: (context, ref, child) {
        final watchlistState = ref.watch(watchlistProvider);
        
        if (watchlistState.isLoading && watchlistState.items.isEmpty) {
          return const LoadingWidget(message: 'Loading watchlist...');
        }
        
        if (watchlistState.error != null) {
          return CustomErrorWidget(
            message: watchlistState.error!,
            onRetry: () => ref.read(watchlistProvider.notifier).loadWatchlist(),
          );
        }
        
        if (watchlistState.items.isEmpty) {
          return EmptyStateWidget(
            title: 'Your Watchlist is Empty',
            message: 'Add stocks and crypto to track their performance.',
            icon: Icons.bookmark_border,
            action: ElevatedButton.icon(
              onPressed: _showAddToWatchlistDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add First Item'),
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: _refreshWatchlist,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Account for FAB
            itemCount: watchlistState.items.length,
            itemBuilder: (context, index) {
              final item = watchlistState.items[index];
              return _buildWatchlistItem(item);
            },
          ),
        );
      },
    );
  }

  Widget _buildWatchlistItem(WatchlistItem item) {
    final isPositive = item.isPriceUp;
    final color = isPositive ? AppColors.bullColor : AppColors.bearColor;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _showItemDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Symbol and company
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.symbol,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildTypeChip(item.type),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.companyName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Price info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${item.currentPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive ? Icons.trending_up : Icons.trending_down,
                              size: 14,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${isPositive ? '+' : ''}${item.priceChangePercent.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleAction(value, item),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'alert',
                        child: Row(
                          children: [
                            Icon(Icons.notifications_outlined),
                            SizedBox(width: 8),
                            Text('Set Alert'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'notes',
                        child: Row(
                          children: [
                            Icon(Icons.note_outlined),
                            SizedBox(width: 8),
                            Text('Add Notes'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Remove', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Alert indicator
              if (item.isPriceAlertEnabled) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warningColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        size: 16,
                        color: AppColors.warningColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Alert set for \$${item.priceAlertTarget?.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.warningColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Notes
              if (item.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.notes!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(type) {
    Color color;
    switch (type.toString()) {
      case 'SignalType.stock':
        color = AppColors.primaryColor;
        break;
      case 'SignalType.crypto':
        color = AppColors.warningColor;
        break;
      case 'SignalType.forex':
        color = AppColors.secondaryColor;
        break;
      default:
        color = AppColors.infoColor;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        type.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _refreshWatchlist() async {
    await ref.read(watchlistProvider.notifier).loadWatchlist();
  }

  void _handleAction(String action, WatchlistItem item) {
    switch (action) {
      case 'alert':
        _showPriceAlertDialog(item);
        break;
      case 'notes':
        _showNotesDialog(item);
        break;
      case 'remove':
        _confirmRemoveItem(item);
        break;
    }
  }

  void _showItemDetails(WatchlistItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildItemDetailsSheet(item),
    );
  }

  Widget _buildItemDetailsSheet(WatchlistItem item) {
    final isPositive = item.isPriceUp;
    final color = isPositive ? AppColors.bullColor : AppColors.bearColor;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  item.symbol,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.companyName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${item.currentPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositive ? '+' : ''}${item.priceChangePercent.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Price Alert'),
                  subtitle: Text(item.isPriceAlertEnabled 
                      ? 'Alert at \$${item.priceAlertTarget?.toStringAsFixed(2)}'
                      : 'No alert set'),
                  onTap: () {
                    Navigator.pop(context);
                    _showPriceAlertDialog(item);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.note_outlined),
                  title: const Text('Notes'),
                  subtitle: Text(item.notes?.isNotEmpty == true 
                      ? item.notes! 
                      : 'No notes added'),
                  onTap: () {
                    Navigator.pop(context);
                    _showNotesDialog(item);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  title: Text('Remove from Watchlist', 
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmRemoveItem(item);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToWatchlistDialog() {
    // Implement add to watchlist dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add to watchlist feature coming soon!')),
    );
  }

  void _showPriceAlertDialog(WatchlistItem item) {
    final controller = TextEditingController(
      text: item.priceAlertTarget?.toString() ?? '',
    );
    bool enabled = item.isPriceAlertEnabled;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Price Alert for ${item.symbol}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Enable Alert'),
                value: enabled,
                onChanged: (value) => setState(() => enabled = value),
              ),
              if (enabled) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target Price',
                    prefixText: '\$',
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final targetPrice = enabled ? double.tryParse(controller.text) : null;
                ref.read(watchlistProvider.notifier).updatePriceAlert(
                  item.id,
                  enabled,
                  targetPrice,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotesDialog(WatchlistItem item) {
    final controller = TextEditingController(text: item.notes ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notes for ${item.symbol}'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Add your notes',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update notes - would need to add this to the provider
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveItem(WatchlistItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Watchlist'),
        content: Text('Remove ${item.symbol} from your watchlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(watchlistProvider.notifier).removeFromWatchlist(item.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}