import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _startAnimations();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _textController.forward();
    });
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Check if user has completed onboarding
        // For now, always go to onboarding for demo
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // Logo Section
            _buildLogo(),
            
            const SizedBox(height: 24),
            
            // App Name and Tagline
            _buildAppName(),
            
            const Spacer(),
            
            // Loading Indicator and Version
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoController.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.trending_up,
              size: 60,
              color: AppColors.primaryColor,
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms)
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: 800.ms,
                curve: Curves.elasticOut,
              )
              .then()
              .shimmer(
                duration: 1000.ms,
                color: Colors.white.withOpacity(0.5),
              ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textController.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _textController.value)),
            child: Column(
              children: [
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
                
                const SizedBox(height: 8),
                
                Text(
                  AppConstants.appTagline,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.8,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 600.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        children: [
          // Loading Indicator
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(delay: 1200.ms, duration: 400.ms),
          ),
          
          const SizedBox(height: 16),
          
          // Version
          Text(
            'Version ${AppConstants.appVersion}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          )
              .animate()
              .fadeIn(delay: 1500.ms, duration: 400.ms),
          
          const SizedBox(height: 8),
          
          // Copyright
          Text(
            '© 2025 Stock Signal AI',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
            ),
          )
              .animate()
              .fadeIn(delay: 1700.ms, duration: 400.ms),
        ],
      ),
    );
  }
}