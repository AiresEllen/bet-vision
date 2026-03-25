import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/football_match.dart';
import '../models/match_analysis.dart';
import '../widgets/confidence_badge.dart';
import '../widgets/section_card.dart';
import '../widgets/stat_chip.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({
    super.key,
    required this.match,
    required this.analysis,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final FootballMatch match;
  final MatchAnalysis analysis;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da análise'),
        actions: [
          IconButton(
            onPressed: onFavoriteToggle,
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFavorite ? Colors.amberAccent : Colors.white70,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TopHero(
            match: match,
            analysis: analysis,
            isFavorite: isFavorite,
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Resumo executivo',
            subtitle: analysis.avoidGame
                ? 'O motor marcou este jogo com sinal de cautela.'
                : 'Leitura principal com cenário aproveitável.',
            child: Text(analysis.summary),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Métricas rápidas',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                StatChip(label: 'Mandante', value: '#${match.home.position}'),
                StatChip(label: 'Visitante', value: '#${match.away.position}'),
                StatChip(label: 'Odd casa', value: match.odds.homeWin.toStringAsFixed(2)),
                StatChip(label: 'Empate', value: match.odds.draw.toStringAsFixed(2)),
                StatChip(label: 'Odd fora', value: match.odds.awayWin.toStringAsFixed(2)),
                StatChip(label: 'Estabilidade', value: '${match.scenarioStability.toStringAsFixed(0)}%'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Mercados sugeridos',
            subtitle: 'Ordenados da melhor para a menor leitura estatística.',
            child: Column(
              children: analysis.insights.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101B27),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.market,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          ConfidenceBadge(score: item.score, compact: true),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Entrada sugerida: ${item.pick}'),
                      const SizedBox(height: 4),
                      Text('Risco estimado: ${item.riskLevel}'),
                      const SizedBox(height: 10),
                      ...item.reasons.map(
                        (reason) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $reason'),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Quebra do score',
            subtitle: 'Quanto cada fator puxou a confiança final.',
            child: Column(
              children: analysis.scoreBreakdown.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(entry.key)),
                          Text('${entry.value.toStringAsFixed(0)}%'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: entry.value / 100,
                        minHeight: 9,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Forma recente',
            child: Row(
              children: [
                _formBlock(context, match.home.name, match.home.recentForm),
                _formBlock(context, match.away.name, match.away.recentForm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formBlock(BuildContext context, String team, String form) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF101B27),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              team,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: form.split('').map((item) {
                final color = item == 'W'
                    ? Colors.greenAccent
                    : item == 'D'
                        ? Colors.amberAccent
                        : Colors.redAccent;
                return CircleAvatar(
                  radius: 15,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(
                    item,
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHero extends StatelessWidget {
  const _TopHero({
    required this.match,
    required this.analysis,
    required this.isFavorite,
  });

  final FootballMatch match;
  final MatchAnalysis analysis;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
            const Color(0xFF0E1823),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConfidenceBadge(score: analysis.topInsight.score),
              _infoChip(match.league),
              _infoChip(DateFormat('dd/MM • HH:mm').format(match.kickoff)),
              if (isFavorite) _infoChip('Favorito'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            match.label,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            '${match.round} • ${match.venue}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analysis.avoidGame ? 'Alerta de cautela' : 'Melhor leitura do motor',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: analysis.avoidGame ? Colors.amberAccent : Colors.white70,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${analysis.topInsight.market}: ${analysis.topInsight.pick}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text),
    );
  }
}
