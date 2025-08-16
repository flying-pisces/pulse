import 'package:drift/drift.dart';

@DataClassName('UserTable')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get firstName => text().named('first_name')();
  TextColumn get lastName => text().named('last_name')();
  TextColumn get profileImageUrl => text().named('profile_image_url').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  BoolColumn get isVerified => boolean().named('is_verified').withDefault(const Constant(false))();
  IntColumn get subscriptionTier => intEnum<SubscriptionTier>().named('subscription_tier')();
  DateTimeColumn get subscriptionExpiresAt => dateTime().named('subscription_expires_at').nullable()();
  IntColumn get authProvider => intEnum<AuthProvider>().named('auth_provider')();
  TextColumn get providerId => text().named('provider_id').nullable()();
  TextColumn get providerData => text().named('provider_data').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SignalTable')
class Signals extends Table {
  TextColumn get id => text()();
  TextColumn get symbol => text()();
  TextColumn get companyName => text().named('company_name')();
  IntColumn get type => intEnum<SignalType>()();
  IntColumn get action => intEnum<SignalAction>()();
  RealColumn get currentPrice => real().named('current_price')();
  RealColumn get targetPrice => real().named('target_price')();
  RealColumn get stopLoss => real().named('stop_loss')();
  RealColumn get confidence => real()();
  TextColumn get reasoning => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get expiresAt => dateTime().named('expires_at').nullable()();
  IntColumn get status => intEnum<SignalStatus>()();
  TextColumn get tags => text()(); // JSON string of tags array
  IntColumn get requiredTier => intEnum<SubscriptionTier>().named('required_tier')();
  RealColumn get profitLossPercentage => real().named('profit_loss_percentage').nullable()();
  TextColumn get imageUrl => text().named('image_url').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WatchlistItemTable')
class WatchlistItems extends Table {
  TextColumn get id => text()();
  TextColumn get symbol => text()();
  TextColumn get companyName => text().named('company_name')();
  IntColumn get type => intEnum<SignalType>()();
  RealColumn get currentPrice => real().named('current_price')();
  RealColumn get priceChange => real().named('price_change')();
  RealColumn get priceChangePercent => real().named('price_change_percent')();
  DateTimeColumn get addedAt => dateTime().named('added_at')();
  BoolColumn get isPriceAlertEnabled => boolean().named('is_price_alert_enabled').withDefault(const Constant(false))();
  RealColumn get priceAlertTarget => real().named('price_alert_target').nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Enums
enum SubscriptionTier {
  free,
  basic,
  premium,
  pro;
}

enum AuthProvider {
  email,
  google,
  apple;
}

enum SignalType {
  stock,
  crypto,
  forex,
  commodity;
}

enum SignalAction {
  buy,
  sell,
  hold;
}

enum SignalStatus {
  active,
  completed,
  cancelled,
  expired;
}