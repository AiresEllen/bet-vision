import 'package:flutter/material.dart';

import '../models/analysis_settings.dart';
import '../widgets/section_card.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  final AnalysisSettings settings;
  final ValueChanged<AnalysisSettings> onSettingsChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            _StrategyHero(settings: settings),
            const SizedBox(height: 18),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _PresetSection(onSettingsChanged: onSettingsChanged),
                        const SizedBox(height: 16),
                        _WeightSummary(settings: settings),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SlidersSection(
                      settings: settings,
                      onSettingsChanged: onSettingsChanged,
                    ),
                  ),
                ],
              )
            else ...[
              _PresetSection(onSettingsChanged: onSettingsChanged),
              const SizedBox(height: 16),
              _WeightSummary(settings: settings),
              const SizedBox(height: 16),
              _SlidersSection(
                settings: settings,
                onSettingsChanged: onSettingsChanged,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StrategyHero extends StatelessWidget {
  const _StrategyHero({required this.settings});

  final AnalysisSettings settings;

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
            'Sessão de estratégia',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Agora com blocos bem separados para presets, pesos e leitura do motor.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(label: 'Peso total', value: settings.totalWeight.toStringAsFixed(0)),
              _MetricPill(label: 'Estabilidade', value: settings.stabilityWeight.toStringAsFixed(0)),
              _MetricPill(label: 'Forma', value: settings.formWeight.toStringAsFixed(0)),
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

class _PresetSection extends StatelessWidget {
  const _PresetSection({required this.onSettingsChanged});

  final ValueChanged<AnalysisSettings> onSettingsChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Perfis rápidos',
      subtitle: 'Escolha uma base pronta e depois refine os controles finos abaixo.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _PresetButton(
            title: 'Equilibrado',
            description: 'Boa leitura geral para uso diário.',
            onTap: () => onSettingsChanged(AnalysisSettings.balanced),
          ),
          _PresetButton(
            title: 'Conservador',
            description: 'Dá mais peso à estabilidade do cenário.',
            onTap: () => onSettingsChanged(AnalysisSettings.conservative),
          ),
          _PresetButton(
            title: 'Agressivo',
            description: 'Valoriza forma recente e ataque.',
            onTap: () => onSettingsChanged(AnalysisSettings.aggressive),
          ),
        ],
      ),
    );
  }
}

class _WeightSummary extends StatelessWidget {
  const _WeightSummary({required this.settings});

  final AnalysisSettings settings;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Distribuição atual',
      subtitle:
          'Cada seção do motor agora fica mais fácil de entender visualmente.',
      child: Column(
        children: [
          _WeightLine(label: 'Forma recente', value: settings.formWeight / 40),
          _WeightLine(
            label: 'Ataque e defesa',
            value: settings.attackDefenseWeight / 40,
          ),
          _WeightLine(label: 'Casa e fora', value: settings.homeAwayWeight / 40),
          _WeightLine(label: 'Tabela', value: settings.tableWeight / 40),
          _WeightLine(
            label: 'Confronto direto',
            value: settings.headToHeadWeight / 40,
          ),
          _WeightLine(label: 'Valor e odds', value: settings.oddsValueWeight / 40),
          _WeightLine(label: 'Estabilidade', value: settings.stabilityWeight / 40),
        ],
      ),
    );
  }
}

class _WeightLine extends StatelessWidget {
  const _WeightLine({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(0, 1).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ),
              Text('${(normalized * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: normalized,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}

class _SlidersSection extends StatelessWidget {
  const _SlidersSection({
    required this.settings,
    required this.onSettingsChanged,
  });

  final AnalysisSettings settings;
  final ValueChanged<AnalysisSettings> onSettingsChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Controles finos',
      subtitle:
          'Ajuste o peso de cada critério para um perfil conservador, equilibrado ou agressivo.',
      child: Column(
        children: [
          _slider(
            context,
            'Forma recente',
            'Últimos resultados e consistência.',
            settings.formWeight,
            (value) => onSettingsChanged(settings.copyWith(formWeight: value)),
          ),
          _slider(
            context,
            'Ataque e defesa',
            'Eficiência ofensiva e solidez defensiva.',
            settings.attackDefenseWeight,
            (value) => onSettingsChanged(
              settings.copyWith(attackDefenseWeight: value),
            ),
          ),
          _slider(
            context,
            'Casa e fora',
            'Força de desempenho conforme o mando.',
            settings.homeAwayWeight,
            (value) => onSettingsChanged(settings.copyWith(homeAwayWeight: value)),
          ),
          _slider(
            context,
            'Tabela',
            'Posição e contexto competitivo na liga.',
            settings.tableWeight,
            (value) => onSettingsChanged(settings.copyWith(tableWeight: value)),
          ),
          _slider(
            context,
            'Confronto direto',
            'Histórico do duelo entre as equipes.',
            settings.headToHeadWeight,
            (value) => onSettingsChanged(settings.copyWith(headToHeadWeight: value)),
          ),
          _slider(
            context,
            'Valor e odds',
            'Oscilação do mercado e relação risco/retorno.',
            settings.oddsValueWeight,
            (value) => onSettingsChanged(settings.copyWith(oddsValueWeight: value)),
          ),
          _slider(
            context,
            'Estabilidade',
            'Proteção contra cenários muito voláteis.',
            settings.stabilityWeight,
            (value) => onSettingsChanged(settings.copyWith(stabilityWeight: value)),
          ),
        ],
      ),
    );
  }

  Widget _slider(
    BuildContext context,
    String label,
    String helper,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: 0,
            max: 40,
            divisions: 40,
            label: value.toStringAsFixed(0),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: OutlinedButton(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
