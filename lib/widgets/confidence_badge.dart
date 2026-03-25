import 'package:flutter/material.dart';

class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({
    super.key,
    required this.score,
    this.compact = false,
  });

  final double score;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = score >= 85
        ? Colors.greenAccent
        : score >= 70
            ? Colors.amberAccent
            : Colors.redAccent;

    final label = score >= 85
        ? 'Alta'
        : score >= 70
            ? 'Moderada'
            : 'Baixa';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        compact ? '${score.toStringAsFixed(0)}%' : '$label • ${score.toStringAsFixed(0)}%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 12 : 13,
        ),
      ),
    );
  }
}
