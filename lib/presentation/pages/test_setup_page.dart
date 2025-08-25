import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/pocketbase_service.dart';
import '../../core/constants/env_config.dart';

/// Test setup page to validate PocketBase connection and basic functionality
class TestSetupPage extends ConsumerStatefulWidget {
  const TestSetupPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TestSetupPage> createState() => _TestSetupPageState();
}

class _TestSetupPageState extends ConsumerState<TestSetupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  bool _isLoading = false;
  String _statusMessage = '';
  bool _isRegistering = false;
  
  @override
  void initState() {
    super.initState();
    _testPocketBaseConnection();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _testPocketBaseConnection() async {
    setState(() {
      _statusMessage = 'Testing PocketBase connection...';
    });

    try {
      final pocketBaseService = ref.read(pocketBaseServiceProvider);
      final isHealthy = await pocketBaseService.healthCheck();
      
      setState(() {
        _statusMessage = isHealthy 
          ? '✅ PocketBase connection successful!' 
          : '❌ PocketBase health check failed';
      });
    } catch (error) {
      setState(() {
        _statusMessage = '❌ PocketBase connection failed: ${error.toString()}';
      });
    }
  }

  Future<void> _testSignUp() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty) {
      setState(() {
        _statusMessage = '❌ Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating account...';
    });

    try {
      final pocketBaseService = ref.read(pocketBaseServiceProvider);
      
      final user = await pocketBaseService.registerWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      setState(() {
        _statusMessage = '✅ Account created successfully!\nUser ID: ${user.id}\nEmail: ${user.data['email']}';
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _statusMessage = '❌ Sign up failed: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _statusMessage = '❌ Please enter email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Signing in...';
    });

    try {
      final pocketBaseService = ref.read(pocketBaseServiceProvider);
      
      final authData = await pocketBaseService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() {
        _statusMessage = '✅ Sign in successful!\nUser: ${authData.record.data['email']}\nToken: ${authData.token.substring(0, 20)}...';
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _statusMessage = '❌ Sign in failed: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignOut() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Signing out...';
    });

    try {
      final pocketBaseService = ref.read(pocketBaseServiceProvider);
      await pocketBaseService.signOut();

      setState(() {
        _statusMessage = '✅ Signed out successfully';
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _statusMessage = '❌ Sign out failed: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestSignal() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating test signal...';
    });

    try {
      final pocketBaseService = ref.read(pocketBaseServiceProvider);
      
      if (!pocketBaseService.isAuthenticated) {
        setState(() {
          _statusMessage = '❌ Please sign in first to create signals';
          _isLoading = false;
        });
        return;
      }

      final signalData = {
        'symbol': 'AAPL',
        'companyName': 'Apple Inc.',
        'type': 'stock',
        'action': 'buy',
        'currentPrice': 150.25,
        'targetPrice': 165.0,
        'stopLoss': 140.0,
        'confidence': 0.8,
        'reasoning': 'Strong earnings report and positive analyst upgrades. Technical indicators show bullish momentum.',
        'status': 'active',
        'tags': ['tech', 'earnings', 'bullish'],
        'requiredTier': 'free',
      };

      final signal = await pocketBaseService.createSignal(signalData);

      setState(() {
        _statusMessage = '✅ Test signal created!\nSignal ID: ${signal.id}\nSymbol: ${signal.data['symbol']}';
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _statusMessage = '❌ Signal creation failed: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSignals() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading signals...';
    });

    try {
      final pocketBaseService = ref.read(pocketBaseServiceProvider);
      
      final signals = await pocketBaseService.getSignals(perPage: 5);

      setState(() {
        _statusMessage = '✅ Loaded ${signals.items.length} signals\n' +
          signals.items.map((s) => '• ${s.data['symbol']}: ${s.data['action']}').join('\n');
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _statusMessage = '❌ Load signals failed: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse Setup Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Configuration Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    _buildConfigItem('PocketBase URL', EnvConfig.pocketbaseUrl),
                    _buildConfigItem('Alpaca Credentials', EnvConfig.hasAlpacaCredentials ? '✅ Configured' : '❌ Missing'),
                    _buildConfigItem('App Environment', EnvConfig.appEnv),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Authentication Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authentication Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    authState.when(
                      data: (user) => user != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('✅ Signed in as: ${user.data['email'] ?? 'No email'}'),
                              Text('User ID: ${user.id}'),
                              Text('Subscription: ${user.data['subscriptionTier'] ?? 'free'}'),
                            ],
                          )
                        : const Text('❌ Not signed in'),
                      loading: () => const Text('🔄 Checking authentication...'),
                      error: (error, _) => Text('❌ Auth error: $error'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Forms
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _isRegistering ? 'Sign Up' : 'Sign In',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isRegistering = !_isRegistering;
                              _statusMessage = '';
                            });
                          },
                          child: Text(_isRegistering ? 'Switch to Sign In' : 'Switch to Sign Up'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Email field
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    // Password field
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),

                    // Additional fields for registration
                    if (_isRegistering) ...[
                      TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : (_isRegistering ? _testSignUp : _testSignIn),
                            child: Text(_isRegistering ? 'Sign Up' : 'Sign In'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _testSignOut,
                            child: const Text('Sign Out'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Signal Testing
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signal Testing',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createTestSignal,
                            child: const Text('Create Test Signal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _loadSignals,
                            child: const Text('Load Signals'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Results',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 12),
                          Text('Running test...'),
                        ],
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          _statusMessage.isEmpty ? 'No tests run yet' : _statusMessage,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _testPocketBaseConnection,
                          icon: const Icon(Icons.health_and_safety),
                          label: const Text('Test Connection'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _emailController.text = 'test@pulse.com';
                              _passwordController.text = 'test123456';
                              _firstNameController.text = 'Test';
                              _lastNameController.text = 'User';
                            });
                          },
                          icon: const Icon(Icons.auto_fix_high),
                          label: const Text('Fill Test Data'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _emailController.clear();
                              _passwordController.clear();
                              _firstNameController.clear();
                              _lastNameController.clear();
                              _statusMessage = '';
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Form'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}