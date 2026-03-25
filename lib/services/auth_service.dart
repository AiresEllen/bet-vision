import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/env_config.dart';

class AuthService {
  AuthService()
      : _client = EnvConfig.hasSupabase
            ? SupabaseClient(
                EnvConfig.supabaseUrl,
                EnvConfig.supabaseKey,
              )
            : null;

  final SupabaseClient? _client;

  bool get isConfigured => _client != null;

  Session? get currentSession => _client?.auth.currentSession;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase nao configurado.');
    }

    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null) {
      throw Exception('Nao foi possivel iniciar a sessao.');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase nao configurado.');
    }

    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Nao foi possivel criar a conta.');
    }
  }

  Future<void> signOut() async {
    final client = _client;
    if (client == null) return;

    await client.auth.signOut();
  }
}
