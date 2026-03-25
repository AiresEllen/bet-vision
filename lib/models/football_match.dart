class TeamSnapshot {
  const TeamSnapshot({
    required this.name,
    required this.position,
    required this.recentForm,
    required this.goalsForAvg,
    required this.goalsAgainstAvg,
    required this.cornersAvg,
    required this.bttsRate,
    required this.homeAwayStrength,
  });

  final String name;
  final int position;
  final String recentForm;
  final double goalsForAvg;
  final double goalsAgainstAvg;
  final double cornersAvg;
  final double bttsRate;
  final double homeAwayStrength;
}

class MatchOdds {
  const MatchOdds({
    required this.homeWin,
    required this.draw,
    required this.awayWin,
  });

  final double homeWin;
  final double draw;
  final double awayWin;
}

class FootballMatch {
  const FootballMatch({
    required this.id,
    required this.league,
    required this.round,
    required this.venue,
    required this.kickoff,
    required this.home,
    required this.away,
    required this.odds,
    required this.headToHeadHomeEdge,
    required this.scenarioStability,
    required this.oddsMomentumScore,
  });

  final String id;
  final String league;
  final String round;
  final String venue;
  final DateTime kickoff;
  final TeamSnapshot home;
  final TeamSnapshot away;
  final MatchOdds odds;
  final double headToHeadHomeEdge;
  final double scenarioStability;
  final double oddsMomentumScore;

  String get label => '${home.name} x ${away.name}';

  double get averageGoalsProjection =>
      home.goalsForAvg +
      away.goalsForAvg +
      home.goalsAgainstAvg +
      away.goalsAgainstAvg;

  // 🔥 AQUI ESTÁ O QUE FALTAVA
  factory FootballMatch.fromJson(Map<String, dynamic> json) {
    final fixture = json['fixture'] ?? {};
    final teams = json['teams'] ?? {};
    final league = json['league'] ?? {};
    final goals = json['goals'] ?? {};

    return FootballMatch(
      id: fixture['id']?.toString() ?? '',
      league: league['name'] ?? 'Desconhecido',
      round: league['round'] ?? '',
      venue: fixture['venue']?['name'] ?? '',
      kickoff: DateTime.tryParse(fixture['date'] ?? '') ?? DateTime.now(),

      home: TeamSnapshot(
        name: teams['home']?['name'] ?? '',
        position: 0,
        recentForm: '',
        goalsForAvg: 0,
        goalsAgainstAvg: 0,
        cornersAvg: 0,
        bttsRate: 0,
        homeAwayStrength: 0,
      ),

      away: TeamSnapshot(
        name: teams['away']?['name'] ?? '',
        position: 0,
        recentForm: '',
        goalsForAvg: 0,
        goalsAgainstAvg: 0,
        cornersAvg: 0,
        bttsRate: 0,
        homeAwayStrength: 0,
      ),

      odds: const MatchOdds(
        homeWin: 0,
        draw: 0,
        awayWin: 0,
      ),

      headToHeadHomeEdge: 0,
      scenarioStability: 0,
      oddsMomentumScore: 0,
    );
  }
}