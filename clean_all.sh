#!/bin/bash

echo "🧹 Tüm cache temizleniyor..."

# Flutter cache
rm -rf pubspec.lock
rm -rf .dart_tool
rm -rf build
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# Android cache
rm -rf android/.gradle
rm -rf android/app/build
rm -rf android/build
rm -rf android/.idea
rm -rf android/local.properties

# Gradle cache
rm -rf ~/.gradle/caches

# Pub cache temizle (telephony'yi tam sil)
flutter pub cache repair

echo "✅ Temizlik tamamlandı!"
