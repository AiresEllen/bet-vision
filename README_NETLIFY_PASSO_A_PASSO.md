# Bet Vision - publicação simples

## O que já está pronto
- login real com Supabase
- modo demo como fallback
- build para Netlify
- favoritos e preferências salvos no navegador

## Publicar rápido
1. Descompacte a pasta do projeto.
2. Rode `build_web_demo.bat` para testar sem API de futebol.
3. Ou rode `build_web_com_chaves.bat` se quiser usar a API de futebol.
4. Depois envie a pasta `build/web` para o Netlify.

## Observações
- O Supabase já está configurado no código com a URL e a chave pública do projeto.
- A chave da API-Football não fica fixa no código por segurança.
- Para usar partidas reais, preencha `FOOTBALL_API_KEY` no `build_web_com_chaves.bat`.
