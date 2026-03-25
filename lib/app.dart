import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'models/analysis_settings.dart';
import 'models/football_match.dart';
import 'repositories/match_repository.dart';
import 'screens/admin_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'services/analysis_engine.dart';
import 'services/auth_service.dart';
import 'services/local_storage_service.dart';
import 'widgets/brand_mark.dart';

class BetVisionApp extends StatefulWidget {
  const BetVisionApp({super.key});

  @override
  State<BetVisionApp> createState() => _BetVisionAppState();
}

class _BetVisionAppState extends State<BetVisionApp> {
  final _authService = AuthService();
  final _repository = MatchRepository();
  final _analysisEngine = AnalysisEngine();
  final _storageService = LocalStorageService();

  Set<String> _favoriteIds = <String>{};
  AnalysisSettings _settings = const AnalysisSettings();
  List<FootballMatch> _latestMatches = const [];

  bool _demoMode = false;
  bool _isReady = false;
  int _currentIndex = 0;

  bool get _isLoggedIn => _demoMode || _authService.currentSession != null;

  @override
  void initState() {
    super.initState();
    _restoreLocalState();
  }

  Future<void> _restoreLocalState() async {
    final favoriteIds = await _storageService.loadFavoriteIds();
    final settings = await _storageService.loadAnalysisSettings();

    if (!mounted) return;
    setState(() {
      _favoriteIds = favoriteIds;
      _settings = settings;
      _isReady = true;
    });
  }

  Future<void> _toggleFavorite(String id) async {
    final updated = Set<String>.from(_favoriteIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }

    setState(() {
      _favoriteIds = updated;
    });

    await _storageService.saveFavoriteIds(updated);
  }

  Future<void> _updateSettings(AnalysisSettings newValue) async {
    setState(() {
      _settings = newValue;
    });

    await _storageService.saveAnalysisSettings(newValue);
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (!mounted) return;

    setState(() {
      _demoMode = false;
      _currentIndex = 0;
    });
  }

  void _cacheMatches(List<FootballMatch> matches) {
    setState(() {
      _latestMatches = matches;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bet Vision',
      theme: AppTheme.dark(),
      home: _isReady
          ? (_isLoggedIn
              ? _AppHome(
                  authService: _authService,
                  repository: _repository,
                  engine: _analysisEngine,
                  settings: _settings,
                  favoriteIds: _favoriteIds,
                  latestMatches: _latestMatches,
                  currentIndex: _currentIndex,
                  demoMode: _demoMode,
                  onFavoriteToggle: _toggleFavorite,
                  onSettingsChanged: _updateSettings,
                  onLogout: _logout,
                  onNavigate: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  onMatchesLoaded: _cacheMatches,
                )
              : LoginScreen(
                  authService: _authService,
                  onLoggedIn: () => setState(() {}),
                  onContinueDemo: () => setState(() => _demoMode = true),
                ))
          : const _LoadingSplash(),
    );
  }
}

class _AppHome extends StatelessWidget {
  const _AppHome({
    required this.authService,
    required this.repository,
    required this.engine,
    required this.settings,
    required this.favoriteIds,
    required this.latestMatches,
    required this.currentIndex,
    required this.demoMode,
    required this.onFavoriteToggle,
    required this.onSettingsChanged,
    required this.onLogout,
    required this.onNavigate,
    required this.onMatchesLoaded,
  });

  final AuthService authService;
  final MatchRepository repository;
  final AnalysisEngine engine;
  final AnalysisSettings settings;
  final Set<String> favoriteIds;
  final List<FootballMatch> latestMatches;
  final int currentIndex;
  final bool demoMode;
  final ValueChanged<String> onFavoriteToggle;
  final ValueChanged<AnalysisSettings> onSettingsChanged;
  final VoidCallback onLogout;
  final ValueChanged<int> onNavigate;
  final ValueChanged<List<FootballMatch>> onMatchesLoaded;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(
        repository: repository,
        engine: engine,
        settings: settings,
        favoriteIds: favoriteIds,
        onFavoriteToggle: onFavoriteToggle,
        onMatchesLoaded: onMatchesLoaded,
        onLogout: onLogout,
      ),
      FavoritesScreen(
        matches: latestMatches,
        engine: engine,
        settings: settings,
        favoriteIds: favoriteIds,
        onFavoriteToggle: onFavoriteToggle,
      ),
      AdminScreen(
        settings: settings,
        onSettingsChanged: onSettingsChanged,
      ),
      ProfileScreen(
        authService: authService,
        onLogout: onLogout,
        demoMode: demoMode,
        favoriteCount: favoriteIds.length,
        usingLiveData: repository.usesLiveApi,
      ),
    ];

    const destinations = [
      _ShellDestination(
        label: 'Jogos',
        title: 'Central de análises',
        subtitle:
            'Jogos organizados por campeonato com leitura rápida e menos ruído visual.',
        icon: Icons.space_dashboard_outlined,
        selectedIcon: Icons.space_dashboard_rounded,
      ),
      _ShellDestination(
        label: 'Favoritos',
        title: 'Sessão de acompanhamento',
        subtitle:
            'Acompanhe apenas as partidas que importam para sua rotina.',
        icon: Icons.star_border_rounded,
        selectedIcon: Icons.star_rounded,
      ),
      _ShellDestination(
        label: 'Estratégia',
        title: 'Sessão de estratégia',
        subtitle:
            'Ajuste pesos, refine o motor e monte um perfil premium de leitura.',
        icon: Icons.tune_outlined,
        selectedIcon: Icons.tune_rounded,
      ),
      _ShellDestination(
        label: 'Perfil',
        title: 'Conta e ambiente',
        subtitle:
            'Resumo da conta, acesso e experiência entre celular, tablet e desktop.',
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
      ),
    ];

    final currentDestination = destinations[currentIndex];
    final accountLabel = demoMode
        ? 'Modo demonstração'
        : (authService.currentSession?.user.email ?? 'Conta conectada');

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1280;
        final isTablet = width >= 900 && width < 1280;

        if (isDesktop) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DesktopSidePanel(
                      currentIndex: currentIndex,
                      destinations: destinations,
                      onNavigate: onNavigate,
                      accountLabel: accountLabel,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          _WorkspaceTopBar(
                            destination: currentDestination,
                            compact: false,
                            accountLabel: accountLabel,
                            liveLabel:
                                repository.usesLiveApi ? 'API ao vivo' : 'Base local',
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: _MainWorkspace(
                              currentIndex: currentIndex,
                              pages: pages,
                              borderRadius: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 310,
                      child: _RightContextPanel(
                        currentTitle: currentDestination.title,
                        favoriteCount: favoriteIds.length,
                        matchCount: latestMatches.length,
                        demoMode: demoMode,
                        settings: settings,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (isTablet) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TabletNavigationRail(
                    currentIndex: currentIndex,
                    destinations: destinations,
                    onNavigate: onNavigate,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                      child: Column(
                        children: [
                          _WorkspaceTopBar(
                            destination: currentDestination,
                            compact: true,
                            accountLabel: accountLabel,
                            liveLabel:
                                repository.usesLiveApi ? 'API ao vivo' : 'Base local',
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _MainWorkspace(
                              currentIndex: currentIndex,
                              pages: pages,
                              borderRadius: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 76,
            titleSpacing: 16,
            title: Row(
              children: [
                const _BrandSquare(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bet Vision',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentDestination.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _HeaderChip(
                  label: 'Fonte',
                  value: repository.usesLiveApi ? 'API' : 'Local',
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Container(
              color: const Color(0xFF081018),
              child: IndexedStack(
                index: currentIndex,
                children: pages.map((page) {
                  return Container(
                    color: const Color(0xFF081018),
                    child: page,
                  );
                }).toList(),
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onNavigate,
            destinations: destinations
                .map(
                  (item) => NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _MainWorkspace extends StatelessWidget {
  const _MainWorkspace({
    required this.currentIndex,
    required this.pages,
    required this.borderRadius,
  });

  final int currentIndex;
  final List<Widget> pages;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF081018),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: IndexedStack(
          index: currentIndex,
          children: pages.map((page) {
            return Container(
              color: const Color(0xFF081018),
              child: page,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final IconData selectedIcon;
}

class _DesktopSidePanel extends StatelessWidget {
  const _DesktopSidePanel({
    required this.currentIndex,
    required this.destinations,
    required this.onNavigate,
    required this.accountLabel,
  });

  final int currentIndex;
  final List<_ShellDestination> destinations;
  final ValueChanged<int> onNavigate;
  final String accountLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xCC0A121C),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrandMark(size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bet Vision',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      'Workspace premium',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.20),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conta ativa',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  accountLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Navegação lateral limpa, sessões bem separadas e leitura rápida em telas amplas.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sessões',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white60,
                ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final item = destinations[index];
                final isSelected = index == currentIndex;
                return _DesktopNavTile(
                  destination: item,
                  selected: isSelected,
                  onTap: () => onNavigate(index),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopNavTile extends StatelessWidget {
  const _DesktopNavTile({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final highlight = Theme.of(context).colorScheme.primary;

    return Material(
      color: selected
          ? highlight.withValues(alpha: 0.16)
          : Colors.white.withValues(alpha: 0.02),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? highlight.withValues(alpha: 0.20)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  color: selected ? highlight : Colors.white70,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: selected ? Colors.white : Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabletNavigationRail extends StatelessWidget {
  const _TabletNavigationRail({
    required this.currentIndex,
    required this.destinations,
    required this.onNavigate,
  });

  final int currentIndex;
  final List<_ShellDestination> destinations;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xCC0A121C),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: NavigationRail(
        selectedIndex: currentIndex,
        onDestinationSelected: onNavigate,
        labelType: NavigationRailLabelType.all,
        leading: const Padding(
          padding: EdgeInsets.only(top: 12),
          child: BrandMark(size: 22),
        ),
        destinations: destinations
            .map(
              (item) => NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.label),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _WorkspaceTopBar extends StatelessWidget {
  const _WorkspaceTopBar({
    required this.destination,
    required this.compact,
    required this.accountLabel,
    required this.liveLabel,
  });

  final _ShellDestination destination;
  final bool compact;
  final String accountLabel;
  final String liveLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 18 : 22,
        vertical: compact ? 16 : 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xCC0A121C),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: compact ? 420 : 520,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  destination.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeaderChip(label: 'Conta', value: accountLabel),
              _HeaderChip(label: 'Fonte', value: liveLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _RightContextPanel extends StatelessWidget {
  const _RightContextPanel({
    required this.currentTitle,
    required this.favoriteCount,
    required this.matchCount,
    required this.demoMode,
    required this.settings,
  });

  final String currentTitle;
  final int favoriteCount;
  final int matchCount;
  final bool demoMode;
  final AnalysisSettings settings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ContextCard(
          title: 'Visão da sessão',
          subtitle: currentTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetricLine(label: 'Favoritos', value: '$favoriteCount'),
              const SizedBox(height: 10),
              _MetricLine(label: 'Jogos carregados', value: '$matchCount'),
              const SizedBox(height: 10),
              _MetricLine(
                label: 'Modo',
                value: demoMode ? 'Demo' : 'Conta',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ContextCard(
          title: 'Perfil do motor',
          subtitle: 'Pesos atuais organizados por seção',
          child: Column(
            children: [
              _MiniBar(label: 'Forma', value: settings.formWeight / 40),
              _MiniBar(label: 'Ataque/defesa', value: settings.attackDefenseWeight / 40),
              _MiniBar(label: 'Casa/Fora', value: settings.homeAwayWeight / 40),
              _MiniBar(label: 'Tabela', value: settings.tableWeight / 40),
              _MiniBar(label: 'H2H', value: settings.headToHeadWeight / 40),
              _MiniBar(label: 'Odds', value: settings.oddsValueWeight / 40),
              _MiniBar(label: 'Estabilidade', value: settings.stabilityWeight / 40),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ContextCard(
          title: 'Experiência visual',
          subtitle: 'Refatorado para um visual premium e menos poluído',
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BulletLine(text: 'Navegação lateral em telas amplas'),
              _BulletLine(text: 'Sessões bem separadas por contexto'),
              _BulletLine(text: 'Cards com mais respiro e leitura rápida'),
              _BulletLine(text: 'Melhor adaptação para celular, tablet e desktop'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xCC0A121C),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
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
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.label, required this.value});

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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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

class _BrandSquare extends StatelessWidget {
  const _BrandSquare();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15C26B), Color(0xFF6FE8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.auto_graph_rounded, color: Colors.black, size: 20),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111A26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white60,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _LoadingSplash extends StatelessWidget {
  const _LoadingSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            BrandMark(size: 28),
            SizedBox(height: 18),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}