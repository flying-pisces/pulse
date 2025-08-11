import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  SubscriptionTier? _selectedTier;
  bool _isAnnual = false;

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      tier: SubscriptionTier.free,
      monthlyPrice: 0,
      annualPrice: 0,
      features: [
        'Up to 3 signals per day',
        'Basic market data',
        'Email notifications',
        'Community access',
      ],
      limitations: [
        'Limited signal history',
        'No priority support',
        'Basic analytics only',
      ],
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.basic,
      monthlyPrice: 9.99,
      annualPrice: 99.99,
      features: [
        'Up to 20 signals per day',
        'Real-time market data',
        'Push notifications',
        'Basic portfolio tracking',
        'Email support',
      ],
      isPopular: false,
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.premium,
      monthlyPrice: 19.99,
      annualPrice: 199.99,
      features: [
        'Up to 100 signals per day',
        'Advanced analytics',
        'Custom watchlists',
        'Risk management tools',
        'Priority support',
        'Telegram integration',
      ],
      isPopular: true,
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.pro,
      monthlyPrice: 39.99,
      annualPrice: 399.99,
      features: [
        'Unlimited signals',
        'AI trading insights',
        'Advanced charting tools',
        'API access',
        'White-label reports',
        '24/7 phone support',
        'Personal account manager',
      ],
      isPopular: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Billing Toggle
            _buildBillingToggle(),
            
            // Subscription Plans
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _plans.length,
                itemBuilder: (context, index) => _buildPlanCard(_plans[index]),
              ),
            ),
            
            // Continue Button
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Skip button
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: _skipSubscription,
              child: const Text('Skip for now'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Title
          Text(
            'Choose Your Plan',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms)
              .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'Start your free trial and upgrade anytime',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBillingOption('Monthly', !_isAnnual),
          ),
          Expanded(
            child: _buildBillingOption('Annual (Save 20%)', _isAnnual),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildBillingOption(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAnnual = text.contains('Annual');
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected 
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isSelected = _selectedTier == plan.tier;
    final price = _isAnnual ? plan.annualPrice : plan.monthlyPrice;
    final originalPrice = _isAnnual ? plan.monthlyPrice * 12 : null;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTier = plan.tier;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryColor 
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Plan name and popular badge
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                plan.tier.displayName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (plan.isPopular) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'POPULAR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (plan.tier != SubscriptionTier.free) ...[
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${price.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                Text(
                                  _isAnnual ? '/year' : '/month',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            if (_isAnnual && originalPrice != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Was \$${originalPrice.toStringAsFixed(0)}/year',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ] else ...[
                            const SizedBox(height: 4),
                            Text(
                              'Free Forever',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Selection indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected 
                              ? AppColors.primaryColor 
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected 
                                ? AppColors.primaryColor 
                                : Theme.of(context).colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        child: isSelected 
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Features
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...plan.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppColors.successColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )),
                  if (plan.limitations.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...plan.limitations.map((limitation) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.remove_circle_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              limitation,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (400 + _plans.indexOf(plan) * 100).ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedTier != null ? _continueToDashboard : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _selectedTier == SubscriptionTier.free 
                    ? 'Start Free Trial'
                    : 'Subscribe Now',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Terms text
          Text(
            'By continuing, you agree to our Terms of Service and Privacy Policy',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 800.ms)
        .slideY(begin: 0.3, end: 0);
  }

  void _skipSubscription() {
    context.go('/dashboard');
  }

  void _continueToDashboard() {
    // Here you would typically process the subscription
    // For demo purposes, we'll just navigate to dashboard
    context.go('/dashboard');
  }
}

class SubscriptionPlan {
  final SubscriptionTier tier;
  final double monthlyPrice;
  final double annualPrice;
  final List<String> features;
  final List<String> limitations;
  final bool isPopular;

  SubscriptionPlan({
    required this.tier,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.features,
    this.limitations = const [],
    this.isPopular = false,
  });
}