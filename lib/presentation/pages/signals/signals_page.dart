import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/signal.dart';
import '../../providers/signals_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/signal_card.dart';

class SignalsPage extends ConsumerStatefulWidget {
  const SignalsPage({super.key});

  @override
  ConsumerState<SignalsPage> createState() => _SignalsPageState();
}

class _SignalsPageState extends ConsumerState<SignalsPage> {
  final ScrollController _scrollController = ScrollController();
  SignalType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial signals
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(signalsProvider.notifier).loadSignals(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent) {
      final signalsState = ref.read(signalsProvider);
      if (signalsState.hasMore && !signalsState.isLoading) {
        ref.read(signalsProvider.notifier).loadSignals();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom App Bar
          const CustomAppBar(
            title: 'Trading Signals',
            showBackButton: false,
          ),
          
          // Filter Tabs
          _buildFilterTabs(),
          
          // Signals List
          Expanded(
            child: _buildSignalsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _refreshSignals(),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('All', null),
          const SizedBox(width: 8),
          _buildFilterChip('Stocks', SignalType.stock),
          const SizedBox(width: 8),
          _buildFilterChip('Crypto', SignalType.crypto),
          const SizedBox(width: 8),
          _buildFilterChip('Forex', SignalType.forex),
          const SizedBox(width: 8),
          _buildFilterChip('Commodities', SignalType.commodity),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, SignalType? type) {
    final isSelected = _selectedFilter == type;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? type : null;
        });
      },
      backgroundColor: isSelected 
          ? AppColors.primaryColor
          : Theme.of(context).colorScheme.surfaceContainer,
      selectedColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      showCheckmark: false,
    );
  }

  Widget _buildSignalsList() {
    return Consumer(
      builder: (context, ref, child) {
        final signalsState = ref.watch(signalsProvider);
        
        if (signalsState.signals.isEmpty && signalsState.isLoading) {
          return const LoadingWidget(message: 'Loading trading signals...');
        }
        
        if (signalsState.signals.isEmpty && signalsState.error != null) {
          return CustomErrorWidget(
            message: signalsState.error!,
            onRetry: () => ref.read(signalsProvider.notifier).loadSignals(refresh: true),
          );
        }
        
        if (signalsState.signals.isEmpty) {
          return const EmptyStateWidget(
            title: 'No Signals Available',
            message: 'Check back later for new trading signals.',
            icon: Icons.signal_cellular_nodata,
          );
        }
        
        // Filter signals if needed
        final filteredSignals = _selectedFilter == null 
            ? signalsState.signals
            : signalsState.signals.where((signal) => signal.type == _selectedFilter).toList();
        
        return RefreshIndicator(
          onRefresh: _refreshSignals,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 80), // Account for FAB
            itemCount: filteredSignals.length + (signalsState.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Loading indicator at the end
              if (index >= filteredSignals.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final signal = filteredSignals[index];
              return SignalCard(
                signal: signal,
                onTap: () => _viewSignalDetails(signal),
                onWatchlistAdd: () => _addToWatchlist(signal),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _refreshSignals() async {
    await ref.read(signalsProvider.notifier).loadSignals(refresh: true);
  }

  void _viewSignalDetails(Signal signal) {
    context.push('/signals/detail/${signal.id}');
  }

  void _addToWatchlist(Signal signal) async {
    try {
      await ref.read(watchlistProvider.notifier).addToWatchlist(
        signal.symbol,
        signal.companyName,
        signal.type,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${signal.symbol} added to watchlist'),
            backgroundColor: AppColors.successColor,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () => context.go('/watchlist'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}