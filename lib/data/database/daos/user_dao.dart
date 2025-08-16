import 'package:drift/drift.dart';
import '../../../domain/entities/user.dart' as entities;
import '../database.dart';
import '../tables.dart';
import '../converters.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  Future<entities.User?> getCurrentUser() async {
    final query = select(users).limit(1);
    final result = await query.getSingleOrNull();
    return result != null ? DatabaseConverters.userFromTable(result) : null;
  }

  Future<entities.User?> getUserById(String id) async {
    final query = select(users)..where((u) => u.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? DatabaseConverters.userFromTable(result) : null;
  }

  Future<entities.User?> getUserByEmail(String email) async {
    final query = select(users)..where((u) => u.email.equals(email));
    final result = await query.getSingleOrNull();
    return result != null ? DatabaseConverters.userFromTable(result) : null;
  }

  Future<entities.User> createUser(entities.User user) async {
    final companion = DatabaseConverters.userToCompanion(user);
    await into(users).insert(companion);
    return user;
  }

  Future<entities.User> updateUser(entities.User user) async {
    final companion = DatabaseConverters.userToCompanion(user);
    await update(users).replace(companion);
    return user;
  }

  Future<void> deleteUser(String id) async {
    await (delete(users)..where((u) => u.id.equals(id))).go();
  }

  Future<void> deleteAllUsers() async {
    await delete(users).go();
  }

  Future<bool> hasUsers() async {
    final count = await customSelect('SELECT COUNT(*) as count FROM users').getSingle();
    return count.data['count'] as int > 0;
  }

  Stream<entities.User?> watchCurrentUser() {
    return select(users).limit(1).watchSingleOrNull().map(
      (result) => result != null ? DatabaseConverters.userFromTable(result) : null,
    );
  }

  Future<List<entities.User>> getAllUsers() async {
    final query = select(users);
    final results = await query.get();
    return results.map(DatabaseConverters.userFromTable).toList();
  }
}