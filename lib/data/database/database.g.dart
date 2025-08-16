// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileImageUrlMeta =
      const VerificationMeta('profileImageUrl');
  @override
  late final GeneratedColumn<String> profileImageUrl = GeneratedColumn<String>(
      'profile_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isVerifiedMeta =
      const VerificationMeta('isVerified');
  @override
  late final GeneratedColumn<bool> isVerified = GeneratedColumn<bool>(
      'is_verified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_verified" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  late final GeneratedColumnWithTypeConverter<SubscriptionTier, int>
      subscriptionTier = GeneratedColumn<int>(
              'subscription_tier', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<SubscriptionTier>(
              $UsersTable.$convertersubscriptionTier);
  static const VerificationMeta _subscriptionExpiresAtMeta =
      const VerificationMeta('subscriptionExpiresAt');
  @override
  late final GeneratedColumn<DateTime> subscriptionExpiresAt =
      GeneratedColumn<DateTime>('subscription_expires_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<AuthProvider, int> authProvider =
      GeneratedColumn<int>('auth_provider', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<AuthProvider>($UsersTable.$converterauthProvider);
  static const VerificationMeta _providerIdMeta =
      const VerificationMeta('providerId');
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
      'provider_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _providerDataMeta =
      const VerificationMeta('providerData');
  @override
  late final GeneratedColumn<String> providerData = GeneratedColumn<String>(
      'provider_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
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
        providerData
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('profile_image_url')) {
      context.handle(
          _profileImageUrlMeta,
          profileImageUrl.isAcceptableOrUnknown(
              data['profile_image_url']!, _profileImageUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_verified')) {
      context.handle(
          _isVerifiedMeta,
          isVerified.isAcceptableOrUnknown(
              data['is_verified']!, _isVerifiedMeta));
    }
    if (data.containsKey('subscription_expires_at')) {
      context.handle(
          _subscriptionExpiresAtMeta,
          subscriptionExpiresAt.isAcceptableOrUnknown(
              data['subscription_expires_at']!, _subscriptionExpiresAtMeta));
    }
    if (data.containsKey('provider_id')) {
      context.handle(
          _providerIdMeta,
          providerId.isAcceptableOrUnknown(
              data['provider_id']!, _providerIdMeta));
    }
    if (data.containsKey('provider_data')) {
      context.handle(
          _providerDataMeta,
          providerData.isAcceptableOrUnknown(
              data['provider_data']!, _providerDataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name'])!,
      profileImageUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}profile_image_url']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isVerified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_verified'])!,
      subscriptionTier: $UsersTable.$convertersubscriptionTier.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}subscription_tier'])!),
      subscriptionExpiresAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}subscription_expires_at']),
      authProvider: $UsersTable.$converterauthProvider.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}auth_provider'])!),
      providerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_id']),
      providerData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_data']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SubscriptionTier, int, int>
      $convertersubscriptionTier =
      const EnumIndexConverter<SubscriptionTier>(SubscriptionTier.values);
  static JsonTypeConverter2<AuthProvider, int, int> $converterauthProvider =
      const EnumIndexConverter<AuthProvider>(AuthProvider.values);
}

class UserTable extends DataClass implements Insertable<UserTable> {
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
  final String? providerData;
  const UserTable(
      {required this.id,
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
      this.providerData});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || profileImageUrl != null) {
      map['profile_image_url'] = Variable<String>(profileImageUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_verified'] = Variable<bool>(isVerified);
    {
      map['subscription_tier'] = Variable<int>(
          $UsersTable.$convertersubscriptionTier.toSql(subscriptionTier));
    }
    if (!nullToAbsent || subscriptionExpiresAt != null) {
      map['subscription_expires_at'] =
          Variable<DateTime>(subscriptionExpiresAt);
    }
    {
      map['auth_provider'] =
          Variable<int>($UsersTable.$converterauthProvider.toSql(authProvider));
    }
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    if (!nullToAbsent || providerData != null) {
      map['provider_data'] = Variable<String>(providerData);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      firstName: Value(firstName),
      lastName: Value(lastName),
      profileImageUrl: profileImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(profileImageUrl),
      createdAt: Value(createdAt),
      isVerified: Value(isVerified),
      subscriptionTier: Value(subscriptionTier),
      subscriptionExpiresAt: subscriptionExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionExpiresAt),
      authProvider: Value(authProvider),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      providerData: providerData == null && nullToAbsent
          ? const Value.absent()
          : Value(providerData),
    );
  }

  factory UserTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTable(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      profileImageUrl: serializer.fromJson<String?>(json['profileImageUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
      subscriptionTier: $UsersTable.$convertersubscriptionTier
          .fromJson(serializer.fromJson<int>(json['subscriptionTier'])),
      subscriptionExpiresAt:
          serializer.fromJson<DateTime?>(json['subscriptionExpiresAt']),
      authProvider: $UsersTable.$converterauthProvider
          .fromJson(serializer.fromJson<int>(json['authProvider'])),
      providerId: serializer.fromJson<String?>(json['providerId']),
      providerData: serializer.fromJson<String?>(json['providerData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'profileImageUrl': serializer.toJson<String?>(profileImageUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isVerified': serializer.toJson<bool>(isVerified),
      'subscriptionTier': serializer.toJson<int>(
          $UsersTable.$convertersubscriptionTier.toJson(subscriptionTier)),
      'subscriptionExpiresAt':
          serializer.toJson<DateTime?>(subscriptionExpiresAt),
      'authProvider': serializer
          .toJson<int>($UsersTable.$converterauthProvider.toJson(authProvider)),
      'providerId': serializer.toJson<String?>(providerId),
      'providerData': serializer.toJson<String?>(providerData),
    };
  }

  UserTable copyWith(
          {String? id,
          String? email,
          String? firstName,
          String? lastName,
          Value<String?> profileImageUrl = const Value.absent(),
          DateTime? createdAt,
          bool? isVerified,
          SubscriptionTier? subscriptionTier,
          Value<DateTime?> subscriptionExpiresAt = const Value.absent(),
          AuthProvider? authProvider,
          Value<String?> providerId = const Value.absent(),
          Value<String?> providerData = const Value.absent()}) =>
      UserTable(
        id: id ?? this.id,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        profileImageUrl: profileImageUrl.present
            ? profileImageUrl.value
            : this.profileImageUrl,
        createdAt: createdAt ?? this.createdAt,
        isVerified: isVerified ?? this.isVerified,
        subscriptionTier: subscriptionTier ?? this.subscriptionTier,
        subscriptionExpiresAt: subscriptionExpiresAt.present
            ? subscriptionExpiresAt.value
            : this.subscriptionExpiresAt,
        authProvider: authProvider ?? this.authProvider,
        providerId: providerId.present ? providerId.value : this.providerId,
        providerData:
            providerData.present ? providerData.value : this.providerData,
      );
  UserTable copyWithCompanion(UsersCompanion data) {
    return UserTable(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      profileImageUrl: data.profileImageUrl.present
          ? data.profileImageUrl.value
          : this.profileImageUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isVerified:
          data.isVerified.present ? data.isVerified.value : this.isVerified,
      subscriptionTier: data.subscriptionTier.present
          ? data.subscriptionTier.value
          : this.subscriptionTier,
      subscriptionExpiresAt: data.subscriptionExpiresAt.present
          ? data.subscriptionExpiresAt.value
          : this.subscriptionExpiresAt,
      authProvider: data.authProvider.present
          ? data.authProvider.value
          : this.authProvider,
      providerId:
          data.providerId.present ? data.providerId.value : this.providerId,
      providerData: data.providerData.present
          ? data.providerData.value
          : this.providerData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserTable(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('profileImageUrl: $profileImageUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('isVerified: $isVerified, ')
          ..write('subscriptionTier: $subscriptionTier, ')
          ..write('subscriptionExpiresAt: $subscriptionExpiresAt, ')
          ..write('authProvider: $authProvider, ')
          ..write('providerId: $providerId, ')
          ..write('providerData: $providerData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      providerData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserTable &&
          other.id == this.id &&
          other.email == this.email &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.profileImageUrl == this.profileImageUrl &&
          other.createdAt == this.createdAt &&
          other.isVerified == this.isVerified &&
          other.subscriptionTier == this.subscriptionTier &&
          other.subscriptionExpiresAt == this.subscriptionExpiresAt &&
          other.authProvider == this.authProvider &&
          other.providerId == this.providerId &&
          other.providerData == this.providerData);
}

class UsersCompanion extends UpdateCompanion<UserTable> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String?> profileImageUrl;
  final Value<DateTime> createdAt;
  final Value<bool> isVerified;
  final Value<SubscriptionTier> subscriptionTier;
  final Value<DateTime?> subscriptionExpiresAt;
  final Value<AuthProvider> authProvider;
  final Value<String?> providerId;
  final Value<String?> providerData;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.profileImageUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.subscriptionTier = const Value.absent(),
    this.subscriptionExpiresAt = const Value.absent(),
    this.authProvider = const Value.absent(),
    this.providerId = const Value.absent(),
    this.providerData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    this.profileImageUrl = const Value.absent(),
    required DateTime createdAt,
    this.isVerified = const Value.absent(),
    required SubscriptionTier subscriptionTier,
    this.subscriptionExpiresAt = const Value.absent(),
    required AuthProvider authProvider,
    this.providerId = const Value.absent(),
    this.providerData = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        firstName = Value(firstName),
        lastName = Value(lastName),
        createdAt = Value(createdAt),
        subscriptionTier = Value(subscriptionTier),
        authProvider = Value(authProvider);
  static Insertable<UserTable> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? profileImageUrl,
    Expression<DateTime>? createdAt,
    Expression<bool>? isVerified,
    Expression<int>? subscriptionTier,
    Expression<DateTime>? subscriptionExpiresAt,
    Expression<int>? authProvider,
    Expression<String>? providerId,
    Expression<String>? providerData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (isVerified != null) 'is_verified': isVerified,
      if (subscriptionTier != null) 'subscription_tier': subscriptionTier,
      if (subscriptionExpiresAt != null)
        'subscription_expires_at': subscriptionExpiresAt,
      if (authProvider != null) 'auth_provider': authProvider,
      if (providerId != null) 'provider_id': providerId,
      if (providerData != null) 'provider_data': providerData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String>? firstName,
      Value<String>? lastName,
      Value<String?>? profileImageUrl,
      Value<DateTime>? createdAt,
      Value<bool>? isVerified,
      Value<SubscriptionTier>? subscriptionTier,
      Value<DateTime?>? subscriptionExpiresAt,
      Value<AuthProvider>? authProvider,
      Value<String?>? providerId,
      Value<String?>? providerData,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      authProvider: authProvider ?? this.authProvider,
      providerId: providerId ?? this.providerId,
      providerData: providerData ?? this.providerData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (profileImageUrl.present) {
      map['profile_image_url'] = Variable<String>(profileImageUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<bool>(isVerified.value);
    }
    if (subscriptionTier.present) {
      map['subscription_tier'] = Variable<int>(
          $UsersTable.$convertersubscriptionTier.toSql(subscriptionTier.value));
    }
    if (subscriptionExpiresAt.present) {
      map['subscription_expires_at'] =
          Variable<DateTime>(subscriptionExpiresAt.value);
    }
    if (authProvider.present) {
      map['auth_provider'] = Variable<int>(
          $UsersTable.$converterauthProvider.toSql(authProvider.value));
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (providerData.present) {
      map['provider_data'] = Variable<String>(providerData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('profileImageUrl: $profileImageUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('isVerified: $isVerified, ')
          ..write('subscriptionTier: $subscriptionTier, ')
          ..write('subscriptionExpiresAt: $subscriptionExpiresAt, ')
          ..write('authProvider: $authProvider, ')
          ..write('providerId: $providerId, ')
          ..write('providerData: $providerData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SignalsTable extends Signals with TableInfo<$SignalsTable, SignalTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _companyNameMeta =
      const VerificationMeta('companyName');
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
      'company_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<SignalType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<SignalType>($SignalsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<SignalAction, int> action =
      GeneratedColumn<int>('action', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<SignalAction>($SignalsTable.$converteraction);
  static const VerificationMeta _currentPriceMeta =
      const VerificationMeta('currentPrice');
  @override
  late final GeneratedColumn<double> currentPrice = GeneratedColumn<double>(
      'current_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _targetPriceMeta =
      const VerificationMeta('targetPrice');
  @override
  late final GeneratedColumn<double> targetPrice = GeneratedColumn<double>(
      'target_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _stopLossMeta =
      const VerificationMeta('stopLoss');
  @override
  late final GeneratedColumn<double> stopLoss = GeneratedColumn<double>(
      'stop_loss', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _reasoningMeta =
      const VerificationMeta('reasoning');
  @override
  late final GeneratedColumn<String> reasoning = GeneratedColumn<String>(
      'reasoning', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<SignalStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<SignalStatus>($SignalsTable.$converterstatus);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<SubscriptionTier, int>
      requiredTier = GeneratedColumn<int>('required_tier', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<SubscriptionTier>(
              $SignalsTable.$converterrequiredTier);
  static const VerificationMeta _profitLossPercentageMeta =
      const VerificationMeta('profitLossPercentage');
  @override
  late final GeneratedColumn<double> profitLossPercentage =
      GeneratedColumn<double>('profit_loss_percentage', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
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
        imageUrl
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signals';
  @override
  VerificationContext validateIntegrity(Insertable<SignalTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('company_name')) {
      context.handle(
          _companyNameMeta,
          companyName.isAcceptableOrUnknown(
              data['company_name']!, _companyNameMeta));
    } else if (isInserting) {
      context.missing(_companyNameMeta);
    }
    if (data.containsKey('current_price')) {
      context.handle(
          _currentPriceMeta,
          currentPrice.isAcceptableOrUnknown(
              data['current_price']!, _currentPriceMeta));
    } else if (isInserting) {
      context.missing(_currentPriceMeta);
    }
    if (data.containsKey('target_price')) {
      context.handle(
          _targetPriceMeta,
          targetPrice.isAcceptableOrUnknown(
              data['target_price']!, _targetPriceMeta));
    } else if (isInserting) {
      context.missing(_targetPriceMeta);
    }
    if (data.containsKey('stop_loss')) {
      context.handle(_stopLossMeta,
          stopLoss.isAcceptableOrUnknown(data['stop_loss']!, _stopLossMeta));
    } else if (isInserting) {
      context.missing(_stopLossMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('reasoning')) {
      context.handle(_reasoningMeta,
          reasoning.isAcceptableOrUnknown(data['reasoning']!, _reasoningMeta));
    } else if (isInserting) {
      context.missing(_reasoningMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('profit_loss_percentage')) {
      context.handle(
          _profitLossPercentageMeta,
          profitLossPercentage.isAcceptableOrUnknown(
              data['profit_loss_percentage']!, _profitLossPercentageMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SignalTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignalTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      companyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}company_name'])!,
      type: $SignalsTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      action: $SignalsTable.$converteraction.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}action'])!),
      currentPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_price'])!,
      targetPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_price'])!,
      stopLoss: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}stop_loss'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      reasoning: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reasoning'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at']),
      status: $SignalsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      requiredTier: $SignalsTable.$converterrequiredTier.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}required_tier'])!),
      profitLossPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}profit_loss_percentage']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
    );
  }

  @override
  $SignalsTable createAlias(String alias) {
    return $SignalsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SignalType, int, int> $convertertype =
      const EnumIndexConverter<SignalType>(SignalType.values);
  static JsonTypeConverter2<SignalAction, int, int> $converteraction =
      const EnumIndexConverter<SignalAction>(SignalAction.values);
  static JsonTypeConverter2<SignalStatus, int, int> $converterstatus =
      const EnumIndexConverter<SignalStatus>(SignalStatus.values);
  static JsonTypeConverter2<SubscriptionTier, int, int> $converterrequiredTier =
      const EnumIndexConverter<SubscriptionTier>(SubscriptionTier.values);
}

class SignalTable extends DataClass implements Insertable<SignalTable> {
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
  final String tags;
  final SubscriptionTier requiredTier;
  final double? profitLossPercentage;
  final String? imageUrl;
  const SignalTable(
      {required this.id,
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
      this.imageUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['symbol'] = Variable<String>(symbol);
    map['company_name'] = Variable<String>(companyName);
    {
      map['type'] = Variable<int>($SignalsTable.$convertertype.toSql(type));
    }
    {
      map['action'] =
          Variable<int>($SignalsTable.$converteraction.toSql(action));
    }
    map['current_price'] = Variable<double>(currentPrice);
    map['target_price'] = Variable<double>(targetPrice);
    map['stop_loss'] = Variable<double>(stopLoss);
    map['confidence'] = Variable<double>(confidence);
    map['reasoning'] = Variable<String>(reasoning);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    {
      map['status'] =
          Variable<int>($SignalsTable.$converterstatus.toSql(status));
    }
    map['tags'] = Variable<String>(tags);
    {
      map['required_tier'] = Variable<int>(
          $SignalsTable.$converterrequiredTier.toSql(requiredTier));
    }
    if (!nullToAbsent || profitLossPercentage != null) {
      map['profit_loss_percentage'] = Variable<double>(profitLossPercentage);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    return map;
  }

  SignalsCompanion toCompanion(bool nullToAbsent) {
    return SignalsCompanion(
      id: Value(id),
      symbol: Value(symbol),
      companyName: Value(companyName),
      type: Value(type),
      action: Value(action),
      currentPrice: Value(currentPrice),
      targetPrice: Value(targetPrice),
      stopLoss: Value(stopLoss),
      confidence: Value(confidence),
      reasoning: Value(reasoning),
      createdAt: Value(createdAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      status: Value(status),
      tags: Value(tags),
      requiredTier: Value(requiredTier),
      profitLossPercentage: profitLossPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(profitLossPercentage),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
    );
  }

  factory SignalTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignalTable(
      id: serializer.fromJson<String>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      companyName: serializer.fromJson<String>(json['companyName']),
      type: $SignalsTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      action: $SignalsTable.$converteraction
          .fromJson(serializer.fromJson<int>(json['action'])),
      currentPrice: serializer.fromJson<double>(json['currentPrice']),
      targetPrice: serializer.fromJson<double>(json['targetPrice']),
      stopLoss: serializer.fromJson<double>(json['stopLoss']),
      confidence: serializer.fromJson<double>(json['confidence']),
      reasoning: serializer.fromJson<String>(json['reasoning']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      status: $SignalsTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      tags: serializer.fromJson<String>(json['tags']),
      requiredTier: $SignalsTable.$converterrequiredTier
          .fromJson(serializer.fromJson<int>(json['requiredTier'])),
      profitLossPercentage:
          serializer.fromJson<double?>(json['profitLossPercentage']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'symbol': serializer.toJson<String>(symbol),
      'companyName': serializer.toJson<String>(companyName),
      'type': serializer.toJson<int>($SignalsTable.$convertertype.toJson(type)),
      'action':
          serializer.toJson<int>($SignalsTable.$converteraction.toJson(action)),
      'currentPrice': serializer.toJson<double>(currentPrice),
      'targetPrice': serializer.toJson<double>(targetPrice),
      'stopLoss': serializer.toJson<double>(stopLoss),
      'confidence': serializer.toJson<double>(confidence),
      'reasoning': serializer.toJson<String>(reasoning),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'status':
          serializer.toJson<int>($SignalsTable.$converterstatus.toJson(status)),
      'tags': serializer.toJson<String>(tags),
      'requiredTier': serializer.toJson<int>(
          $SignalsTable.$converterrequiredTier.toJson(requiredTier)),
      'profitLossPercentage': serializer.toJson<double?>(profitLossPercentage),
      'imageUrl': serializer.toJson<String?>(imageUrl),
    };
  }

  SignalTable copyWith(
          {String? id,
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
          Value<DateTime?> expiresAt = const Value.absent(),
          SignalStatus? status,
          String? tags,
          SubscriptionTier? requiredTier,
          Value<double?> profitLossPercentage = const Value.absent(),
          Value<String?> imageUrl = const Value.absent()}) =>
      SignalTable(
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
        expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
        status: status ?? this.status,
        tags: tags ?? this.tags,
        requiredTier: requiredTier ?? this.requiredTier,
        profitLossPercentage: profitLossPercentage.present
            ? profitLossPercentage.value
            : this.profitLossPercentage,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
      );
  SignalTable copyWithCompanion(SignalsCompanion data) {
    return SignalTable(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      companyName:
          data.companyName.present ? data.companyName.value : this.companyName,
      type: data.type.present ? data.type.value : this.type,
      action: data.action.present ? data.action.value : this.action,
      currentPrice: data.currentPrice.present
          ? data.currentPrice.value
          : this.currentPrice,
      targetPrice:
          data.targetPrice.present ? data.targetPrice.value : this.targetPrice,
      stopLoss: data.stopLoss.present ? data.stopLoss.value : this.stopLoss,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      reasoning: data.reasoning.present ? data.reasoning.value : this.reasoning,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      status: data.status.present ? data.status.value : this.status,
      tags: data.tags.present ? data.tags.value : this.tags,
      requiredTier: data.requiredTier.present
          ? data.requiredTier.value
          : this.requiredTier,
      profitLossPercentage: data.profitLossPercentage.present
          ? data.profitLossPercentage.value
          : this.profitLossPercentage,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignalTable(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('companyName: $companyName, ')
          ..write('type: $type, ')
          ..write('action: $action, ')
          ..write('currentPrice: $currentPrice, ')
          ..write('targetPrice: $targetPrice, ')
          ..write('stopLoss: $stopLoss, ')
          ..write('confidence: $confidence, ')
          ..write('reasoning: $reasoning, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('status: $status, ')
          ..write('tags: $tags, ')
          ..write('requiredTier: $requiredTier, ')
          ..write('profitLossPercentage: $profitLossPercentage, ')
          ..write('imageUrl: $imageUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      imageUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignalTable &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.companyName == this.companyName &&
          other.type == this.type &&
          other.action == this.action &&
          other.currentPrice == this.currentPrice &&
          other.targetPrice == this.targetPrice &&
          other.stopLoss == this.stopLoss &&
          other.confidence == this.confidence &&
          other.reasoning == this.reasoning &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt &&
          other.status == this.status &&
          other.tags == this.tags &&
          other.requiredTier == this.requiredTier &&
          other.profitLossPercentage == this.profitLossPercentage &&
          other.imageUrl == this.imageUrl);
}

class SignalsCompanion extends UpdateCompanion<SignalTable> {
  final Value<String> id;
  final Value<String> symbol;
  final Value<String> companyName;
  final Value<SignalType> type;
  final Value<SignalAction> action;
  final Value<double> currentPrice;
  final Value<double> targetPrice;
  final Value<double> stopLoss;
  final Value<double> confidence;
  final Value<String> reasoning;
  final Value<DateTime> createdAt;
  final Value<DateTime?> expiresAt;
  final Value<SignalStatus> status;
  final Value<String> tags;
  final Value<SubscriptionTier> requiredTier;
  final Value<double?> profitLossPercentage;
  final Value<String?> imageUrl;
  final Value<int> rowid;
  const SignalsCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.companyName = const Value.absent(),
    this.type = const Value.absent(),
    this.action = const Value.absent(),
    this.currentPrice = const Value.absent(),
    this.targetPrice = const Value.absent(),
    this.stopLoss = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reasoning = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.status = const Value.absent(),
    this.tags = const Value.absent(),
    this.requiredTier = const Value.absent(),
    this.profitLossPercentage = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SignalsCompanion.insert({
    required String id,
    required String symbol,
    required String companyName,
    required SignalType type,
    required SignalAction action,
    required double currentPrice,
    required double targetPrice,
    required double stopLoss,
    required double confidence,
    required String reasoning,
    required DateTime createdAt,
    this.expiresAt = const Value.absent(),
    required SignalStatus status,
    required String tags,
    required SubscriptionTier requiredTier,
    this.profitLossPercentage = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        symbol = Value(symbol),
        companyName = Value(companyName),
        type = Value(type),
        action = Value(action),
        currentPrice = Value(currentPrice),
        targetPrice = Value(targetPrice),
        stopLoss = Value(stopLoss),
        confidence = Value(confidence),
        reasoning = Value(reasoning),
        createdAt = Value(createdAt),
        status = Value(status),
        tags = Value(tags),
        requiredTier = Value(requiredTier);
  static Insertable<SignalTable> custom({
    Expression<String>? id,
    Expression<String>? symbol,
    Expression<String>? companyName,
    Expression<int>? type,
    Expression<int>? action,
    Expression<double>? currentPrice,
    Expression<double>? targetPrice,
    Expression<double>? stopLoss,
    Expression<double>? confidence,
    Expression<String>? reasoning,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? status,
    Expression<String>? tags,
    Expression<int>? requiredTier,
    Expression<double>? profitLossPercentage,
    Expression<String>? imageUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (companyName != null) 'company_name': companyName,
      if (type != null) 'type': type,
      if (action != null) 'action': action,
      if (currentPrice != null) 'current_price': currentPrice,
      if (targetPrice != null) 'target_price': targetPrice,
      if (stopLoss != null) 'stop_loss': stopLoss,
      if (confidence != null) 'confidence': confidence,
      if (reasoning != null) 'reasoning': reasoning,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (status != null) 'status': status,
      if (tags != null) 'tags': tags,
      if (requiredTier != null) 'required_tier': requiredTier,
      if (profitLossPercentage != null)
        'profit_loss_percentage': profitLossPercentage,
      if (imageUrl != null) 'image_url': imageUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SignalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? symbol,
      Value<String>? companyName,
      Value<SignalType>? type,
      Value<SignalAction>? action,
      Value<double>? currentPrice,
      Value<double>? targetPrice,
      Value<double>? stopLoss,
      Value<double>? confidence,
      Value<String>? reasoning,
      Value<DateTime>? createdAt,
      Value<DateTime?>? expiresAt,
      Value<SignalStatus>? status,
      Value<String>? tags,
      Value<SubscriptionTier>? requiredTier,
      Value<double?>? profitLossPercentage,
      Value<String?>? imageUrl,
      Value<int>? rowid}) {
    return SignalsCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($SignalsTable.$convertertype.toSql(type.value));
    }
    if (action.present) {
      map['action'] =
          Variable<int>($SignalsTable.$converteraction.toSql(action.value));
    }
    if (currentPrice.present) {
      map['current_price'] = Variable<double>(currentPrice.value);
    }
    if (targetPrice.present) {
      map['target_price'] = Variable<double>(targetPrice.value);
    }
    if (stopLoss.present) {
      map['stop_loss'] = Variable<double>(stopLoss.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (reasoning.present) {
      map['reasoning'] = Variable<String>(reasoning.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (status.present) {
      map['status'] =
          Variable<int>($SignalsTable.$converterstatus.toSql(status.value));
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (requiredTier.present) {
      map['required_tier'] = Variable<int>(
          $SignalsTable.$converterrequiredTier.toSql(requiredTier.value));
    }
    if (profitLossPercentage.present) {
      map['profit_loss_percentage'] =
          Variable<double>(profitLossPercentage.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignalsCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('companyName: $companyName, ')
          ..write('type: $type, ')
          ..write('action: $action, ')
          ..write('currentPrice: $currentPrice, ')
          ..write('targetPrice: $targetPrice, ')
          ..write('stopLoss: $stopLoss, ')
          ..write('confidence: $confidence, ')
          ..write('reasoning: $reasoning, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('status: $status, ')
          ..write('tags: $tags, ')
          ..write('requiredTier: $requiredTier, ')
          ..write('profitLossPercentage: $profitLossPercentage, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchlistItemsTable extends WatchlistItems
    with TableInfo<$WatchlistItemsTable, WatchlistItemTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchlistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _companyNameMeta =
      const VerificationMeta('companyName');
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
      'company_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<SignalType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<SignalType>($WatchlistItemsTable.$convertertype);
  static const VerificationMeta _currentPriceMeta =
      const VerificationMeta('currentPrice');
  @override
  late final GeneratedColumn<double> currentPrice = GeneratedColumn<double>(
      'current_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _priceChangeMeta =
      const VerificationMeta('priceChange');
  @override
  late final GeneratedColumn<double> priceChange = GeneratedColumn<double>(
      'price_change', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _priceChangePercentMeta =
      const VerificationMeta('priceChangePercent');
  @override
  late final GeneratedColumn<double> priceChangePercent =
      GeneratedColumn<double>('price_change_percent', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isPriceAlertEnabledMeta =
      const VerificationMeta('isPriceAlertEnabled');
  @override
  late final GeneratedColumn<bool> isPriceAlertEnabled = GeneratedColumn<bool>(
      'is_price_alert_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_price_alert_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _priceAlertTargetMeta =
      const VerificationMeta('priceAlertTarget');
  @override
  late final GeneratedColumn<double> priceAlertTarget = GeneratedColumn<double>(
      'price_alert_target', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
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
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watchlist_items';
  @override
  VerificationContext validateIntegrity(Insertable<WatchlistItemTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('company_name')) {
      context.handle(
          _companyNameMeta,
          companyName.isAcceptableOrUnknown(
              data['company_name']!, _companyNameMeta));
    } else if (isInserting) {
      context.missing(_companyNameMeta);
    }
    if (data.containsKey('current_price')) {
      context.handle(
          _currentPriceMeta,
          currentPrice.isAcceptableOrUnknown(
              data['current_price']!, _currentPriceMeta));
    } else if (isInserting) {
      context.missing(_currentPriceMeta);
    }
    if (data.containsKey('price_change')) {
      context.handle(
          _priceChangeMeta,
          priceChange.isAcceptableOrUnknown(
              data['price_change']!, _priceChangeMeta));
    } else if (isInserting) {
      context.missing(_priceChangeMeta);
    }
    if (data.containsKey('price_change_percent')) {
      context.handle(
          _priceChangePercentMeta,
          priceChangePercent.isAcceptableOrUnknown(
              data['price_change_percent']!, _priceChangePercentMeta));
    } else if (isInserting) {
      context.missing(_priceChangePercentMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('is_price_alert_enabled')) {
      context.handle(
          _isPriceAlertEnabledMeta,
          isPriceAlertEnabled.isAcceptableOrUnknown(
              data['is_price_alert_enabled']!, _isPriceAlertEnabledMeta));
    }
    if (data.containsKey('price_alert_target')) {
      context.handle(
          _priceAlertTargetMeta,
          priceAlertTarget.isAcceptableOrUnknown(
              data['price_alert_target']!, _priceAlertTargetMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchlistItemTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchlistItemTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      companyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}company_name'])!,
      type: $WatchlistItemsTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      currentPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_price'])!,
      priceChange: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price_change'])!,
      priceChangePercent: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}price_change_percent'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
      isPriceAlertEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_price_alert_enabled'])!,
      priceAlertTarget: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}price_alert_target']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $WatchlistItemsTable createAlias(String alias) {
    return $WatchlistItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SignalType, int, int> $convertertype =
      const EnumIndexConverter<SignalType>(SignalType.values);
}

class WatchlistItemTable extends DataClass
    implements Insertable<WatchlistItemTable> {
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
  const WatchlistItemTable(
      {required this.id,
      required this.symbol,
      required this.companyName,
      required this.type,
      required this.currentPrice,
      required this.priceChange,
      required this.priceChangePercent,
      required this.addedAt,
      required this.isPriceAlertEnabled,
      this.priceAlertTarget,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['symbol'] = Variable<String>(symbol);
    map['company_name'] = Variable<String>(companyName);
    {
      map['type'] =
          Variable<int>($WatchlistItemsTable.$convertertype.toSql(type));
    }
    map['current_price'] = Variable<double>(currentPrice);
    map['price_change'] = Variable<double>(priceChange);
    map['price_change_percent'] = Variable<double>(priceChangePercent);
    map['added_at'] = Variable<DateTime>(addedAt);
    map['is_price_alert_enabled'] = Variable<bool>(isPriceAlertEnabled);
    if (!nullToAbsent || priceAlertTarget != null) {
      map['price_alert_target'] = Variable<double>(priceAlertTarget);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  WatchlistItemsCompanion toCompanion(bool nullToAbsent) {
    return WatchlistItemsCompanion(
      id: Value(id),
      symbol: Value(symbol),
      companyName: Value(companyName),
      type: Value(type),
      currentPrice: Value(currentPrice),
      priceChange: Value(priceChange),
      priceChangePercent: Value(priceChangePercent),
      addedAt: Value(addedAt),
      isPriceAlertEnabled: Value(isPriceAlertEnabled),
      priceAlertTarget: priceAlertTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(priceAlertTarget),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory WatchlistItemTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchlistItemTable(
      id: serializer.fromJson<String>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      companyName: serializer.fromJson<String>(json['companyName']),
      type: $WatchlistItemsTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      currentPrice: serializer.fromJson<double>(json['currentPrice']),
      priceChange: serializer.fromJson<double>(json['priceChange']),
      priceChangePercent:
          serializer.fromJson<double>(json['priceChangePercent']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      isPriceAlertEnabled:
          serializer.fromJson<bool>(json['isPriceAlertEnabled']),
      priceAlertTarget: serializer.fromJson<double?>(json['priceAlertTarget']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'symbol': serializer.toJson<String>(symbol),
      'companyName': serializer.toJson<String>(companyName),
      'type': serializer
          .toJson<int>($WatchlistItemsTable.$convertertype.toJson(type)),
      'currentPrice': serializer.toJson<double>(currentPrice),
      'priceChange': serializer.toJson<double>(priceChange),
      'priceChangePercent': serializer.toJson<double>(priceChangePercent),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'isPriceAlertEnabled': serializer.toJson<bool>(isPriceAlertEnabled),
      'priceAlertTarget': serializer.toJson<double?>(priceAlertTarget),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  WatchlistItemTable copyWith(
          {String? id,
          String? symbol,
          String? companyName,
          SignalType? type,
          double? currentPrice,
          double? priceChange,
          double? priceChangePercent,
          DateTime? addedAt,
          bool? isPriceAlertEnabled,
          Value<double?> priceAlertTarget = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      WatchlistItemTable(
        id: id ?? this.id,
        symbol: symbol ?? this.symbol,
        companyName: companyName ?? this.companyName,
        type: type ?? this.type,
        currentPrice: currentPrice ?? this.currentPrice,
        priceChange: priceChange ?? this.priceChange,
        priceChangePercent: priceChangePercent ?? this.priceChangePercent,
        addedAt: addedAt ?? this.addedAt,
        isPriceAlertEnabled: isPriceAlertEnabled ?? this.isPriceAlertEnabled,
        priceAlertTarget: priceAlertTarget.present
            ? priceAlertTarget.value
            : this.priceAlertTarget,
        notes: notes.present ? notes.value : this.notes,
      );
  WatchlistItemTable copyWithCompanion(WatchlistItemsCompanion data) {
    return WatchlistItemTable(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      companyName:
          data.companyName.present ? data.companyName.value : this.companyName,
      type: data.type.present ? data.type.value : this.type,
      currentPrice: data.currentPrice.present
          ? data.currentPrice.value
          : this.currentPrice,
      priceChange:
          data.priceChange.present ? data.priceChange.value : this.priceChange,
      priceChangePercent: data.priceChangePercent.present
          ? data.priceChangePercent.value
          : this.priceChangePercent,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      isPriceAlertEnabled: data.isPriceAlertEnabled.present
          ? data.isPriceAlertEnabled.value
          : this.isPriceAlertEnabled,
      priceAlertTarget: data.priceAlertTarget.present
          ? data.priceAlertTarget.value
          : this.priceAlertTarget,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistItemTable(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('companyName: $companyName, ')
          ..write('type: $type, ')
          ..write('currentPrice: $currentPrice, ')
          ..write('priceChange: $priceChange, ')
          ..write('priceChangePercent: $priceChangePercent, ')
          ..write('addedAt: $addedAt, ')
          ..write('isPriceAlertEnabled: $isPriceAlertEnabled, ')
          ..write('priceAlertTarget: $priceAlertTarget, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchlistItemTable &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.companyName == this.companyName &&
          other.type == this.type &&
          other.currentPrice == this.currentPrice &&
          other.priceChange == this.priceChange &&
          other.priceChangePercent == this.priceChangePercent &&
          other.addedAt == this.addedAt &&
          other.isPriceAlertEnabled == this.isPriceAlertEnabled &&
          other.priceAlertTarget == this.priceAlertTarget &&
          other.notes == this.notes);
}

class WatchlistItemsCompanion extends UpdateCompanion<WatchlistItemTable> {
  final Value<String> id;
  final Value<String> symbol;
  final Value<String> companyName;
  final Value<SignalType> type;
  final Value<double> currentPrice;
  final Value<double> priceChange;
  final Value<double> priceChangePercent;
  final Value<DateTime> addedAt;
  final Value<bool> isPriceAlertEnabled;
  final Value<double?> priceAlertTarget;
  final Value<String?> notes;
  final Value<int> rowid;
  const WatchlistItemsCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.companyName = const Value.absent(),
    this.type = const Value.absent(),
    this.currentPrice = const Value.absent(),
    this.priceChange = const Value.absent(),
    this.priceChangePercent = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.isPriceAlertEnabled = const Value.absent(),
    this.priceAlertTarget = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchlistItemsCompanion.insert({
    required String id,
    required String symbol,
    required String companyName,
    required SignalType type,
    required double currentPrice,
    required double priceChange,
    required double priceChangePercent,
    required DateTime addedAt,
    this.isPriceAlertEnabled = const Value.absent(),
    this.priceAlertTarget = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        symbol = Value(symbol),
        companyName = Value(companyName),
        type = Value(type),
        currentPrice = Value(currentPrice),
        priceChange = Value(priceChange),
        priceChangePercent = Value(priceChangePercent),
        addedAt = Value(addedAt);
  static Insertable<WatchlistItemTable> custom({
    Expression<String>? id,
    Expression<String>? symbol,
    Expression<String>? companyName,
    Expression<int>? type,
    Expression<double>? currentPrice,
    Expression<double>? priceChange,
    Expression<double>? priceChangePercent,
    Expression<DateTime>? addedAt,
    Expression<bool>? isPriceAlertEnabled,
    Expression<double>? priceAlertTarget,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (companyName != null) 'company_name': companyName,
      if (type != null) 'type': type,
      if (currentPrice != null) 'current_price': currentPrice,
      if (priceChange != null) 'price_change': priceChange,
      if (priceChangePercent != null)
        'price_change_percent': priceChangePercent,
      if (addedAt != null) 'added_at': addedAt,
      if (isPriceAlertEnabled != null)
        'is_price_alert_enabled': isPriceAlertEnabled,
      if (priceAlertTarget != null) 'price_alert_target': priceAlertTarget,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchlistItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? symbol,
      Value<String>? companyName,
      Value<SignalType>? type,
      Value<double>? currentPrice,
      Value<double>? priceChange,
      Value<double>? priceChangePercent,
      Value<DateTime>? addedAt,
      Value<bool>? isPriceAlertEnabled,
      Value<double?>? priceAlertTarget,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return WatchlistItemsCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($WatchlistItemsTable.$convertertype.toSql(type.value));
    }
    if (currentPrice.present) {
      map['current_price'] = Variable<double>(currentPrice.value);
    }
    if (priceChange.present) {
      map['price_change'] = Variable<double>(priceChange.value);
    }
    if (priceChangePercent.present) {
      map['price_change_percent'] = Variable<double>(priceChangePercent.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (isPriceAlertEnabled.present) {
      map['is_price_alert_enabled'] = Variable<bool>(isPriceAlertEnabled.value);
    }
    if (priceAlertTarget.present) {
      map['price_alert_target'] = Variable<double>(priceAlertTarget.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistItemsCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('companyName: $companyName, ')
          ..write('type: $type, ')
          ..write('currentPrice: $currentPrice, ')
          ..write('priceChange: $priceChange, ')
          ..write('priceChangePercent: $priceChangePercent, ')
          ..write('addedAt: $addedAt, ')
          ..write('isPriceAlertEnabled: $isPriceAlertEnabled, ')
          ..write('priceAlertTarget: $priceAlertTarget, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $SignalsTable signals = $SignalsTable(this);
  late final $WatchlistItemsTable watchlistItems = $WatchlistItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, signals, watchlistItems];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String email,
  required String firstName,
  required String lastName,
  Value<String?> profileImageUrl,
  required DateTime createdAt,
  Value<bool> isVerified,
  required SubscriptionTier subscriptionTier,
  Value<DateTime?> subscriptionExpiresAt,
  required AuthProvider authProvider,
  Value<String?> providerId,
  Value<String?> providerData,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String> firstName,
  Value<String> lastName,
  Value<String?> profileImageUrl,
  Value<DateTime> createdAt,
  Value<bool> isVerified,
  Value<SubscriptionTier> subscriptionTier,
  Value<DateTime?> subscriptionExpiresAt,
  Value<AuthProvider> authProvider,
  Value<String?> providerId,
  Value<String?> providerData,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profileImageUrl => $composableBuilder(
      column: $table.profileImageUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SubscriptionTier, SubscriptionTier, int>
      get subscriptionTier => $composableBuilder(
          column: $table.subscriptionTier,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get subscriptionExpiresAt => $composableBuilder(
      column: $table.subscriptionExpiresAt,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AuthProvider, AuthProvider, int>
      get authProvider => $composableBuilder(
          column: $table.authProvider,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerData => $composableBuilder(
      column: $table.providerData, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profileImageUrl => $composableBuilder(
      column: $table.profileImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subscriptionTier => $composableBuilder(
      column: $table.subscriptionTier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get subscriptionExpiresAt => $composableBuilder(
      column: $table.subscriptionExpiresAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get authProvider => $composableBuilder(
      column: $table.authProvider,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerData => $composableBuilder(
      column: $table.providerData,
      builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get profileImageUrl => $composableBuilder(
      column: $table.profileImageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SubscriptionTier, int>
      get subscriptionTier => $composableBuilder(
          column: $table.subscriptionTier, builder: (column) => column);

  GeneratedColumn<DateTime> get subscriptionExpiresAt => $composableBuilder(
      column: $table.subscriptionExpiresAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AuthProvider, int> get authProvider =>
      $composableBuilder(
          column: $table.authProvider, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => column);

  GeneratedColumn<String> get providerData => $composableBuilder(
      column: $table.providerData, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    UserTable,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserTable, BaseReferences<_$AppDatabase, $UsersTable, UserTable>),
    UserTable,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String> lastName = const Value.absent(),
            Value<String?> profileImageUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isVerified = const Value.absent(),
            Value<SubscriptionTier> subscriptionTier = const Value.absent(),
            Value<DateTime?> subscriptionExpiresAt = const Value.absent(),
            Value<AuthProvider> authProvider = const Value.absent(),
            Value<String?> providerId = const Value.absent(),
            Value<String?> providerData = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            profileImageUrl: profileImageUrl,
            createdAt: createdAt,
            isVerified: isVerified,
            subscriptionTier: subscriptionTier,
            subscriptionExpiresAt: subscriptionExpiresAt,
            authProvider: authProvider,
            providerId: providerId,
            providerData: providerData,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String email,
            required String firstName,
            required String lastName,
            Value<String?> profileImageUrl = const Value.absent(),
            required DateTime createdAt,
            Value<bool> isVerified = const Value.absent(),
            required SubscriptionTier subscriptionTier,
            Value<DateTime?> subscriptionExpiresAt = const Value.absent(),
            required AuthProvider authProvider,
            Value<String?> providerId = const Value.absent(),
            Value<String?> providerData = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            profileImageUrl: profileImageUrl,
            createdAt: createdAt,
            isVerified: isVerified,
            subscriptionTier: subscriptionTier,
            subscriptionExpiresAt: subscriptionExpiresAt,
            authProvider: authProvider,
            providerId: providerId,
            providerData: providerData,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    UserTable,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserTable, BaseReferences<_$AppDatabase, $UsersTable, UserTable>),
    UserTable,
    PrefetchHooks Function()>;
typedef $$SignalsTableCreateCompanionBuilder = SignalsCompanion Function({
  required String id,
  required String symbol,
  required String companyName,
  required SignalType type,
  required SignalAction action,
  required double currentPrice,
  required double targetPrice,
  required double stopLoss,
  required double confidence,
  required String reasoning,
  required DateTime createdAt,
  Value<DateTime?> expiresAt,
  required SignalStatus status,
  required String tags,
  required SubscriptionTier requiredTier,
  Value<double?> profitLossPercentage,
  Value<String?> imageUrl,
  Value<int> rowid,
});
typedef $$SignalsTableUpdateCompanionBuilder = SignalsCompanion Function({
  Value<String> id,
  Value<String> symbol,
  Value<String> companyName,
  Value<SignalType> type,
  Value<SignalAction> action,
  Value<double> currentPrice,
  Value<double> targetPrice,
  Value<double> stopLoss,
  Value<double> confidence,
  Value<String> reasoning,
  Value<DateTime> createdAt,
  Value<DateTime?> expiresAt,
  Value<SignalStatus> status,
  Value<String> tags,
  Value<SubscriptionTier> requiredTier,
  Value<double?> profitLossPercentage,
  Value<String?> imageUrl,
  Value<int> rowid,
});

class $$SignalsTableFilterComposer
    extends Composer<_$AppDatabase, $SignalsTable> {
  $$SignalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SignalType, SignalType, int> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<SignalAction, SignalAction, int> get action =>
      $composableBuilder(
          column: $table.action,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get currentPrice => $composableBuilder(
      column: $table.currentPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetPrice => $composableBuilder(
      column: $table.targetPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stopLoss => $composableBuilder(
      column: $table.stopLoss, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reasoning => $composableBuilder(
      column: $table.reasoning, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SignalStatus, SignalStatus, int> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SubscriptionTier, SubscriptionTier, int>
      get requiredTier => $composableBuilder(
          column: $table.requiredTier,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get profitLossPercentage => $composableBuilder(
      column: $table.profitLossPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));
}

class $$SignalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SignalsTable> {
  $$SignalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentPrice => $composableBuilder(
      column: $table.currentPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetPrice => $composableBuilder(
      column: $table.targetPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stopLoss => $composableBuilder(
      column: $table.stopLoss, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reasoning => $composableBuilder(
      column: $table.reasoning, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get requiredTier => $composableBuilder(
      column: $table.requiredTier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get profitLossPercentage => $composableBuilder(
      column: $table.profitLossPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));
}

class $$SignalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SignalsTable> {
  $$SignalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SignalType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SignalAction, int> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<double> get currentPrice => $composableBuilder(
      column: $table.currentPrice, builder: (column) => column);

  GeneratedColumn<double> get targetPrice => $composableBuilder(
      column: $table.targetPrice, builder: (column) => column);

  GeneratedColumn<double> get stopLoss =>
      $composableBuilder(column: $table.stopLoss, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get reasoning =>
      $composableBuilder(column: $table.reasoning, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SignalStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SubscriptionTier, int> get requiredTier =>
      $composableBuilder(
          column: $table.requiredTier, builder: (column) => column);

  GeneratedColumn<double> get profitLossPercentage => $composableBuilder(
      column: $table.profitLossPercentage, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);
}

class $$SignalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SignalsTable,
    SignalTable,
    $$SignalsTableFilterComposer,
    $$SignalsTableOrderingComposer,
    $$SignalsTableAnnotationComposer,
    $$SignalsTableCreateCompanionBuilder,
    $$SignalsTableUpdateCompanionBuilder,
    (SignalTable, BaseReferences<_$AppDatabase, $SignalsTable, SignalTable>),
    SignalTable,
    PrefetchHooks Function()> {
  $$SignalsTableTableManager(_$AppDatabase db, $SignalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<String> companyName = const Value.absent(),
            Value<SignalType> type = const Value.absent(),
            Value<SignalAction> action = const Value.absent(),
            Value<double> currentPrice = const Value.absent(),
            Value<double> targetPrice = const Value.absent(),
            Value<double> stopLoss = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<String> reasoning = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> expiresAt = const Value.absent(),
            Value<SignalStatus> status = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<SubscriptionTier> requiredTier = const Value.absent(),
            Value<double?> profitLossPercentage = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SignalsCompanion(
            id: id,
            symbol: symbol,
            companyName: companyName,
            type: type,
            action: action,
            currentPrice: currentPrice,
            targetPrice: targetPrice,
            stopLoss: stopLoss,
            confidence: confidence,
            reasoning: reasoning,
            createdAt: createdAt,
            expiresAt: expiresAt,
            status: status,
            tags: tags,
            requiredTier: requiredTier,
            profitLossPercentage: profitLossPercentage,
            imageUrl: imageUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String symbol,
            required String companyName,
            required SignalType type,
            required SignalAction action,
            required double currentPrice,
            required double targetPrice,
            required double stopLoss,
            required double confidence,
            required String reasoning,
            required DateTime createdAt,
            Value<DateTime?> expiresAt = const Value.absent(),
            required SignalStatus status,
            required String tags,
            required SubscriptionTier requiredTier,
            Value<double?> profitLossPercentage = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SignalsCompanion.insert(
            id: id,
            symbol: symbol,
            companyName: companyName,
            type: type,
            action: action,
            currentPrice: currentPrice,
            targetPrice: targetPrice,
            stopLoss: stopLoss,
            confidence: confidence,
            reasoning: reasoning,
            createdAt: createdAt,
            expiresAt: expiresAt,
            status: status,
            tags: tags,
            requiredTier: requiredTier,
            profitLossPercentage: profitLossPercentage,
            imageUrl: imageUrl,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SignalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SignalsTable,
    SignalTable,
    $$SignalsTableFilterComposer,
    $$SignalsTableOrderingComposer,
    $$SignalsTableAnnotationComposer,
    $$SignalsTableCreateCompanionBuilder,
    $$SignalsTableUpdateCompanionBuilder,
    (SignalTable, BaseReferences<_$AppDatabase, $SignalsTable, SignalTable>),
    SignalTable,
    PrefetchHooks Function()>;
typedef $$WatchlistItemsTableCreateCompanionBuilder = WatchlistItemsCompanion
    Function({
  required String id,
  required String symbol,
  required String companyName,
  required SignalType type,
  required double currentPrice,
  required double priceChange,
  required double priceChangePercent,
  required DateTime addedAt,
  Value<bool> isPriceAlertEnabled,
  Value<double?> priceAlertTarget,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$WatchlistItemsTableUpdateCompanionBuilder = WatchlistItemsCompanion
    Function({
  Value<String> id,
  Value<String> symbol,
  Value<String> companyName,
  Value<SignalType> type,
  Value<double> currentPrice,
  Value<double> priceChange,
  Value<double> priceChangePercent,
  Value<DateTime> addedAt,
  Value<bool> isPriceAlertEnabled,
  Value<double?> priceAlertTarget,
  Value<String?> notes,
  Value<int> rowid,
});

class $$WatchlistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WatchlistItemsTable> {
  $$WatchlistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SignalType, SignalType, int> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get currentPrice => $composableBuilder(
      column: $table.currentPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get priceChange => $composableBuilder(
      column: $table.priceChange, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get priceChangePercent => $composableBuilder(
      column: $table.priceChangePercent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPriceAlertEnabled => $composableBuilder(
      column: $table.isPriceAlertEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get priceAlertTarget => $composableBuilder(
      column: $table.priceAlertTarget,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$WatchlistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchlistItemsTable> {
  $$WatchlistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentPrice => $composableBuilder(
      column: $table.currentPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get priceChange => $composableBuilder(
      column: $table.priceChange, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get priceChangePercent => $composableBuilder(
      column: $table.priceChangePercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPriceAlertEnabled => $composableBuilder(
      column: $table.isPriceAlertEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get priceAlertTarget => $composableBuilder(
      column: $table.priceAlertTarget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$WatchlistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchlistItemsTable> {
  $$WatchlistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SignalType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get currentPrice => $composableBuilder(
      column: $table.currentPrice, builder: (column) => column);

  GeneratedColumn<double> get priceChange => $composableBuilder(
      column: $table.priceChange, builder: (column) => column);

  GeneratedColumn<double> get priceChangePercent => $composableBuilder(
      column: $table.priceChangePercent, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<bool> get isPriceAlertEnabled => $composableBuilder(
      column: $table.isPriceAlertEnabled, builder: (column) => column);

  GeneratedColumn<double> get priceAlertTarget => $composableBuilder(
      column: $table.priceAlertTarget, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$WatchlistItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WatchlistItemsTable,
    WatchlistItemTable,
    $$WatchlistItemsTableFilterComposer,
    $$WatchlistItemsTableOrderingComposer,
    $$WatchlistItemsTableAnnotationComposer,
    $$WatchlistItemsTableCreateCompanionBuilder,
    $$WatchlistItemsTableUpdateCompanionBuilder,
    (
      WatchlistItemTable,
      BaseReferences<_$AppDatabase, $WatchlistItemsTable, WatchlistItemTable>
    ),
    WatchlistItemTable,
    PrefetchHooks Function()> {
  $$WatchlistItemsTableTableManager(
      _$AppDatabase db, $WatchlistItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchlistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchlistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchlistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<String> companyName = const Value.absent(),
            Value<SignalType> type = const Value.absent(),
            Value<double> currentPrice = const Value.absent(),
            Value<double> priceChange = const Value.absent(),
            Value<double> priceChangePercent = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<bool> isPriceAlertEnabled = const Value.absent(),
            Value<double?> priceAlertTarget = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WatchlistItemsCompanion(
            id: id,
            symbol: symbol,
            companyName: companyName,
            type: type,
            currentPrice: currentPrice,
            priceChange: priceChange,
            priceChangePercent: priceChangePercent,
            addedAt: addedAt,
            isPriceAlertEnabled: isPriceAlertEnabled,
            priceAlertTarget: priceAlertTarget,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String symbol,
            required String companyName,
            required SignalType type,
            required double currentPrice,
            required double priceChange,
            required double priceChangePercent,
            required DateTime addedAt,
            Value<bool> isPriceAlertEnabled = const Value.absent(),
            Value<double?> priceAlertTarget = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WatchlistItemsCompanion.insert(
            id: id,
            symbol: symbol,
            companyName: companyName,
            type: type,
            currentPrice: currentPrice,
            priceChange: priceChange,
            priceChangePercent: priceChangePercent,
            addedAt: addedAt,
            isPriceAlertEnabled: isPriceAlertEnabled,
            priceAlertTarget: priceAlertTarget,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WatchlistItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WatchlistItemsTable,
    WatchlistItemTable,
    $$WatchlistItemsTableFilterComposer,
    $$WatchlistItemsTableOrderingComposer,
    $$WatchlistItemsTableAnnotationComposer,
    $$WatchlistItemsTableCreateCompanionBuilder,
    $$WatchlistItemsTableUpdateCompanionBuilder,
    (
      WatchlistItemTable,
      BaseReferences<_$AppDatabase, $WatchlistItemsTable, WatchlistItemTable>
    ),
    WatchlistItemTable,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$SignalsTableTableManager get signals =>
      $$SignalsTableTableManager(_db, _db.signals);
  $$WatchlistItemsTableTableManager get watchlistItems =>
      $$WatchlistItemsTableTableManager(_db, _db.watchlistItems);
}
