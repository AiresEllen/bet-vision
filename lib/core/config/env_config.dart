class EnvConfig {
  // Cole aqui os seus dados reais antes de publicar.
  // Supabase: settings > API
  // Football API: sua chave da API-Football

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'COLE_AQUI_SUA_SUPABASE_URL',
  );

  static const String supabaseKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: 'COLE_AQUI_SUA_SUPABASE_ANON_KEY',
  );

  static const String footballApiKey = String.fromEnvironment(
    'FOOTBALL_API_KEY',
    defaultValue: '',
  );

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty &&
      supabaseKey.isNotEmpty &&
      supabaseUrl.startsWith('https://') &&
      !supabaseUrl.contains('COLE_AQUI') &&
      !supabaseKey.contains('COLE_AQUI');

  static bool get hasFootballApi => footballApiKey.isNotEmpty;
}
