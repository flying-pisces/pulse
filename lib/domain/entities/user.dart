import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool isVerified;
  final SubscriptionTier subscriptionTier;
  final DateTime? subscriptionExpiresAt;
  final AuthProvider authProvider;
  final String? providerId;
  final Map<String, dynamic>? providerData;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    required this.createdAt,
    required this.isVerified,
    required this.subscriptionTier,
    this.subscriptionExpiresAt,
    required this.authProvider,
    this.providerId,
    this.providerData,
  });

  String get fullName => '$firstName $lastName';
  
  bool get isSubscriptionActive {
    if (subscriptionTier == SubscriptionTier.free) return true;
    return subscriptionExpiresAt?.isAfter(DateTime.now()) ?? false;
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? isVerified,
    SubscriptionTier? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    AuthProvider? authProvider,
    String? providerId,
    Map<String, dynamic>? providerData,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      authProvider: authProvider ?? this.authProvider,
      providerId: providerId ?? this.providerId,
      providerData: providerData ?? this.providerData,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        profileImageUrl,
        createdAt,
        isVerified,
        subscriptionTier,
        subscriptionExpiresAt,
        authProvider,
        providerId,
        providerData,
      ];
}

enum SubscriptionTier {
  free,
  basic,
  premium,
  pro;

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.basic:
        return 'Basic';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.pro:
        return 'Pro';
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionTier.free:
        return 0.0;
      case SubscriptionTier.basic:
        return 9.99;
      case SubscriptionTier.premium:
        return 19.99;
      case SubscriptionTier.pro:
        return 39.99;
    }
  }
}

enum AuthProvider {
  email,
  google,
  apple;

  String get displayName {
    switch (this) {
      case AuthProvider.email:
        return 'Email';
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
    }
  }

  String get iconName {
    switch (this) {
      case AuthProvider.email:
        return 'email';
      case AuthProvider.google:
        return 'google';
      case AuthProvider.apple:
        return 'apple';
    }
  }
}