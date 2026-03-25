import 'package:flutter/material.dart';

import '../models/analysis_settings.dart';
import '../models/football_match.dart';
import '../services/analysis_engine.dart';
import '../widgets/match_card.dart';
import 'match_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.matches,
    required this.engine,
    required this.settings,
    required this.favoriteIds,
    required this.onFavoriteToggle,
  });

  final List<FootballMatch> matches;
  final AnalysisEngine engine;
  final AnalysisSettings settings;
  final Set<String> favoriteIds;
  final ValueChanged<String> onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final favoriteMatches = matches.where((item) => favoriteIds.contains(item.id)).toList()
      ..sort((a, b) => a.kickoff.compareTo(b.kickoff));

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1350
            ? 3
            : width >= 820
                ? 2
                : 1;
        final childAspectRatio = width >= 1350
            ? 1.38
            : width >= 820
                ? 1.18
                : 1.02;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            _FavoritesHero(
              favoriteCount: favoriteIds.length,
              loadedMatches: matches.length,
            ),
            const SizedBox(height: 18),
            if (favoriteIds.isEmpty)
              const _FavoritesEmptyState(
                title: 'Você ainda não salvou nenhum jogo.',
                description:
                    'Abra a sessão Jogos e toque na estrela para montar sua shortlist premium.',
              )
            else if (matches.isEmpty)
              const _FavoritesEmptyState(
                title: 'Os favoritos estão guardados, mas a lista do dia ainda não foi carregada.',
                description:
                    'Abra a sessão Jogos para atualizar as partidas e preencher esta tela automaticamente.',
              )
            else if (favoriteMatches.isEmpty)
              const _FavoritesEmptyState(
                title: 'Os favoritos não aparecem na grade atual.',
                description:
                    'Isso pode acontecer quando a programação do dia muda. Atualize a lista principal para sincronizar.',
              )
            else ...[
              _SectionHeader(count: favoriteMatches.length),
              const SizedBox(height: 14),
              GridView.builder(
                itemCount: favoriteMatches.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  final match = favoriteMatches[index];
                  final analysis = engine.analyze(match, settings);
                  return MatchCard(
                    match: match,
                    analysis: analysis,
                    isFavorite: true,
                    onFavoriteToggle: () => onFavoriteToggle(match.id),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MatchDetailScreen(
                            match: match,
                            analysis: analysis,
                            isFavorite: true,
                            onFavoriteToggle: () => onFavoriteToggle(match.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _FavoritesHero extends StatelessWidget {
  const _FavoritesHero({
    required this.favoriteCount,
    required this.loadedMatches,
  });

  final int favoriteCount;
  final int loadedMatches;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1622),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sessão de favoritos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Uma área mais limpa para acompanhar apenas os confrontos que merecem atenção.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(label: 'Favoritos', value: '$favoriteCount'),
              _MetricPill(label: 'Jogos carregados', value: '$loadedMatches'),
              const _MetricPill(label: 'Organização', value: 'Premium'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1925),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_added_rounded, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sua shortlist',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Text(
            '$count jogo${count > 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesEmptyState extends StatelessWidget {
  const _FavoritesEmptyState({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1925),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          const Icon(Icons.bookmark_added_outlined, size: 36, color: Colors.white70),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}
