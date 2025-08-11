import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        if (next.error == null) {
          setState(() {
            _emailSent = true;
          });
        } else {
          _showErrorSnackBar(next.error!);
        }
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              if (!_emailSent) ...[
                // Request Reset Form
                _buildRequestForm(authState),
              ] else ...[
                // Success Message
                _buildSuccessMessage(),
              ],
              
              const Spacer(),
              
              // Back to Login
              _buildBackToLogin(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestForm(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        _buildHeader(),
        
        const SizedBox(height: 32),
        
        // Email Form
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  helperText: 'Enter the email associated with your account',
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
              )
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideX(begin: -0.3, end: 0),
              
              const SizedBox(height: 32),
              
              // Send Reset Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleResetRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Send Reset Link',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.lock_reset,
            size: 40,
            color: AppColors.primaryColor,
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: 24),
        
        // Title
        Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Don\'t worry! Enter your email and we\'ll send you a reset link.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 300.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        // Success Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.successColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read,
            size: 50,
            color: AppColors.successColor,
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .then()
            .shimmer(duration: 1000.ms, color: AppColors.successColor.withOpacity(0.3)),
        
        const SizedBox(height: 32),
        
        // Success Title
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.successColor,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 16),
        
        // Success Message
        Text(
          'We\'ve sent a password reset link to:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 300.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 8),
        
        // Email Address
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _emailController.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms),
        
        const SizedBox(height: 24),
        
        // Instructions
        Text(
          'Click the link in the email to reset your password. If you don\'t see it, check your spam folder.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 500.ms),
        
        const SizedBox(height: 32),
        
        // Resend Button
        OutlinedButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Send Again'),
        )
            .animate()
            .fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildBackToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Remember your password? '),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(
            'Back to Login',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: _emailSent ? 700.ms : 600.ms);
  }

  void _handleResetRequest() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).forgotPassword(_emailController.text.trim());
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