import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/models/user_risk_profile.dart';
import 'domain/models/signal_risk_assessment.dart';
import 'data/services/signal_generation_service.dart';

void main() {
  runApp(const ProviderScope(child: RiskProfilingDemoApp()));
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
      _currentProfile = RiskProfileCalculator.createDefaultProfile(
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
          'Risk Profiling System Demo',
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
            'Risk Archetypes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your trading personality to get personalized signals:',
            style: TextStyle(color: Colors.grey),
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
                                    fontSize: 20,
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
                              size: 24,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        archetype.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
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
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Risk Score',
                        '${_currentProfile!.riskRewardAppetite}',
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
            'Risk Tolerance by Signal Type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._currentProfile!.riskTolerance.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getToleranceColor(entry.value),
                      borderRadius: BorderRadius.circular(4),
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
            'Demo Trading Signals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentProfile != null
                ? 'Signals filtered for ${_currentProfile!.archetype.displayName} profile'
                : 'Select a profile to see personalized filtering',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ..._demoSignals.map((signal) {
            final isRecommended = _currentProfile?.riskRewardAppetite != null &&
                signal.riskScore <= _currentProfile!.riskRewardAppetite + 20;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: isRecommended
                    ? Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.5))
                    : null,
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
                          size: 16,
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              signal.symbol,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (isRecommended)
                        const Icon(Icons.recommend, color: Color(0xFF00FF88)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    signal.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildSignalMetric(
                        'Risk',
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
                        'Level',
                        signal.riskLevel.displayName,
                        _getRiskLevelColor(signal.riskLevel),
                      ),
                    ],
                  ),
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
            'Risk Assessment Matrix',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comprehensive risk analysis for informed decision making:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Risk Levels Chart
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
                  'Risk Level Classification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...RiskLevel.values.map((level) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getRiskLevelColor(level),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            level.displayName,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(
                          '${level.scoreRange - 19}-${level.scoreRange}',
                          style: TextStyle(
                            color: _getRiskLevelColor(level),
                            fontWeight: FontWeight.bold,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistical Scenario Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildScenarioRow('Best Case', '+15%', '15%', const Color(0xFF00FF88)),
                _buildScenarioRow('Expected Case', '+5%', '65%', const Color(0xFFFFD93D)),
                _buildScenarioRow('Worst Case', '-8%', '20%', const Color(0xFFFF4757)),
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
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScenarioRow(String scenario, String returns, String probability, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(scenario, style: const TextStyle(color: Colors.white)),
          Text(
            '$returns ($probability probability)',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

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