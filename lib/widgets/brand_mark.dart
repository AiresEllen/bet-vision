import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 24,
    this.compact = false,
  });

  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size * 1.8,
      height: size * 1.8,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15C26B), Color(0xFF6FE8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.6),
      ),
      child: Icon(
        Icons.auto_graph_rounded,
        size: size,
        color: Colors.black,
      ),
    );

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bet Vision',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        if (!compact)
          Text(
            'Análise esportiva orientada por score',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
      ],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(width: 12),
        texts,
      ],
    );
  }
}
