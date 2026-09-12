# PAYDO.TJ

**"Ҳама чиз дар як барнома"**

Super App / marketplace-и бисёрфунксионалӣ барои Тоҷикистон: онлайн-магазин, корёбӣ, хизматрасонӣ, дафтари ҳисобу китоб, доставка, харита, чат ва зиёда аз ин — ҳама дар як APK.

## Ҳолати ҳозираи лоиҳа

| Phase | Ном | Ҳолат |
|---|---|---|
| 0 | Project Architecture | ✅ Анҷом ёфт |
| 1 | Registration / Google Auth | ✅ Анҷом ёфт |
| 2 | User Profile | ✅ Анҷом ёфт |
| 3 | Home Page | ✅ Анҷом ёфт |
| 4 | Marketplace | ✅ Анҷом ёфт |
| 5 | Business Profile | ✅ Анҷом ёфт |
| 6 | Product Management | ✅ Анҷом ёфт |
| 7 | Cart and Orders | ✅ Анҷом ёфт |
| 8 | Chat | ✅ Анҷом ёфт |
| 9 | Jobs / Employment | ✅ Анҷом ёфт |
| 10 | Services | ✅ Анҷом ёфт |
| 11 | Accounting / Дафтари ҳисоб | ✅ Анҷом ёфт |
| 12 | Delivery | ✅ Анҷом ёфт |
| 13 | Map of Tajikistan | ✅ Анҷом ёфт |
| 14 | Live Delivery Tracking | ✅ Анҷом ёфт |
| 15 | Notifications | ✅ Анҷом ёфт |
| 16–25 | ... | ⏳ Дар навбат |

Ниг. [`docs/roadmap.md`](docs/roadmap.md) барои феҳристи пурраи марҳилаҳо.

## Технология

- **Frontend:** Flutter (Dart, null-safe)
- **State management:** Riverpod (стандарти интихобшудаи проект — дар ҳама феча истифода мешавад)
- **Routing:** go_router
- **Backend:** Firebase (Authentication, Cloud Firestore, Storage, Cloud Messaging)
- **Login:** Google Sign-In
- **Maps:** MapLibre + OpenStreetMap (PHASE 13+)
- **Architecture:** Clean Architecture + feature-based modular structure

## Сохтори лоиҳа

```
lib/
  core/          # theme, constants, errors, network, виҷетҳои умумӣ
  features/      # ҳар феча = data / domain / presentation
    auth/        # PHASE 1 — тайёр
    profile/     # PHASE 2
    home/        # PHASE 3 (placeholder ҳоло)
    marketplace/ ...
  models/        # моделҳои муштарак (UserModel, ...)
  routing/       # go_router (як ҷои марказӣ барои ҳама roҳҳо)
  main.dart
```

Ниг. [`docs/architecture.md`](docs/architecture.md) барои тавзеҳи муфассал.

## CI/CD — Build ва Test худкор

Лоиҳа акнун **GitHub Actions** дорад:

- `.github/workflows/ci.yml` — дар ҳар push/PR: `flutter analyze` + `flutter test` (бе ниёз ба танзими иловагӣ)
- `.github/workflows/build.yml` — сохтани **APK**, **AAB** (Play Store), **Web**, ва **iOS** (бе имзо), дастӣ ё бо tag-и `v*`

Иконкаи барнома (APK/iOS/Web) аз `assets/icons/app_icon.png` (лого-и PAYDO.TJ) худкор бо `flutter_launcher_icons` сохта мешавад.

**Қадами якум пеш аз build:** 2 GitHub Secret (Firebase config) танзим кунед — дастури пурра дар [`docs/ci_cd.md`](docs/ci_cd.md).

**PHASE 15 (Notifications):** барои push-и воқеӣ (на танҳо in-app), Cloud Function-и `functions/` бояд деплой шавад — ихтиёрӣ, дастур дар [`docs/notifications.md`](docs/notifications.md).

## Роҳандозии лоиҳа дар маҳали худ

Пеш аз оғоз шумо бояд дошта бошед:

1. **Flutter SDK** (>=3.3.0) — [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2. **Firebase CLI** ва **FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. Лоиҳаи Firebase (Console: console.firebase.google.com) бо фаъол:
   - Authentication → Google provider
   - Cloud Firestore (production mode)
   - Cloud Storage
   - Cloud Messaging

### Қадамҳо

```bash
# 1. Package-ҳоро насб кунед
flutter pub get

# 2. Firebase-ро ба лоиҳа пайваст кунед (файли firebase_options.dart сохта мешавад)
flutterfire configure

# 3. Санҷиш
flutter analyze
flutter test

# 4. Иҷро кардан (Android)
flutter run
```

### Пайваст кардани Google Sign-In (Android)

Пас аз `flutterfire configure`, боз лозим аст:

1. `android/app/google-services.json` — аз Firebase Console зеркашӣ кунед.
2. SHA-1 ва SHA-256 fingerprint-и debug/release keystore-ро ба Firebase Console (Project Settings → Your apps) илова кунед:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
3. Дар `android/app/build.gradle` плагини Google Services фаъол бошад (FlutterFire CLI ин корро худкор мекунад).

### Насб кардани Security Rules (Firestore ва Storage)

```bash
firebase deploy --only firestore:rules,storage
```

## Муҳими корӣ

- Ин лоиҳа дар ин муҳити разговор (sandbox) **бе Flutter SDK ва бе интернет** сохта шудааст — коди Dart дар ин ҷо навишта шуда, вале **compile нашудааст**. Ду роҳ барои санҷиш:
  1. **Маҳали худ:** `flutter pub get` → `flutter analyze` → `flutter test` → `flutter run`.
  2. **GitHub Actions (тавсия дода мешавад):** push кунед ба GitHub — `ci.yml` худкор analyze/test мекунад, `build.yml` бошад APK/AAB/Web/iOS месозад (пас аз танзими 2 secret). Ниг. [`docs/ci_cd.md`](docs/ci_cd.md).
- Ҳар марҳила (PHASE) бояд пеш аз гузаштан ба навбатӣ бо `flutter analyze`/`flutter test` тасдиқ карда шавад (ниг. `docs/roadmap.md`).
