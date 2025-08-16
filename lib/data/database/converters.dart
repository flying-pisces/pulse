import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/entities/user.dart' as entities;
import '../../domain/entities/signal.dart' as entities;
import '../../domain/entities/watchlist_item.dart' as entities;
import 'database.dart';
import 'tables.dart';

class DatabaseConverters {
  static entities.User userFromTable(UserTable table) {
    return entities.User(
      id: table.id,
      email: table.email,
      firstName: table.firstName,
      lastName: table.lastName,
      profileImageUrl: table.profileImageUrl,
      createdAt: table.createdAt,
      isVerified: table.isVerified,
      subscriptionTier: _convertSubscriptionTier(table.subscriptionTier),
      subscriptionExpiresAt: table.subscriptionExpiresAt,
      authProvider: _convertAuthProvider(table.authProvider),
      providerId: table.providerId,
      providerData: table.providerData != null 
          ? jsonDecode(table.providerData!) as Map<String, dynamic>
          : null,
    );
  }

  static UsersCompanion userToCompanion(entities.User user) {
    return UsersCompanion(
      id: Value(user.id),
      email: Value(user.email),
      firstName: Value(user.firstName),
      lastName: Value(user.lastName),
      profileImageUrl: Value(user.profileImageUrl),
      createdAt: Value(user.createdAt),
      isVerified: Value(user.isVerified),
      subscriptionTier: Value(convertSubscriptionTierToDb(user.subscriptionTier)),
      subscriptionExpiresAt: Value(user.subscriptionExpiresAt),
      authProvider: Value(_convertAuthProviderToDb(user.authProvider)),
      providerId: Value(user.providerId),
      providerData: Value(user.providerData != null 
          ? jsonEncode(user.providerData!) 
          : null),
    );
  }

  static entities.Signal signalFromTable(SignalTable table) {
    return entities.Signal(
      id: table.id,
      symbol: table.symbol,
      companyName: table.companyName,
      type: _convertSignalType(table.type),
      action: _convertSignalAction(table.action),
      currentPrice: table.currentPrice,
      targetPrice: table.targetPrice,
      stopLoss: table.stopLoss,
      confidence: table.confidence,
      reasoning: table.reasoning,
      createdAt: table.createdAt,
      expiresAt: table.expiresAt,
      status: _convertSignalStatus(table.status),
      tags: (jsonDecode(table.tags) as List<dynamic>).cast<String>(),
      requiredTier: _convertSubscriptionTier(table.requiredTier),
      profitLossPercentage: table.profitLossPercentage,
      imageUrl: table.imageUrl,
    );
  }

  static SignalsCompanion signalToCompanion(entities.Signal signal) {
    return SignalsCompanion(
      id: Value(signal.id),
      symbol: Value(signal.symbol),
      companyName: Value(signal.companyName),
      type: Value(convertSignalTypeToDb(signal.type)),
      action: Value(_convertSignalActionToDb(signal.action)),
      currentPrice: Value(signal.currentPrice),
      targetPrice: Value(signal.targetPrice),
      stopLoss: Value(signal.stopLoss),
      confidence: Value(signal.confidence),
      reasoning: Value(signal.reasoning),
      createdAt: Value(signal.createdAt),
      expiresAt: Value(signal.expiresAt),
      status: Value(convertSignalStatusToDb(signal.status)),
      tags: Value(jsonEncode(signal.tags)),
      requiredTier: Value(convertSubscriptionTierToDb(signal.requiredTier)),
      profitLossPercentage: Value(signal.profitLossPercentage),
      imageUrl: Value(signal.imageUrl),
    );
  }

  static entities.WatchlistItem watchlistItemFromTable(WatchlistItemTable table) {
    return entities.WatchlistItem(
      id: table.id,
      symbol: table.symbol,
      companyName: table.companyName,
      type: _convertSignalType(table.type),
      currentPrice: table.currentPrice,
      priceChange: table.priceChange,
      priceChangePercent: table.priceChangePercent,
      addedAt: table.addedAt,
      isPriceAlertEnabled: table.isPriceAlertEnabled,
      priceAlertTarget: table.priceAlertTarget,
      notes: table.notes,
    );
  }

  static WatchlistItemsCompanion watchlistItemToCompanion(entities.WatchlistItem item) {
    return WatchlistItemsCompanion(
      id: Value(item.id),
      symbol: Value(item.symbol),
      companyName: Value(item.companyName),
      type: Value(convertSignalTypeToDb(item.type)),
      currentPrice: Value(item.currentPrice),
      priceChange: Value(item.priceChange),
      priceChangePercent: Value(item.priceChangePercent),
      addedAt: Value(item.addedAt),
      isPriceAlertEnabled: Value(item.isPriceAlertEnabled),
      priceAlertTarget: Value(item.priceAlertTarget),
      notes: Value(item.notes),
    );
  }

  // Helper conversion methods - make public for DAO access
  static entities.SubscriptionTier _convertSubscriptionTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return entities.SubscriptionTier.free;
      case SubscriptionTier.basic:
        return entities.SubscriptionTier.basic;
      case SubscriptionTier.premium:
        return entities.SubscriptionTier.premium;
      case SubscriptionTier.pro:
        return entities.SubscriptionTier.pro;
    }
  }

  static SubscriptionTier convertSubscriptionTierToDb(entities.SubscriptionTier tier) {
    switch (tier) {
      case entities.SubscriptionTier.free:
        return SubscriptionTier.free;
      case entities.SubscriptionTier.basic:
        return SubscriptionTier.basic;
      case entities.SubscriptionTier.premium:
        return SubscriptionTier.premium;
      case entities.SubscriptionTier.pro:
        return SubscriptionTier.pro;
    }
  }

  static entities.AuthProvider _convertAuthProvider(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.email:
        return entities.AuthProvider.email;
      case AuthProvider.google:
        return entities.AuthProvider.google;
      case AuthProvider.apple:
        return entities.AuthProvider.apple;
    }
  }

  static AuthProvider _convertAuthProviderToDb(entities.AuthProvider provider) {
    switch (provider) {
      case entities.AuthProvider.email:
        return AuthProvider.email;
      case entities.AuthProvider.google:
        return AuthProvider.google;
      case entities.AuthProvider.apple:
        return AuthProvider.apple;
    }
  }

  static entities.SignalType _convertSignalType(SignalType type) {
    switch (type) {
      case SignalType.stock:
        return entities.SignalType.stock;
      case SignalType.crypto:
        return entities.SignalType.crypto;
      case SignalType.forex:
        return entities.SignalType.forex;
      case SignalType.commodity:
        return entities.SignalType.commodity;
    }
  }

  static SignalType convertSignalTypeToDb(entities.SignalType type) {
    switch (type) {
      case entities.SignalType.stock:
        return SignalType.stock;
      case entities.SignalType.crypto:
        return SignalType.crypto;
      case entities.SignalType.forex:
        return SignalType.forex;
      case entities.SignalType.commodity:
        return SignalType.commodity;
    }
  }

  static entities.SignalAction _convertSignalAction(SignalAction action) {
    switch (action) {
      case SignalAction.buy:
        return entities.SignalAction.buy;
      case SignalAction.sell:
        return entities.SignalAction.sell;
      case SignalAction.hold:
        return entities.SignalAction.hold;
    }
  }

  static SignalAction _convertSignalActionToDb(entities.SignalAction action) {
    switch (action) {
      case entities.SignalAction.buy:
        return SignalAction.buy;
      case entities.SignalAction.sell:
        return SignalAction.sell;
      case entities.SignalAction.hold:
        return SignalAction.hold;
    }
  }

  static entities.SignalStatus _convertSignalStatus(SignalStatus status) {
    switch (status) {
      case SignalStatus.active:
        return entities.SignalStatus.active;
      case SignalStatus.completed:
        return entities.SignalStatus.completed;
      case SignalStatus.cancelled:
        return entities.SignalStatus.cancelled;
      case SignalStatus.expired:
        return entities.SignalStatus.expired;
    }
  }

  static SignalStatus convertSignalStatusToDb(entities.SignalStatus status) {
    switch (status) {
      case entities.SignalStatus.active:
        return SignalStatus.active;
      case entities.SignalStatus.completed:
        return SignalStatus.completed;
      case entities.SignalStatus.cancelled:
        return SignalStatus.cancelled;
      case entities.SignalStatus.expired:
        return SignalStatus.expired;
    }
  }
}