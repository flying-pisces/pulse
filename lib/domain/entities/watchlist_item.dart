import 'package:equatable/equatable.dart';
import 'signal.dart';

class WatchlistItem extends Equatable {
  final String id;
  final String symbol;
  final String companyName;
  final SignalType type;
  final double currentPrice;
  final double priceChange;
  final double priceChangePercent;
  final DateTime addedAt;
  final bool isPriceAlertEnabled;
  final double? priceAlertTarget;
  final String? notes;

  const WatchlistItem({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.type,
    required this.currentPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.addedAt,
    required this.isPriceAlertEnabled,
    this.priceAlertTarget,
    this.notes,
  });

  bool get isPriceUp => priceChange > 0;
  bool get isPriceDown => priceChange < 0;
  
  bool get shouldTriggerAlert {
    if (!isPriceAlertEnabled || priceAlertTarget == null) return false;
    return currentPrice >= priceAlertTarget!;
  }

  WatchlistItem copyWith({
    String? id,
    String? symbol,
    String? companyName,
    SignalType? type,
    double? currentPrice,
    double? priceChange,
    double? priceChangePercent,
    DateTime? addedAt,
    bool? isPriceAlertEnabled,
    double? priceAlertTarget,
    String? notes,
  }) {
    return WatchlistItem(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      type: type ?? this.type,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange: priceChange ?? this.priceChange,
      priceChangePercent: priceChangePercent ?? this.priceChangePercent,
      addedAt: addedAt ?? this.addedAt,
      isPriceAlertEnabled: isPriceAlertEnabled ?? this.isPriceAlertEnabled,
      priceAlertTarget: priceAlertTarget ?? this.priceAlertTarget,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        symbol,
        companyName,
        type,
        currentPrice,
        priceChange,
        priceChangePercent,
        addedAt,
        isPriceAlertEnabled,
        priceAlertTarget,
        notes,
      ];
}