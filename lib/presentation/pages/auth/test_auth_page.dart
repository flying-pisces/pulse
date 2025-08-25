import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/auth_service.dart';
import '../../../domain/entities/user.dart';

class TestAuthPage extends ConsumerStatefulWidget {
  const TestAuthPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TestAuthPage> createState() => _TestAuthPageState();
}

class _TestAuthPageState extends ConsumerState<TestAuthPage> {
  final AuthService _authService = AuthServiceImpl();
  late final LocalDatabaseService _localDb;
  late final TestDataService _testDataService;
  
  User? _currentUser;
  String _statusMessage = 'Ready for testing';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _localDb = ref.read(localDatabaseServiceProvider);
    _testDataService = TestDataService(_localDb);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await _localDb.getCurrentUser();
      setState(() {
        _currentUser = user;
        _statusMessage = user != null 
          ? 'Logged in as ${user.email} (${user.subscriptionTier.displayName})'
          : 'No user logged in';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error loading user: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null) {
        // Create user in local database
        final user = User(
          id: result.providerId ?? 'google_${DateTime.now().millisecondsSinceEpoch}',
          email: result.email ?? 'unknown@gmail.com',
          firstName: result.name?.split(' ').first ?? 'Test',
          lastName: result.name?.split(' ').last ?? 'User',
          profileImageUrl: result.photoUrl,
          createdAt: DateTime.now(),
          isVerified: true,
          subscriptionTier: SubscriptionTier.free, // Start as free
          authProvider: AuthProvider.google,
          providerId: result.providerId,
          providerData: result.additionalUserInfo,
        );
        
        await _localDb.createUser(user);
        setState(() => _statusMessage = '✅ Google sign-in successful');
        await _loadCurrentUser();
      } else {
        setState(() => _statusMessage = '❌ Google sign-in cancelled');
      }
    } catch (e) {
      setState(() => _statusMessage = '❌ Google sign-in failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      await _localDb.deleteAllUsers(); // Clear local user data
      setState(() => _statusMessage = '✅ Signed out successfully');
      await _loadCurrentUser();
    } catch (e) {
      setState(() => _statusMessage = '❌ Sign out failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTestUsers() async {
    setState(() => _isLoading = true);
    try {
      await _testDataService.createTestUsers();
      await _testDataService.createTestSignals();
      setState(() => _statusMessage = '✅ Test users and signals created');
    } catch (e) {
      setState(() => _statusMessage = '❌ Failed to create test data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _switchToTestUser(String userId, String email, SubscriptionTier tier) async {
    setState(() => _isLoading = true);
    try {
      // In a real app, you'd switch sessions. For testing, we'll update the current user
      final user = await _localDb.getUserById(userId);
      if (user != null) {
        setState(() {
          _currentUser = user;
          _statusMessage = '🔄 Switched to ${email} (${tier.displayName})';
        });
      } else {
        setState(() => _statusMessage = '❌ Test user not found');
      }
    } catch (e) {
      setState(() => _statusMessage = '❌ Failed to switch user: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testTierAccess() async {
    setState(() => _isLoading = true);
    try {
      await _testDataService.testTierAccess();
      setState(() => _statusMessage = '✅ Tier access test completed (check console)');
    } catch (e) {
      setState(() => _statusMessage = '❌ Tier access test failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Auth Testing'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    if (_currentUser != null) ...[
                      const SizedBox(height: 8),
                      Text('User: ${_currentUser!.email}'),
                      Text('Tier: ${_currentUser!.subscriptionTier.displayName}'),
                      Text('Verified: ${_currentUser!.isVerified}'),
                      Text('Active: ${_currentUser!.isSubscriptionActive}'),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Real Authentication Section
            Text(
              '🔐 Real Authentication',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Test Data Section
            Text(
              '🧪 Test Data Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createTestUsers,
              icon: const Icon(Icons.group_add),
              label: const Text('Create Test Users & Signals'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test User Switching
            Text(
              '👥 Switch Test Users',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _switchToTestUser(
                    'test_free_001', 
                    'your.email@gmail.com', 
                    SubscriptionTier.free
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400]),
                  child: const Text('👤 Free'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _switchToTestUser(
                    'test_paid_001', 
                    'paid.user@test.com', 
                    SubscriptionTier.basic
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[400]),
                  child: const Text('💳 Paid'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _switchToTestUser(
                    'test_premium_001', 
                    'premium.user@test.com', 
                    SubscriptionTier.premium
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[400]),
                  child: const Text('⭐ Premium'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _switchToTestUser(
                    'test_pro_001', 
                    'pro.user@test.com', 
                    SubscriptionTier.pro
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[400]),
                  child: const Text('🚀 Pro'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testTierAccess,
              icon: const Icon(Icons.security),
              label: const Text('Test Tier Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Testing Instructions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Use "Sign in with Google" to test real authentication\n'
                      '2. Create test users to simulate different subscription tiers\n'
                      '3. Switch between test users to test access control\n'
                      '4. Use "Test Tier Access" to verify signal filtering\n'
                      '5. Navigate to signal pages to test UI restrictions',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}