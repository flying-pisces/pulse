import 'package:equatable/equatable.dart';
import 'user.dart';

class Signal extends Equatable {
  final String id;
  final String symbol;
  final String companyName;
  final SignalType type;
  final SignalAction action;
  final double currentPrice;
  final double targetPrice;
  final double stopLoss;
  final double confidence;
  final String reasoning;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final SignalStatus status;
  final List<String> tags;
  final SubscriptionTier requiredTier;
  final double? profitLossPercentage;
  final String? imageUrl;

  const Signal({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.type,
    required this.action,
    required this.currentPrice,
    required this.targetPrice,
    required this.stopLoss,
    required this.confidence,
    required this.reasoning,
    required this.createdAt,
    this.expiresAt,
    required this.status,
    required this.tags,
    required this.requiredTier,
    this.profitLossPercentage,
    this.imageUrl,
  });

  bool get isActive => status == SignalStatus.active;
  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? false;
  bool get isProfitable => (profitLossPercentage ?? 0) > 0;

  String get confidenceLabel {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.6) return 'Medium';
    return 'Low';
  }

  Signal copyWith({
    String? id,
    String? symbol,
    String? companyName,
    SignalType? type,
    SignalAction? action,
    double? currentPrice,
    double? targetPrice,
    double? stopLoss,
    double? confidence,
    String? reasoning,
    DateTime? createdAt,
    DateTime? expiresAt,
    SignalStatus? status,
    List<String>? tags,
    SubscriptionTier? requiredTier,
    double? profitLossPercentage,
    String? imageUrl,
  }) {
    return Signal(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      type: type ?? this.type,
      action: action ?? this.action,
      currentPrice: currentPrice ?? this.currentPrice,
      targetPrice: targetPrice ?? this.targetPrice,
      stopLoss: stopLoss ?? this.stopLoss,
      confidence: confidence ?? this.confidence,
      reasoning: reasoning ?? this.reasoning,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      requiredTier: requiredTier ?? this.requiredTier,
      profitLossPercentage: profitLossPercentage ?? this.profitLossPercentage,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        symbol,
        companyName,
        type,
        action,
        currentPrice,
        targetPrice,
        stopLoss,
        confidence,
        reasoning,
        createdAt,
        expiresAt,
        status,
        tags,
        requiredTier,
        profitLossPercentage,
        imageUrl,
      ];
}

enum SignalType {
  stock,
  crypto,
  forex,
  commodity;

  String get displayName {
    switch (this) {
      case SignalType.stock:
        return 'Stock';
      case SignalType.crypto:
        return 'Crypto';
      case SignalType.forex:
        return 'Forex';
      case SignalType.commodity:
        return 'Commodity';
    }
  }
}

enum SignalAction {
  buy,
  sell,
  hold;

  String get displayName {
    switch (this) {
      case SignalAction.buy:
        return 'BUY';
      case SignalAction.sell:
        return 'SELL';
      case SignalAction.hold:
        return 'HOLD';
    }
  }
}

enum SignalStatus {
  active,
  completed,
  cancelled,
  expired;

  String get displayName {
    switch (this) {
      case SignalStatus.active:
        return 'Active';
      case SignalStatus.completed:
        return 'Completed';
      case SignalStatus.cancelled:
        return 'Cancelled';
      case SignalStatus.expired:
        return 'Expired';
    }
  }
}

