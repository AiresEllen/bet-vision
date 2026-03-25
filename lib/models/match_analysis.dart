class MarketInsight {
  const MarketInsight({
    required this.market,
    required this.pick,
    required this.score,
    required this.riskLevel,
    required this.reasons,
  });

  final String market;
  final String pick;
  final double score;
  final String riskLevel;
  final List<String> reasons;
}

class MatchAnalysis {
  const MatchAnalysis({
    required this.topInsight,
    required this.insights,
    required this.summary,
    required this.scoreBreakdown,
    required this.avoidGame,
  });

  final MarketInsight topInsight;
  final List<MarketInsight> insights;
  final String summary;
  final Map<String, double> scoreBreakdown;
  final bool avoidGame;
}
