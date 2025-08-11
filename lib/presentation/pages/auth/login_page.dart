import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/dashboard');
      } else if (next.error != null) {
        _showErrorSnackBar(next.error!);
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Header
              _buildHeader(),
              
              const SizedBox(height: 32),
              
              // OAuth Login Section (Prominent)
              _buildOAuthLogin(authState),
              
              const SizedBox(height: 32),
              
              // Divider with "Or" text
              _buildDivider(),
              
              const SizedBox(height: 24),
              
              // Email Login Section (Secondary)
              _buildEmailLogin(authState),
              
              const SizedBox(height: 32),
              
              // Sign Up Link
              _buildSignUpLink(),
              
              const SizedBox(height: 24),
              
              // Demo Instructions
              _buildDemoInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.trending_up,
            size: 40,
            color: Colors.white,
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: 24),
        
        // Welcome Text
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 8),
        
        Text(
          'Sign in to access your trading signals',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildOAuthLogin(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Google Sign In Button
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: authState.isLoading ? null : _handleGoogleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[800],
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(
              Icons.g_mobiledata,
              size: 24,
              color: Colors.red,
            ),
            label: authState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        )
            .animate()
            .fadeIn(delay: 600.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 16),
        
        // Apple Sign In Button
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: authState.isLoading ? null : _handleAppleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(
              Icons.apple,
              size: 24,
              color: Colors.white,
            ),
            label: authState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Continue with Apple',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        )
            .animate()
            .fadeIn(delay: 700.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or sign in with email',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    )
        .animate()
        .fadeIn(delay: 800.ms);
  }

  Widget _buildEmailLogin(AuthState authState) {
    return ExpansionTile(
      title: Text(
        'Sign in with Email',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryColor,
        ),
      ),
      leading: Icon(
        Icons.email_outlined,
        color: AppColors.primaryColor,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Login Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleEmailLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Sign In with Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 900.ms);
  }


  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
          onPressed: () => context.push('/register'),
          child: const Text(
            'Sign Up',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 1100.ms);
  }

  Widget _buildDemoInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.infoColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.infoColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Demo Account',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Email: demo@stocksignal.ai\nPassword: password',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.infoColor,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 1200.ms);
  }

  void _handleGoogleSignIn() {
    ref.read(authProvider.notifier).signInWithGoogle();
  }

  void _handleAppleSignIn() {
    ref.read(authProvider.notifier).signInWithApple();
  }

  void _handleEmailLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}