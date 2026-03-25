#!/usr/bin/env bash
set -e

echo 'Gerando pastas nativas Android e Web...'
flutter create . --platforms=android,web

echo 'Baixando dependências...'
flutter pub get

echo 'Pronto. Agora você pode rodar:'
echo 'flutter run -d chrome'
echo 'ou'
echo 'flutter run -d android'
