# BetVision personalizado

Projeto ajustado com visual premium inspirado no modelo que você gostou.

## O que já veio pronto
- nome BetVision
- tela de login mais premium
- dashboard no estilo cards modernos
- visualização em seções por campeonato
- frase principal: "Motivação te faz começar. Disciplina te faz continuar."
- base pronta para API de futebol e Supabase
- responsivo para celular, tablet e desktop

## Onde colocar seus dados
### Supabase
Arquivo:
`lib/core/config/env_config.dart`

Preencha:
- `COLE_AQUI_SUA_SUPABASE_URL`
- `COLE_AQUI_SUA_SUPABASE_ANON_KEY`

### API de futebol no Netlify
No painel do Netlify, adicione uma variável de ambiente:
- `API_FOOTBALL_KEY`

ou
- `FOOTBALL_API_KEY`

A função serverless fica em:
`netlify/functions/matches.js`

## Fluxo ideal
1. testar localmente
2. subir no GitHub
3. conectar no Netlify
4. adicionar variável da API no Netlify
5. publicar

## Observação
Eu mantive a estrutura do projeto compatível com a sua base anterior para facilitar seus próximos ajustes.
