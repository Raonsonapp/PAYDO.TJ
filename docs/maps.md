# Maps — Харитаи Тоҷикистон (PHASE 13)

## Технология

- **MapLibre GL** (`maplibre_gl` package) — free/open-source, бе vendor lock-in (banди 2 ва 25 спецификатсия).
- **Style:** `https://demotiles.maplibre.org/style.json` — style-и ройгони расмии MapLibre (асоси OpenStreetMap), бе калиди API.

  ⚠️ **Муҳим барои production:** ин "demo style" барои санҷиш/MVP аст, на
  барои траффики баланд. Пеш аз PHASE 25 (Play Store), тавсия дода
  мешавад:
  - Ба [MapTiler](https://www.maptiler.com) (5000 boр/моҳ ройгон) ё
    [Stadia Maps](https://stadiamaps.com) гузаред, ё
  - Tile server-и худиро бо [OpenMapTiles](https://openmaptiles.org)
    роҳандозӣ кунед (пурра self-hosted, ройгон, вале серверти худ лозим).

  Style-и нав танҳо як тағйири constant аст: `_osmDemoStyleUrl` дар
  `lib/features/maps/presentation/map_screen.dart`.

## Маркерҳо (banди 17)

Харита маълумоти нав **ЗАХИРА НАМЕКУНАД** — маркерҳо бевосита аз
феҳаҳои аллакай мавҷуда хонда мешаванд:

| Маркер | Манбаъ | Феҳа |
|---|---|---|
| 🏪 Дӯконҳо | `businesses` | PHASE 5 |
| 🔧 Хизматрасонҳо | `services` | PHASE 10 |
| 💼 Вакансияҳо | `jobs` | PHASE 9 (пешфарз хомӯш — поён нигаред) |
| 🚚 Courier-ҳо | `couriers` (танҳо `status=available`) | PHASE 12 |

Ин комбинатсия дар `lib/features/maps/presentation/map_markers_provider.dart`
анҷом дода мешавад — 4 stream-и алоҳида ба ҳам якҷоя карда мешаванд бо як
helper-и хурди дастӣ (`_combineMarkerStreams`), то package-и иловагии
`rxdart` барои ҳамин як мавзеъ илова нашавад.

## Fallback-и координата (қарори муҳими тарроҳӣ)

Дар PHASE 5/10 (Business/Service Profile), майдони `location` (GeoPoint)
**ихтиёрӣ** аст — фармоне барои "нуқтаро дар харита нишон деҳ" ҳанӯз дар
UI-и он форма-ҳо нест (ин бахши ояндаи PHASE 13.x метавонад бошад, агар
лозим шавад: mini-map дар CreateEditBusinessScreen барои интихоби нуқта).

Барои ҳамин, агар `location` набошад, маркер дар **маркази шаҳр**и
дар профил зикршуда нишон дода мешавад (`TjCityCoordinates`, координатаи
тахминии 14 шаҳр). Дар bottom-sheet-и маркер, паёми равшан нишон дода
мешавад: "Ҷои дақиқ маълум нест — нуқта дар маркази шаҳр нишон дода
шудааст." Ин рафтори қасдист, на хатогӣ.

**Вакансия (💼)** асосан GeoPoint надорад (танҳо `city`) — бинобар ин
layer-и он пешфарз **хомӯш** аст дар харита (тавассути chip-и legend
фаъол карда мешавад), то накшаи маркерҳо аз пин-ҳои "ҳама дар як нуқта"
пур нашавад.

## UI

- `DropdownButton` барои ҷустуҷӯи шаҳр (banди 17: "User метавонад шаҳрро
  ҷустуҷӯ кунад") — интихоб камераро ба он шаҳр мебарад
  (`CameraUpdate.newLatLngZoom`).
- Legend/filter chips (поён) — фаъол/хомӯш кардани ҳар намуди маркер.
- Tap ба маркер → bottom sheet бо ном/тавсиф → тугмаи "Кушодан" мебарад
  ба профили дахлдор (`BusinessProfileScreen`/`ProviderProfileScreen`/
  `VacancyDetailsScreen`). Courier тугмаи "Кушодан" надорад (профили
  courier ҷамъиятӣ намоён нест).
- Attribution "© OpenStreetMap contributors" — шарти ҳатмии истифодаи
  tile-ҳои OSM.

## Насби native (Android/iOS)

`maplibre_gl` ба танзими иловагии native ниёз дорад (масалан
`minSdkVersion` ва баъзе permission-ҳо). Пас аз `flutter create .`
(ниг. `android/README.md`), санҷед:

- `android/app/build.gradle`: `minSdkVersion` ҳадди ақал 21 (аллакай
  дар README умумӣ зикр шудааст).
- Агар дар оянда `myLocationEnabled: true` фаъол шавад (PHASE 14 —
  Live Delivery Tracking), permission-ҳои
  `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` бояд ба
  `AndroidManifest.xml` ва iOS `Info.plist` илова шаванд.

## Санҷиши CI

`maplibre_gl` як native plugin аст — `flutter analyze`/`flutter test`
(ки дар `ci.yml` худкор иҷро мешавад) коди Dart-ро санҷанд, вале
рендери воқеии харита танҳо дар build-и воқеӣ (`build.yml` → APK) ё
`flutter run`-и шумо тафтиш мешавад. Ниг. `docs/ci_cd.md`.

## PHASE 14 — Live Delivery Tracking

`LiveTrackingScreen` (`lib/features/delivery/presentation/`) ҳамин
`MapLibreMap`-ро (ҳамон style, `osmDemoStyleUrl`) истифода мебарад,
вале бо 3 маркер: 🏪 Store (аз бизнеси seller-и таъинкунанда), 🚚
Courier (координатаи **зинда** аз `deliveries/{orderId}.courierLocation`
— навсозишаванда аз тарафи худи courier тавассути `geolocator`), 📍
Customer (аз рӯи шаҳри order).

**Масир:** хатти сода байни 3 нуқта (на роутинги воқеӣ бо кӯчаҳо) —
"advanced delivery routing" қасдан ба banди 36 (оянда) гузошта шудааст.

**Ризояти GPS (banди 18: "Do not collect location without user
permission"):** courier бояд тугмаи равшани "Фаъол кардани GPS"-ро дар
`ActiveDeliveryScreen` пахш кунад — на permission-и OS танҳо, балки
ризояти UX низ ошкоро аст. `distanceFilter: 25` (метр, на interval-и
вақт) истифода мешавад — навсозии Firestore танҳо вақте courier воқеан
25+ метр ҳаракат кунад, то cost-и free-tier (banди 25) кам шавад.

Санҷиш: android/ios permission-ҳо дар `android/README.md` тавзеҳ
дода шудаанд.
