# Kübaj Android

Kübaj iOS uygulamasının Kotlin ve Jetpack Compose ile geliştirilen Android sürümüdür.

## Gereksinimler

- Android Studio Meerkat veya daha yeni
- JDK 17
- Android SDK 36
- Minimum Android 8.0 (API 26)

## Teknoloji

- Kotlin
- Jetpack Compose ve Material 3
- Room
- Preferences DataStore
- StateFlow tabanlı MVVM
- Android PdfDocument
- OOXML tabanlı gerçek XLSX üretimi

## Çalıştırma

Android Studio ile `android` klasörünü açın veya:

```bash
./gradlew :app:assembleDebug
```

APK:

```text
app/build/outputs/apk/debug/app-debug.apk
```

## Doğrulama

```bash
./gradlew :app:testDebugUnitTest :app:lintDebug :app:assembleDebug
```
