import 'package:flutter/material.dart';

void main() {
  runApp(const RiskProfilingDemoApp());
}

class RiskProfilingDemoApp extends StatelessWidget {
  const RiskProfilingDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Risk Profiling System Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FF88),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const RiskProfilingDemoPage(),
    );
  }
}

enum RiskArchetype {
  yolo,
  reasonable,
  conservative,
}

extension RiskArchetypeExtension on RiskArchetype {
  String get displayName {
    switch (this) {
      case RiskArchetype.yolo:
        return 'YOLO';
      case RiskArchetype.reasonable:
        return 'Reasonable';
      case RiskArchetype.conservative:
        return 'Conservative';
    }
  }

  String get description {
    switch (this) {
      case RiskArchetype.yolo:
        return 'Extremely risky favorite, willing to lose all principle to chase for high return';
      case RiskArchetype.reasonable:
        return 'Willing to take some risk but rely on risk reward ratio to make decisions to favor reward';
      case RiskArchetype.conservative:
        return 'Extremely risk aversion, prioritizes capital preservation over high returns';
    }
  }

  int get minRiskScore {
    switch (this) {
      case RiskArchetype.yolo:
        return 70;
      case RiskArchetype.reasonable:
        return 30;
      case RiskArchetype.conservative:
        return 0;
    }
  }

  int get maxRiskScore {
    switch (this) {
      case RiskArchetype.yolo:
        return 100;
      case RiskArchetype.reasonable:
        return 69;
      case RiskArchetype.conservative:
        return 29;
    }
  }
}

enum RiskLevel {
  veryLow,
  low,
  medium,
  high,
  veryHigh,
}

extension RiskLevelExtension on RiskLevel {
  String get displayName {
    switch (this) {
      case RiskLevel.veryLow:
        return 'Very Low';
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
      case RiskLevel.veryHigh:
        return 'Very High';
    }
  }
}

enum SignalType {
  options,
  earnings,
  momentum,
  volume,
  breakout,
  preMarket,
  crypto,
}

extension SignalTypeExtension on SignalType {
  String get displayName {
    switch (this) {
      case SignalType.options:
        return 'Options';
      case SignalType.earnings:
        return 'Earnings';
      case SignalType.momentum:
        return 'Momentum';
      case SignalType.volume:
        return 'Volume Alert';
      case SignalType.breakout:
        return 'Breakout';
      case SignalType.preMarket:
        return 'Pre-Market';
      case SignalType.crypto:
        return 'Crypto';
    }
  }
}

class UserRiskProfile {
  final String userId;
  final RiskArchetype archetype;
  final int riskRewardAppetite;
  final double maxPositionSize;
  final double maxDailyLoss;
  final int maxSignalsPerDay;
  final Map<String, double> riskTolerance;

  UserRiskProfile({
    required this.userId,
    required this.archetype,
    required this.riskRewardAppetite,
    required this.maxPositionSize,
    required this.maxDailyLoss,
    required this.maxSignalsPerDay,
    required this.riskTolerance,
  });

  static UserRiskProfile createDefault({
    required String userId,
    RiskArchetype? archetype,
    int? riskRewardAppetite,
  }) {
    final appetite = riskRewardAppetite ?? 50;
    final defaultArchetype = archetype ?? _determineArchetype(appetite);

    return UserRiskProfile(
      userId: userId,
      archetype: defaultArchetype,
      riskRewardAppetite: appetite,
      maxPositionSize: _getDefaultMaxPositionSize(defaultArchetype),
      maxDailyLoss: _getDefaultMaxDailyLoss(defaultArchetype),
      maxSignalsPerDay: _getDefaultMaxSignalsPerDay(defaultArchetype),
      riskTolerance: _getDefaultRiskTolerance(defaultArchetype),
    );
  }

  static RiskArchetype _determineArchetype(int riskRewardAppetite) {
    if (riskRewardAppetite >= 70) return RiskArchetype.yolo;
    if (riskRewardAppetite >= 30) return RiskArchetype.reasonable;
    return RiskArchetype.conservative;
  }

  static double _getDefaultMaxPositionSize(RiskArchetype archetype) {
    switch (archetype) {
      case RiskArchetype.yolo:
        return 0.50;
      case RiskArchetype.reasonable:
        return 0.20;
      case RiskArchetype.conservative:
        return 0.05;
    }
  }

  static double _getDefaultMaxDailyLoss(RiskArchetype archetype) {
    switch (archetype) {
      case RiskArchetype.yolo:
        return 0.20;
      case RiskArchetype.reasonable:
        return 0.05;
      case RiskArchetype.conservative:
        return 0.02;
    }
  }

  static int _getDefaultMaxSignalsPerDay(RiskArchetype archetype) {
    switch (archetype) {
      case RiskArchetype.yolo:
        return 20;
      case RiskArchetype.reasonable:
        return 10;
      case RiskArchetype.conservative:
        return 3;
    }
  }

  static Map<String, double> _getDefaultRiskTolerance(RiskArchetype archetype) {
    switch (archetype) {
      case RiskArchetype.yolo:
        return {
          '0dte_options': 1.5,
          'momentum': 1.2,
          'breakout': 1.3,
          'earnings': 1.4,
          'swing_trade': 0.8,
        };
      case RiskArchetype.reasonable:
        return {
          '0dte_options': 0.5,
          'momentum': 1.0,
          'breakout': 0.9,
          'earnings': 0.8,
          'swing_trade': 1.1,
        };
      case RiskArchetype.conservative:
        return {
          '0dte_options': 0.1,
          'momentum': 0.6,
          'breakout': 0.5,
          'earnings': 0.4,
          'swing_trade': 1.2,
        };
    }
  }
}

class DemoSignal {
  final String symbol;
  final SignalType type;
  final String title;
  final RiskLevel riskLevel;
  final int riskScore;
  final double riskRewardRatio;
  final String description;

  DemoSignal({
    required this.symbol,
    required this.type,
    required this.title,
    required this.riskLevel,
    required this.riskScore,
    required this.riskRewardRatio,
    required this.description,
  });
}

class RiskProfilingDemoPage extends StatefulWidget {
  const RiskProfilingDemoPage({super.key});

  @override
  State<RiskProfilingDemoPage> createState() => _RiskProfilingDemoPageState();
}

class _RiskProfilingDemoPageState extends State<RiskProfilingDemoPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  RiskArchetype _selectedArchetype = RiskArchetype.reasonable;
  UserRiskProfile? _currentProfile;
  List<DemoSignal> _demoSignals = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _generateDemoSignals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateDemoSignals() {
    _demoSignals = [
      DemoSignal(
        symbol: 'TSLA',
        type: SignalType.options,
        title: '0DTE TSLA Call Options',
        riskLevel: RiskLevel.veryHigh,
        riskScore: 95,
        riskRewardRatio: 3.5,
        description: 'Extremely high-risk 0DTE options play with massive upside potential but total loss risk.',
      ),
      DemoSignal(
        symbol: 'AAPL',
        type: SignalType.earnings,
        title: 'AAPL Earnings Play',
        riskLevel: RiskLevel.high,
        riskScore: 75,
        riskRewardRatio: 2.1,
        description: 'High-risk earnings momentum play with solid fundamentals backing.',
      ),
      DemoSignal(
        symbol: 'SPY',
        type: SignalType.momentum,
        title: 'SPY Momentum Breakout',
        riskLevel: RiskLevel.medium,
        riskScore: 50,
        riskRewardRatio: 1.8,
        description: 'Medium-risk momentum play on broad market ETF with technical confirmation.',
      ),
      DemoSignal(
        symbol: 'VTI',
        type: SignalType.volume,
        title: 'VTI Support Bounce',
        riskLevel: RiskLevel.low,
        riskScore: 25,
        riskRewardRatio: 1.4,
        description: 'Conservative play on total market ETF at strong support level.',
      ),
    ];
  }

  void _createRiskProfile(RiskArchetype archetype) {
    setState(() {
      _selectedArchetype = archetype;
      _currentProfile = UserRiskProfile.createDefault(
        userId: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
        archetype: archetype,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        title: const Text(
          'User Risk Profiling System Demo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00FF88),
          labelColor: const Color(0xFF00FF88),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Archetypes'),
            Tab(text: 'Profile'),
            Tab(text: 'Signals'),
            Tab(text: 'Assessment'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildArchetypesTab(),
          _buildProfileTab(),
          _buildSignalsTab(),
          _buildAssessmentTab(),
        ],
      ),
    );
  }

  Widget _buildArchetypesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Risk Archetypes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your trading personality to get personalized signals with 0-100 risk scoring:',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ...RiskArchetype.values.map((archetype) {
            final isSelected = _selectedArchetype == archetype;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => _createRiskProfile(archetype),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getArchetypeColor(archetype).withValues(alpha: 0.2)
                        : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _getArchetypeColor(archetype)
                          : Colors.grey.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getArchetypeColor(archetype),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getArchetypeIcon(archetype),
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  archetype.displayName,
                                  style: TextStyle(
                                    color: _getArchetypeColor(archetype),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Risk Score: ${archetype.minRiskScore}-${archetype.maxRiskScore}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF00FF88),
                              size: 28,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        archetype.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.3)),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF00FF88)),
                    SizedBox(width: 8),
                    Text(
                      'How Risk Scoring Works',
                      style: TextStyle(
                        color: Color(0xFF00FF88),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '• 0-29: Conservative - Capital preservation focused\n'
                  '• 30-69: Reasonable - Balanced risk/reward approach\n'
                  '• 70-100: YOLO - Maximum risk for maximum reward\n\n'
                  'Your score dynamically adjusts based on signal acceptance patterns!',
                  style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    if (_currentProfile == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select an archetype to create your profile',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getRiskScoreColor(_currentProfile!.riskRewardAppetite).withValues(alpha: 0.3),
                  _getRiskScoreColor(_currentProfile!.riskRewardAppetite).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getRiskScoreColor(_currentProfile!.riskRewardAppetite).withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getArchetypeColor(_currentProfile!.archetype),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _currentProfile!.archetype.displayName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Your Profile',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Risk Score',
                        '${_currentProfile!.riskRewardAppetite}/100',
                        _getRiskScoreColor(_currentProfile!.riskRewardAppetite),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Max Position',
                        '${(_currentProfile!.maxPositionSize * 100).round()}%',
                        const Color(0xFF00D4FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Daily Signals',
                        '${_currentProfile!.maxSignalsPerDay}',
                        const Color(0xFFFFD93D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Risk Tolerance
          const Text(
            '📊 Risk Tolerance by Signal Type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._currentProfile!.riskTolerance.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getToleranceColor(entry.value),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${entry.value.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚡ Dynamic Risk Adjustment',
                  style: TextStyle(
                    color: Color(0xFFFFD93D),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your risk profile automatically adjusts based on your signal acceptance patterns:',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                _buildAdjustmentRow('Accept high-risk signals', '+5-10 points', const Color(0xFFFF4757)),
                _buildAdjustmentRow('Decline low-risk signals', '-2-5 points', const Color(0xFF00FF88)),
                _buildAdjustmentRow('Consistent behavior', 'Archetype upgrade/downgrade', const Color(0xFFFFD93D)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 Demo Trading Signals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentProfile != null
                ? 'Signals filtered for ${_currentProfile!.archetype.displayName} profile (Risk Score: ${_currentProfile!.riskRewardAppetite})'
                : 'Select a profile to see personalized filtering',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ..._demoSignals.map((signal) {
            final isRecommended = _currentProfile?.riskRewardAppetite != null &&
                signal.riskScore <= _currentProfile!.riskRewardAppetite + 20;
            final positionSize = _currentProfile?.maxPositionSize ?? 0.1;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: isRecommended
                    ? Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.6), width: 2)
                    : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getSignalTypeColor(signal.type),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getSignalTypeIcon(signal.type),
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              signal.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              signal.symbol,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      if (isRecommended) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FF88),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.recommend, color: Colors.black, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'MATCH',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4757),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'HIGH RISK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    signal.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  
                  // Risk Metrics Row
                  Row(
                    children: [
                      _buildSignalMetric(
                        'Risk Score',
                        '${signal.riskScore}/100',
                        _getRiskLevelColor(signal.riskLevel),
                      ),
                      const SizedBox(width: 16),
                      _buildSignalMetric(
                        'R/R Ratio',
                        '${signal.riskRewardRatio.toStringAsFixed(1)}:1',
                        const Color(0xFF00D4FF),
                      ),
                      const SizedBox(width: 16),
                      _buildSignalMetric(
                        'Risk Level',
                        signal.riskLevel.displayName,
                        _getRiskLevelColor(signal.riskLevel),
                      ),
                    ],
                  ),
                  
                  if (isRecommended && _currentProfile != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF88).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '✅ Personalized Recommendation',
                            style: TextStyle(
                              color: Color(0xFF00FF88),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Suggested position size: ${(positionSize * 100).toStringAsFixed(0)}% of portfolio\n'
                            'Matches your ${_currentProfile!.archetype.displayName} risk tolerance',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAssessmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔬 Risk Assessment Matrix',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comprehensive risk analysis with statistical scenarios for informed decision making:',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          
          // Risk Levels Chart
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 Risk Level Classification (0-100 Scale)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...RiskLevel.values.map((level) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getRiskLevelColor(level).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getRiskLevelColor(level).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _getRiskLevelColor(level),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            level.displayName,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRiskLevelColor(level),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_getRiskScoreRange(level)}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Demo Statistical Scenarios
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📈 Statistical Scenario Analysis Example',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'TSLA 0DTE Options Signal Analysis:',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                _buildScenarioRow('🚀 Best Case', '+250%', '10%', const Color(0xFF00FF88)),
                _buildScenarioRow('📊 Expected Case', '+50%', '25%', const Color(0xFFFFD93D)),
                _buildScenarioRow('💥 Worst Case', '-100%', '65%', const Color(0xFFFF4757)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard('Expected Value', '-12%', const Color(0xFFFF4757)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard('Max Drawdown', '100%', const Color(0xFFFF4757)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard('Sharpe Ratio', '0.3', const Color(0xFFFFD93D)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Key Features
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎯 Key Features Implemented',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text('✅ Three-tier archetype system (YOLO/Reasonable/Conservative)', 
                     style: TextStyle(color: Colors.grey, fontSize: 14)),
                SizedBox(height: 8),
                Text('✅ Dynamic 0-100 risk scoring system', 
                     style: TextStyle(color: Colors.grey, fontSize: 14)),
                SizedBox(height: 8),
                Text('✅ Statistical scenario analysis (best/expected/worst case)', 
                     style: TextStyle(color: Colors.grey, fontSize: 14)),
                SizedBox(height: 8),
                Text('✅ Behavioral learning and profile adjustment', 
                     style: TextStyle(color: Colors.grey, fontSize: 14)),
                SizedBox(height: 8),
                Text('✅ Personalized signal filtering and recommendations', 
                     style: TextStyle(color: Colors.grey, fontSize: 14)),
                SizedBox(height: 8),
                Text('✅ Risk-reward ratio analysis and position sizing', 
                     style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSignalMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildScenarioRow(String scenario, String returns, String probability, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(scenario, style: const TextStyle(color: Colors.white, fontSize: 15)),
          Text(
            '$returns ($probability chance)',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentRow(String action, String effect, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              action,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Text(
            effect,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Color _getArchetypeColor(RiskArchetype archetype) {
    switch (archetype) {
      case RiskArchetype.yolo:
        return const Color(0xFFFF4757);
      case RiskArchetype.reasonable:
        return const Color(0xFFFFD93D);
      case RiskArchetype.conservative:
        return const Color(0xFF00FF88);
    }
  }

  IconData _getArchetypeIcon(RiskArchetype archetype) {
    switch (archetype) {
      case RiskArchetype.yolo:
        return Icons.rocket_launch;
      case RiskArchetype.reasonable:
        return Icons.balance;
      case RiskArchetype.conservative:
        return Icons.security;
    }
  }

  Color _getRiskScoreColor(int score) {
    if (score >= 70) return const Color(0xFFFF4757);
    if (score >= 40) return const Color(0xFFFFD93D);
    return const Color(0xFF00FF88);
  }

  Color _getToleranceColor(double tolerance) {
    if (tolerance >= 1.2) return const Color(0xFFFF4757);
    if (tolerance >= 0.8) return const Color(0xFFFFD93D);
    return const Color(0xFF00FF88);
  }

  Color _getSignalTypeColor(SignalType type) {
    switch (type) {
      case SignalType.preMarket: return const Color(0xFFFFD93D);
      case SignalType.earnings: return const Color(0xFF95A5A6);
      case SignalType.momentum: return const Color(0xFF00FF88);
      case SignalType.volume: return const Color(0xFF00D4FF);
      case SignalType.breakout: return const Color(0xFFFF6B6B);
      case SignalType.options: return const Color(0xFF9B59B6);
      case SignalType.crypto: return const Color(0xFFF39C12);
    }
  }

  IconData _getSignalTypeIcon(SignalType type) {
    switch (type) {
      case SignalType.preMarket: return Icons.wb_sunny;
      case SignalType.earnings: return Icons.assessment;
      case SignalType.momentum: return Icons.trending_up;
      case SignalType.volume: return Icons.volume_up;
      case SignalType.breakout: return Icons.open_in_full;
      case SignalType.options: return Icons.swap_calls;
      case SignalType.crypto: return Icons.currency_bitcoin;
    }
  }

  Color _getRiskLevelColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.veryLow: return const Color(0xFF2ECC71);
      case RiskLevel.low: return const Color(0xFF00FF88);
      case RiskLevel.medium: return const Color(0xFFFFD93D);
      case RiskLevel.high: return const Color(0xFFF39C12);
      case RiskLevel.veryHigh: return const Color(0xFFFF4757);
    }
  }

  String _getRiskScoreRange(RiskLevel level) {
    switch (level) {
      case RiskLevel.veryLow: return '0-20';
      case RiskLevel.low: return '21-40';
      case RiskLevel.medium: return '41-60';
      case RiskLevel.high: return '61-80';
      case RiskLevel.veryHigh: return '81-100';
    }
  }
}