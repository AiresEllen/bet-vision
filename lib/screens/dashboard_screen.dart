import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/analysis_settings.dart';
import '../models/football_match.dart';
import '../models/match_analysis.dart';
import '../repositories/match_repository.dart';
import '../services/analysis_engine.dart';
import '../widgets/match_card.dart';
import 'match_detail_screen.dart';

enum DashboardFilter {
  all('Todos'),
  highConfidence('Alta confiança'),
  stable('Mais estáveis'),
  favorites('Favoritos');

  const DashboardFilter(this.label);
  final String label;
}

enum DashboardDateFilter {
  today('Hoje'),
  tomorrow('Amanhã'),
  week('Semana');

  const DashboardDateFilter(this.label);
  final String label;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.repository,
    required this.engine,
    required this.settings,
    required this.favoriteIds,
    required this.onFavoriteToggle,
    required this.onMatchesLoaded,
    required this.onLogout,
  });

  final MatchRepository repository;
  final AnalysisEngine engine;
  final AnalysisSettings settings;
  final Set<String> favoriteIds;
  final ValueChanged<String> onFavoriteToggle;
  final ValueChanged<List<FootballMatch>> onMatchesLoaded;
  final VoidCallback onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<FootballMatch> _matches = const [];
  bool _isLoading = true;
  String? _errorMessage;
  DashboardFilter _selectedFilter = DashboardFilter.all;
  DashboardDateFilter _selectedDateFilter = DashboardDateFilter.today;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final matches = await widget.repository.getTodayMatches();
      if (!mounted) return;

      setState(() {
        _matches = matches;
      });
      widget.onMatchesLoaded(matches);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Não foi possível atualizar os jogos agora. Verifique a variável API_FOOTBALL_KEY no Netlify e publique novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DateTime _onlyDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _matchesDateFilter(FootballMatch match) {
    final today = _onlyDate(DateTime.now());
    final matchDate = _onlyDate(match.kickoff);
    final diff = matchDate.difference(today).inDays;

    switch (_selectedDateFilter) {
      case DashboardDateFilter.today:
        return diff == 0;
      case DashboardDateFilter.tomorrow:
        return diff == 1;
      case DashboardDateFilter.week:
        return diff >= 0 && diff <= 6;
    }
  }

  Map<String, List<_DashboardEntry>> _groupByLeague(List<_DashboardEntry> items) {
    final grouped = <String, List<_DashboardEntry>>{};

    for (final item in items) {
      final league = item.match.league.trim().isEmpty ? 'Sem campeonato' : item.match.league.trim();
      grouped.putIfAbsent(league, () => []);
      grouped[league]!.add(item);
    }

    final sortedKeys = grouped.keys.toList()..sort();
    return {for (final key in sortedKeys) key: grouped[key]!};
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1380) return 3;
    if (width >= 860) return 2;
    return 1;
  }

  double _getChildAspectRatio(double width) {
    if (width >= 1380) return 1.26;
    if (width >= 860) return 1.16;
    return 1.10;
  }

  @override
  Widget build(BuildContext context) {
    final items = _matches
        .map(
          (match) => _DashboardEntry(
            match: match,
            analysis: widget.engine.analyze(match, widget.settings),
            isFavorite: widget.favoriteIds.contains(match.id),
          ),
        )
        .toList()
      ..sort((a, b) => b.analysis.topInsight.score.compareTo(a.analysis.topInsight.score));

    final normalizedQuery = _searchQuery.trim().toLowerCase();

    final filtered = items.where((item) {
      final matchesMainFilter = switch (_selectedFilter) {
        DashboardFilter.highConfidence => item.analysis.topInsight.score >= 78,
        DashboardFilter.stable => !item.analysis.avoidGame,
        DashboardFilter.favorites => item.isFavorite,
        DashboardFilter.all => true,
      };

      if (!matchesMainFilter) return false;
      if (!_matchesDateFilter(item.match)) return false;

      if (normalizedQuery.isEmpty) return true;

      return item.match.label.toLowerCase().contains(normalizedQuery) ||
          item.match.league.toLowerCase().contains(normalizedQuery) ||
          item.match.home.name.toLowerCase().contains(normalizedQuery) ||
          item.match.away.name.toLowerCase().contains(normalizedQuery);
    }).toList();

    final grouped = _groupByLeague(filtered);
    final highConfidenceCount = filtered.where((item) => item.analysis.topInsight.score >= 78).length;
    final favoritesCount = filtered.where((item) => item.isFavorite).length;
    final stableCount = filtered.where((item) => !item.analysis.avoidGame).length;

    if (_isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = _getCrossAxisCount(width);
          final childAspectRatio = _getChildAspectRatio(width);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              _HeroHeader(
                onLogout: widget.onLogout,
                totalMatches: filtered.length,
                highConfidenceCount: highConfidenceCount,
                favoritesCount: favoritesCount,
                stableCount: stableCount,
              ),
              const SizedBox(height: 18),
              _SearchBar(
                controller: _searchController,
                value: _searchQuery,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: DashboardDateFilter.values.map((filter) {
                    final isSelected = filter == _selectedDateFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(filter.label),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedDateFilter = filter;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: DashboardFilter.values.map((filter) {
                    final isSelected = filter == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(filter.label),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _InlineFeedback(message: _errorMessage!),
              ],
              const SizedBox(height: 20),
              if (grouped.isEmpty)
                const _EmptyListState()
              else
                ...grouped.entries.map((entry) {
                  final leagueItems = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LeagueHeader(
                          title: entry.key,
                          count: leagueItems.length,
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: leagueItems.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemBuilder: (context, index) {
                            final item = leagueItems[index];

                            return MatchCard(
                              match: item.match,
                              analysis: item.analysis,
                              isFavorite: item.isFavorite,
                              onFavoriteToggle: () => widget.onFavoriteToggle(item.match.id),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MatchDetailScreen(
                                      match: item.match,
                                      analysis: item.analysis,
                                      isFavorite: item.isFavorite,
                                      onFavoriteToggle: () => widget.onFavoriteToggle(item.match.id),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.onLogout,
    required this.totalMatches,
    required this.highConfidenceCount,
    required this.favoritesCount,
    required this.stableCount,
  });

  final VoidCallback onLogout;
  final int totalMatches;
  final int highConfidenceCount;
  final int favoritesCount;
  final int stableCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.surfaceAlt, AppTheme.panel],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _heroText(theme)),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: onLogout,
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Sair'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _heroText(theme),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: onLogout,
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Sair'),
                        ),
                      ],
                    );
            },
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatBox(label: 'Jogos visíveis', value: '$totalMatches'),
              _StatBox(label: 'Alta confiança', value: '$highConfidenceCount'),
              _StatBox(label: 'Mais estáveis', value: '$stableCount'),
              _StatBox(label: 'Favoritos', value: '$favoritesCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroText(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'BetVision premium dashboard',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Motivação te faz começar. Disciplina te faz continuar.',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Visual limpo, leitura rápida e partidas separadas por campeonato no estilo que você gostou.',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.value,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    if (controller.text != value) {
      controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar jogo, time ou campeonato',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: value.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: const Color(0xFF111C29),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class _LeagueHeader extends StatelessWidget {
  const _LeagueHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1925),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              size: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count jogo${count > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineFeedback extends StatelessWidget {
  const _InlineFeedback({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _EmptyListState extends StatelessWidget {
  const _EmptyListState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1925),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 30,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum jogo encontrado.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Tente mudar a busca, trocar a data ou atualizar a lista puxando a tela para baixo.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _DashboardEntry {
  const _DashboardEntry({
    required this.match,
    required this.analysis,
    required this.isFavorite,
  });

  final FootballMatch match;
  final MatchAnalysis analysis;
  final bool isFavorite;
}
