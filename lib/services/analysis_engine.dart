import 'dart:math';

import '../models/analysis_settings.dart';
import '../models/football_match.dart';
import '../models/match_analysis.dart';

class AnalysisEngine {
  MatchAnalysis analyze(FootballMatch match, AnalysisSettings settings) {
    final homeForm = _formScore(match.home.recentForm);
    final awayForm = _formScore(match.away.recentForm);
    final formScore = _normalize(50 + ((homeForm - awayForm) * 0.5));

    final homeAttackDefense =
        (match.home.goalsForAvg * 30) - (match.home.goalsAgainstAvg * 20);
    final awayAttackDefense =
        (match.away.goalsForAvg * 30) - (match.away.goalsAgainstAvg * 20);
    final attackDefenseScore =
        _normalize(50 + (homeAttackDefense - awayAttackDefense));

    final homeAwayScore = _normalize(
      50 + ((match.home.homeAwayStrength - match.away.homeAwayStrength) * 0.5),
    );

    final tableScore = _normalize(
      50 + ((match.away.position - match.home.position) * 3.5),
    );

    final headToHeadScore = match.headToHeadHomeEdge;
    final oddsValueScore = match.oddsMomentumScore;
    final stabilityScore = match.scenarioStability;

    final overallHomeLean = _weightedScore(
      {
        'Forma': formScore,
        'Ataque/Defesa': attackDefenseScore,
        'Casa/Fora': homeAwayScore,
        'Tabela': tableScore,
        'Confronto Direto': headToHeadScore,
        'Valor/Odds': oddsValueScore,
        'Estabilidade': stabilityScore,
      },
      settings,
    );

    final goalProjection = _normalize(
      ((match.home.goalsForAvg + match.away.goalsForAvg) * 22) +
          ((match.home.goalsAgainstAvg + match.away.goalsAgainstAvg) * 14),
    );

    final bttsProjection = _normalize(
      (((match.home.bttsRate + match.away.bttsRate) / 2) * 100) +
          ((match.home.goalsForAvg + match.away.goalsForAvg) * 8),
    );

    final diff = overallHomeLean - 50;
    final doubleChanceScore = _normalize(68 + diff.abs() * 0.8);
    final doubleChancePick = diff >= 0 ? '1X' : 'X2';

    final over15Score = _normalize(goalProjection + 6);
    final over25Score = _normalize(goalProjection - 4);
    final bttsScore = _normalize(bttsProjection - 2);

    final insights = <MarketInsight>[
      MarketInsight(
        market: 'Dupla chance',
        pick: doubleChancePick,
        score: doubleChanceScore,
        riskLevel: _riskLabel(doubleChanceScore),
        reasons: [
          'Diferença de força estatística entre os times',
          'Leitura combinada de forma, tabela e mando',
        ],
      ),
      MarketInsight(
        market: 'Over 1.5 gols',
        pick: 'Mais de 1.5 gols',
        score: over15Score,
        riskLevel: _riskLabel(over15Score),
        reasons: [
          'Boa projeção de gols marcados e sofridos',
          'Mercado geralmente mais estável que placar exato',
        ],
      ),
      MarketInsight(
        market: 'Over 2.5 gols',
        pick: 'Mais de 2.5 gols',
        score: over25Score,
        riskLevel: _riskLabel(over25Score),
        reasons: [
          'Média ofensiva compatível com jogo aberto',
          'Cenário com potencial de troca de gols',
        ],
      ),
      MarketInsight(
        market: 'Ambas marcam',
        pick: 'Sim',
        score: bttsScore,
        riskLevel: _riskLabel(bttsScore),
        reasons: [
          'Taxa de BTTS aceitável para os dois lados',
          'Defesas cedem espaços em frequência relevante',
        ],
      ),
    ]..sort((a, b) => b.score.compareTo(a.score));

    final topInsight = insights.first;
    final avoidGame = topInsight.score < 65 || stabilityScore < 45;

    final summary = avoidGame
        ? 'Jogo com cenário mais instável. Melhor reduzir exposição ou evitar entradas agressivas.'
        : 'Melhor leitura estatística em ${topInsight.market.toLowerCase()} com tendência para ${topInsight.pick}.';

    return MatchAnalysis(
      topInsight: topInsight,
      insights: insights,
      summary: summary,
      scoreBreakdown: {
        'Forma': formScore,
        'Ataque/Defesa': attackDefenseScore,
        'Casa/Fora': homeAwayScore,
        'Tabela': tableScore,
        'Confronto Direto': headToHeadScore,
        'Valor/Odds': oddsValueScore,
        'Estabilidade': stabilityScore,
      },
      avoidGame: avoidGame,
    );
  }

  double _formScore(String form) {
    final values = form.split('').map((item) {
      switch (item.toUpperCase()) {
        case 'W':
          return 1.0;
        case 'D':
          return 0.5;
        default:
          return 0.0;
      }
    }).toList();

    if (values.isEmpty) return 50;
    // Returns 0–100 (0 = all losses, 100 = all wins)
    return (values.reduce((a, b) => a + b) / values.length) * 100;
  }

  double _weightedScore(
    Map<String, double> breakdown,
    AnalysisSettings settings,
  ) {
    final weights = {
      'Forma': settings.formWeight,
      'Ataque/Defesa': settings.attackDefenseWeight,
      'Casa/Fora': settings.homeAwayWeight,
      'Tabela': settings.tableWeight,
      'Confronto Direto': settings.headToHeadWeight,
      'Valor/Odds': settings.oddsValueWeight,
      'Estabilidade': settings.stabilityWeight,
    };

    var total = 0.0;
    for (final entry in breakdown.entries) {
      total += entry.value * ((weights[entry.key] ?? 0) / settings.totalWeight);
    }
    return total;
  }

  double _normalize(double value) => min(100, max(0, value));

  String _riskLabel(double score) {
    if (score >= 85) return 'Baixo';
    if (score >= 70) return 'Médio';
    return 'Alto';
  }
}
