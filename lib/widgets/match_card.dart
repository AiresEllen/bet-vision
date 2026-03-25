import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../models/football_match.dart';
import '../models/match_analysis.dart';
import 'confidence_badge.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    required this.analysis,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final FootballMatch match;
  final MatchAnalysis analysis;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF101A29),
                const Color(0xFF0C1420),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          match.league,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white70,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: onFavoriteToggle,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                          color: isFavorite ? Colors.amberAccent : Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _TeamLine(name: match.home.name, alignRight: false),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      DateFormat('HH:mm').format(match.kickoff),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _TeamLine(name: match.away.name, alignRight: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.analytics_outlined,
                        label: analysis.topInsight.market,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConfidenceBadge(score: analysis.topInsight.score, compact: true),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  analysis.topInsight.pick,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    analysis.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          height: 1.45,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MiniMetric(
                        label: 'Casa',
                        value: match.home.goalsForAvg.toStringAsFixed(1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniMetric(
                        label: 'Fora',
                        value: match.away.goalsForAvg.toStringAsFixed(1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniMetric(
                        label: 'BTTS',
                        value: '${analysis.topInsight.score.toStringAsFixed(0)}%',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamLine extends StatelessWidget {
  const _TeamLine({required this.name, required this.alignRight});

  final String name;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!alignRight) ...[
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            name,
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        if (alignRight) ...[
          const SizedBox(width: 10),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
