# Alterações realizadas no projeto

## Correções de bugs (v2 — versão corrigida)

### Bug crítico: `_formScore()` com cálculo errado
- A função retornava um valor entre 0–1, mas era multiplicado por 50 como se fosse 0–100.
- Resultado: todos os scores de "Forma" estavam errados no motor de análise.
- **Corrigido:** agora retorna corretamente 0–100.

### Bug crítico: `_logout()` no DashboardScreen quebrado
- O botão de sair chamava `Navigator.popUntil()`, mas a tela não é gerenciada via Navigator.
- Resultado: clicar em "Sair" não fazia nada — o usuário ficava preso.
- **Corrigido:** agora chama `widget.onLogout()` que propaga o logout para o `app.dart`.

### Bug: `onLogout` não era passado ao DashboardScreen
- O `app.dart` não repassava o callback `onLogout` para `DashboardScreen`.
- **Corrigido:** parâmetro adicionado e conectado corretamente.

### Bug: sem fallback para dados mock
- Quando a API falhava (chave não configurada), o app exibia erro e tela vazia.
- **Corrigido:** `FootballApiService` agora usa `MockDataService` automaticamente como fallback.

### Melhoria: requisições da API com timeout
- Requests sem timeout podiam travar a UI indefinidamente.
- **Corrigido:** timeout de 10 segundos adicionado por requisição; datas sem resposta são puladas.

### Aviso: 60 usos de `.withOpacity()` depreciado
- Flutter 3.x marcou `withOpacity()` como depreciado.
- **Corrigido:** todos substituídos por `.withValues(alpha: ...)`.

### Melhoria: `EnvConfig` com suporte a `--dart-define`
- As chaves agora podem ser injetadas em tempo de build com:
  ```
  flutter build web --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_KEY=... --dart-define=FOOTBALL_API_KEY=...
  ```

## Melhorias anteriores (v1)
- Visual geral mais profissional
- Tela de login refeita
- Dashboard com métricas e filtros
- Favoritos realmente úteis
- Painel de estratégia com presets
- Persistência local de favoritos e painel
- Perfil com status do ambiente
- Pasta `web/` pronta para build Flutter web

## Como usar
1. Extraia o ZIP.
2. Abra a pasta no terminal.
3. Rode `flutter pub get` para instalar dependências.
4. Para testar localmente com dados mock: `flutter run -d chrome`
5. Para build web com chaves reais:
   ```
   flutter build web \
     --dart-define=FOOTBALL_API_KEY=sua_chave_aqui \
     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
     --dart-define=SUPABASE_KEY=sua_chave_supabase
   ```
6. Envie a pasta `build/web` para o Netlify.
