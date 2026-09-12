# CI/CD — Build ва Test худкор (GitHub Actions)

## Чаро GitHub Actions?

Дар муҳити ин чат (sandbox-и Claude) Flutter SDK ва интернет нест — бинобар
ин ман наметавонам дар ин ҷо `flutter build apk` ё `flutter test`-ро воқеан
иҷро кунам. **GitHub Actions** ин масъаларо ҳал мекунад: вақте шумо коди
лоиҳаро ба GitHub push мекунед, GitHub худаш серверҳое медиҳад, ки дар
онҳо Flutter SDK, Android SDK ва Xcode (барои iOS) аллакай насб ҳастанд —
он ҷо build/test воқеан иҷро мешавад, ба таври пурра худкор.

Ду workflow тайёр аст:

## 1. `ci.yml` — санҷиш дар ҳар push/PR

Файл: `.github/workflows/ci.yml`

Дар **ҳар push ё Pull Request** худкор иҷро мешавад:
1. `flutter pub get`
2. `flutter analyze --fatal-infos` — хатогиҳои коди Dart
3. `flutter test` — тамоми unit test-ҳои дар `test/`
4. Гузориши coverage ҳамчун artifact

Ин workflow ба Firebase config **ниёз надорад** (тестҳо танҳо моделҳои
Dart-ро санҷанд, на Firebase-и воқеиро) — бинобар ин пас аз якум push ба
GitHub бе ягон танзими иловагӣ кор мекунад.

**Натиҷаро дидан:** GitHub repo → таби **Actions** → "CI — Analyze & Test".

## 2. `build.yml` — сохтани APK/AAB/Web/iOS

Файл: `.github/workflows/build.yml`

Ин workflow **дастӣ** оғоз карда мешавад (Actions → "Build — Android / Web
/ iOS" → "Run workflow"), ё худкор ҳангоми push кардани tag-и `v*`
(масалан `git tag v0.1.0 && git push origin v0.1.0`).

### Пеш аз оғоз — 2 secret лозим аст (як бор)

1. **Лоиҳаи Firebase-и воқеӣ созед** (агар ҳанӯз накардаед) — ниг.
   `docs/firebase.md`.
2. Аз Firebase Console → Project Settings → Your apps → Android app,
   файли **`google-services.json`**-ро зеркашӣ кунед.
3. Онро ба base64 табдил диҳед:
   ```bash
   base64 -i google-services.json | tr -d '\n' > google-services.b64.txt
   ```
   (Windows/PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("google-services.json")) | Out-File google-services.b64.txt`)
4. GitHub repo → **Settings → Secrets and variables → Actions → New
   repository secret**:
   - Ном: `FIREBASE_GOOGLE_SERVICES_JSON`
   - Арзиш: мундариҷаи файли `.b64.txt` (як сатр)
5. (Агар iOS лозим бошад) ҳамин корро бо `GoogleService-Info.plist`
   такрор кунед, ном: `FIREBASE_IOS_PLIST`.

Бе ин secret, job-и Android дар қадами аввал бо паёми равшан **қасдан**
мебояд (на бо хатогии печидаи Gradle) — то шумо фавран донед чӣ лозим аст.

### Чӣ рӯй медиҳад дар ҳар job

| Job | Кор мекунад дар | Натиҷа |
|---|---|---|
| `build-android` | Ubuntu | `.apk` (насб бевосита) + `.aab` (барои Play Store) |
| `build-web` | Ubuntu | Папкаи `build/web` (барои Firebase Hosting/Vercel/ва ғ.) |
| `build-ios` | macOS | `.app` бе имзо (танҳо барои Simulator/санҷиши дохилӣ) |

Ҳар се job аввал сохтори native-и мутобиқро месозанд (`flutter create .
--platforms=...`) агар он ҳанӯз дар репо набошад — ин муваққатист; пас аз
якум build-и муваффақ, тавсия дода мешавад папкаҳои `android/`, `ios/`,
`web/`-ро аз artifact/local run **ба репо commit кунед**, то дигар CI
онҳоро аз нав насозад (боэътимодтар).

Ҳамчунин ҳар се job иконкаи барномаро аз `assets/icons/app_icon.png`
(лого-и PAYDO.TJ) худкор бо `flutter_launcher_icons` месозанд — шумо
дигар набояд иконкаро дасти иваз кунед.

### Гирифтани файли APK

Пас аз анҷоми workflow: Actions → run-и мутобиқ → қисми поёнии саҳифа
"Artifacts" → `paydo-tj-android-apk` → зеркашӣ → `app-release.apk`-ро дар
телефони Android насб кунед (шояд лозим шавад "Install from unknown
sources"-ро дар танзимоти телефон фаъол кунед, зеро ин на аз Play Store
аст).

## Маҳдудияти муҳим: iOS ва App Store

GitHub Actions метавонад iOS-ро **compile** кунад (`build-ios` job), вале
барои интишор дар **App Store** ё ҳатто насб дар телефони воқеӣ (на
Simulator), Apple талаб мекунад:
- Apple Developer Program ($99/сол)
- Сертификати имзо (signing certificate) ва provisioning profile
- Ин маълумот бояд ҳамчун secrets-и иловагӣ (масалан бо fastlane match)
  танзим шаванд — ин қадами дастӣ аст, ки танҳо соҳиби Apple Developer
  account метавонад анҷом диҳад.

Ин ҷо (build.yml) танҳо build-и **бе имзо**-ро медиҳад — барои тасдиқи он
ки коди iOS воқеан compile мешавад, на барои интишор.

## Хулоса: чӣ "худкор" аст ва чӣ на

✅ Худкор: analyze, unit test, build APK/AAB/Web/iOS-и бе имзо — ҳама дар
GitHub-и худи шумо, бе интернет/Flutter-и ман.

⚠️ Дастӣ (як бор): танзими 2 secret (google-services.json/plist), ва агар
хоҳед App Store — сертификати Apple.

❌ Ман (Claude, дар ин чат) ин файлҳоро санҷида/build карда наметавонам —
натиҷаи воқеӣ танҳо дар таби Actions-и GitHub-и шумо намоён мешавад.

## Firebase CLI (rules, indexes, functions)

`build.yml`/`ci.yml` танҳо **Flutter app**-ро (APK/Web/iOS) build
мекунанд — онҳо `firestore.rules`, `firestore.indexes.json` ё
`functions/`-ро деплой НАМЕКУНАНД. Ин корҳо бо Firebase CLI дар
маҳали худи шумо (ё workflow-и алоҳида, агар хоҳед):

```bash
firebase login
firebase use <проекти-firebase-и-шумо>
firebase deploy --only firestore:rules,firestore:indexes,storage
firebase deploy --only functions   # ихтиёрӣ — ниг. docs/notifications.md
```

## Хатоҳои маъмул ва ислоҳашон

### `flutter analyze` сурх мешавад бо садҳо "info" (require_trailing_commas)

Агар дар натиҷаи CI даҳҳо/садҳо паёми `info • Missing a required
trailing comma` бинед — ин **хатогии воқеӣ нест**, лоиҳа lint-и
услубии `require_trailing_commas` дорад (`analysis_options.yaml`).
Дуруст аст, ки CI дар ин ҳолат сабз бошад: `flutter analyze` (бе
`--fatal-infos`) пешфарз танҳо дар сатҳи "error" ноком мешавад. Агар
шумо худатон `--fatal-infos` илова кунед, CI бе сабаби воқеӣ сурх
мешавад — инро дар ин лоиҳа қасдан накардем (ниг. эзоҳ дар
`.github/workflows/ci.yml`).

### `warning • The asset directory 'assets/images/' doesn't exist`

`pubspec.yaml` папкаи `assets/images/`-ро эълон мекунад (барои
тасвирҳои ояндаи статикӣ), вале Git папкаи холиро track намекунад —
агар файл дар дохили он набошад, пас аз `git clone` папка вуҷуд
надорад ва `flutter analyze` шикоят мекунад. Файли
`assets/images/README.md` махсус барои ин гузошта шудааст (то Git
папкаро нигоҳ дорад).
