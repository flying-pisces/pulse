import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../datasources/local_database_service.dart';

class LocalUserRepository {
  final LocalDatabaseService _databaseService;

  LocalUserRepository(this._databaseService);

  Future<User?> getCurrentUser() async {
    return await _databaseService.getCurrentUser();
  }

  Future<User?> getUserByEmail(String email) async {
    return await _databaseService.getUserByEmail(email);
  }

  Future<User> saveUser(User user) async {
    final existingUser = await _databaseService.getUserById(user.id);
    if (existingUser != null) {
      return await _databaseService.updateUser(user);
    } else {
      return await _databaseService.createUser(user);
    }
  }

  Future<void> signOut() async {
    await _databaseService.deleteAllUsers();
  }

  Stream<User?> watchCurrentUser() {
    return _databaseService.watchCurrentUser();
  }

  Future<bool> isUserSignedIn() async {
    return await _databaseService.hasUsers();
  }
}

final localUserRepositoryProvider = Provider<LocalUserRepository>((ref) {
  final databaseService = ref.watch(localDatabaseServiceProvider);
  return LocalUserRepository(databaseService);
});