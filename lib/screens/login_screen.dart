import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/brand_mark.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
    required this.onLoggedIn,
    required this.onContinueDemo,
  });

  final AuthService authService;
  final VoidCallback onLoggedIn;
  final VoidCallback onContinueDemo;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isRegisterMode) {
        await widget.authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await widget.authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      widget.onLoggedIn();
    } catch (_) {
      setState(() {
        _error =
            'Não foi possível acessar agora. Revise e-mail, senha e a configuração do Supabase.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.background, AppTheme.backgroundAlt],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -60,
              child: _GlowOrb(
                size: 260,
                color: AppTheme.primary.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              right: -90,
              bottom: -40,
              child: _GlowOrb(
                size: 220,
                color: AppTheme.secondary.withValues(alpha: 0.14),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 900;
                        return isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Expanded(flex: 12, child: _HeroPanel()),
                                  const SizedBox(width: 26),
                                  Expanded(
                                    flex: 8,
                                    child: _FormPanel(child: _buildForm(context)),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  const _HeroPanel(),
                                  const SizedBox(height: 20),
                                  _FormPanel(child: _buildForm(context)),
                                ],
                              );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.lock_open_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isRegisterMode ? 'Criar conta' : 'Entrar na BetVision',
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    'Acesse seu painel premium.',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          widget.authService.isConfigured
              ? 'Motivação te faz começar. Disciplina te faz continuar.'
              : 'Seu painel já está pronto para demo. Conecte o Supabase depois e continue usando a mesma base.',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'E-mail',
            hintText: 'seuemail@dominio.com',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Senha',
            hintText: 'Digite sua senha',
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.22)),
            ),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
        if (widget.authService.isConfigured) ...[
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: Icon(
                _isRegisterMode ? Icons.person_add_alt_1_rounded : Icons.login_rounded,
              ),
              label: Text(
                _isLoading
                    ? 'Carregando...'
                    : _isRegisterMode
                        ? 'Criar conta'
                        : 'Entrar',
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                _isRegisterMode = !_isRegisterMode;
              });
            },
            child: Text(
              _isRegisterMode
                  ? 'Já tem conta? Entrar'
                  : 'Ainda não tem conta? Criar conta',
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.22)),
            ),
            child: const Text(
              'Supabase ainda não configurado. O app continua funcionando em modo demo com favoritos e painel salvos localmente.',
            ),
          ),
          const SizedBox(height: 14),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onContinueDemo,
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('Explorar modo demo'),
          ),
        ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceAlt,
            AppTheme.panel,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrandMark(size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BetVision',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'Painel premium de partidas',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Leia o jogo antes do apito.',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Visual inspirado em app moderno, com leitura rápida, filtros objetivos e destaque para o que realmente merece sua atenção.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 26),
          const _HeroFeature(
            icon: Icons.grid_view_rounded,
            title: 'Visualização premium',
            description: 'Cards limpos, seções por campeonato e navegação pronta para celular e desktop.',
          ),
          const SizedBox(height: 12),
          const _HeroFeature(
            icon: Icons.auto_graph_rounded,
            title: 'Leitura objetiva',
            description: 'Probabilidade, confiança e resumo do cenário em poucos segundos.',
          ),
          const SizedBox(height: 12),
          const _HeroFeature(
            icon: Icons.cloud_done_rounded,
            title: 'Pronto para API e Supabase',
            description: 'Sua base já nasce preparada para login real e partidas puxadas da API.',
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _HeroMetric(label: 'Modo demo', value: 'Ativo'),
              _HeroMetric(label: 'Layout', value: 'Responsivo'),
              _HeroMetric(label: 'Deploy', value: 'Netlify'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroFeature extends StatelessWidget {
  const _HeroFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60)),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}
