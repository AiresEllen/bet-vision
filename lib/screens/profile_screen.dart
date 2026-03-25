import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/section_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.authService,
    required this.onLogout,
    required this.demoMode,
    required this.favoriteCount,
    required this.usingLiveData,
  });

  final AuthService authService;
  final VoidCallback onLogout;
  final bool demoMode;
  final int favoriteCount;
  final bool usingLiveData;

  @override
  Widget build(BuildContext context) {
    final email = authService.currentSession?.user.email;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;
        final spacing = isWide ? 18.0 : 16.0;
        final summaryCards = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              label: 'Conta',
              value: demoMode ? 'Demo' : 'Premium',
              icon: Icons.workspace_premium_rounded,
            ),
            _SummaryCard(
              label: 'Favoritos',
              value: '$favoriteCount',
              icon: Icons.star_rounded,
            ),
            _SummaryCard(
              label: 'Dados',
              value: usingLiveData ? 'API ao vivo' : 'Base local',
              icon: Icons.cloud_done_rounded,
            ),
          ],
        );

        final content = <Widget>[
          Text(
            'Conta e experiência',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tudo centralizado em sessões mais claras para celular, tablet e desktop.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 18),
          summaryCards,
          const SizedBox(height: 18),
        ];

        if (isWide) {
          content.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SectionCard(
                        title: 'Identidade da conta',
                        subtitle: 'Status atual da sessão e credenciais disponíveis.',
                        child: Column(
                          children: [
                            _InfoRow(
                              label: 'Modo de acesso',
                              value: demoMode ? 'Demonstração' : 'Conta autenticada',
                            ),
                            _InfoRow(
                              label: 'E-mail',
                              value: email ?? 'Sem login de e-mail no modo demo',
                            ),
                            _InfoRow(
                              label: 'Supabase',
                              value: authService.isConfigured
                                  ? 'Configurado'
                                  : 'Não configurado',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing),
                      SectionCard(
                        title: 'Qualidade de experiência',
                        subtitle: 'Como a interface foi reorganizada por formato de tela.',
                        child: const Column(
                          children: [
                            _ExperienceTile(
                              icon: Icons.phone_iphone_rounded,
                              title: 'iPhone e Android',
                              description: 'Navegação inferior com foco total no conteúdo e cards mais limpos.',
                            ),
                            SizedBox(height: 12),
                            _ExperienceTile(
                              icon: Icons.tablet_mac_rounded,
                              title: 'Tablet',
                              description: 'NavigationRail lateral para ganhar espaço e separar sessões.',
                            ),
                            SizedBox(height: 12),
                            _ExperienceTile(
                              icon: Icons.desktop_windows_rounded,
                              title: 'Desktop',
                              description: 'Sidebar premium com contexto, navegação e painel lateral de apoio.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Column(
                    children: [
                      SectionCard(
                        title: 'Organização premium',
                        subtitle: 'Mudanças aplicadas para reduzir poluição visual.',
                        child: const Column(
                          children: [
                            _ChecklistItem(text: 'Sessões laterais bem definidas em telas maiores'),
                            _ChecklistItem(text: 'Cards com mais respiro e hierarquia visual'),
                            _ChecklistItem(text: 'Resumo de contexto sempre visível no desktop'),
                            _ChecklistItem(text: 'Estrutura adaptável entre mobile, tablet e PC'),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing),
                      SectionCard(
                        title: 'Ações rápidas',
                        subtitle: 'Gerencie a sessão atual sem sair do painel.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FilledButton.icon(
                              onPressed: onLogout,
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('Sair da sessão'),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Se estiver em modo demo, você pode retornar à tela inicial e entrar com outra conta quando quiser.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          content.addAll([
            SectionCard(
              title: 'Identidade da conta',
              subtitle: 'Status atual da sessão e credenciais disponíveis.',
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Modo de acesso',
                    value: demoMode ? 'Demonstração' : 'Conta autenticada',
                  ),
                  _InfoRow(
                    label: 'E-mail',
                    value: email ?? 'Sem login de e-mail no modo demo',
                  ),
                  _InfoRow(
                    label: 'Fonte de dados',
                    value: usingLiveData ? 'API ao vivo' : 'Base local',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Experiência por dispositivo',
              subtitle: 'Cada tela agora recebeu uma organização mais limpa.',
              child: const Column(
                children: [
                  _ExperienceTile(
                    icon: Icons.phone_iphone_rounded,
                    title: 'Celular',
                    description: 'Fluxo enxuto com foco total nas partidas e favoritos.',
                  ),
                  SizedBox(height: 12),
                  _ExperienceTile(
                    icon: Icons.tablet_mac_rounded,
                    title: 'Tablet',
                    description: 'Navegação lateral e melhor aproveitamento de largura.',
                  ),
                  SizedBox(height: 12),
                  _ExperienceTile(
                    icon: Icons.desktop_windows_rounded,
                    title: 'Desktop',
                    description: 'Sessões laterais e cartões de contexto premium.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Ações rápidas',
              subtitle: 'Gerencie sua sessão atual.',
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sair da sessão'),
                ),
              ),
            ),
          ]);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: content,
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101B27),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceTile extends StatelessWidget {
  const _ExperienceTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
