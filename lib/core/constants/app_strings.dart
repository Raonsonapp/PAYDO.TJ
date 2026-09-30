/// Тамоми матнҳои статикии барнома (забони асосӣ: Тоҷикӣ).
/// PHASE 0: танҳо матнҳое, ки барои Phase 1 (Auth) лозиманд.
/// Дар марҳилаҳои баъдӣ ин файл васеъ карда мешавад ва баъдтар
/// ба системаи l10n (ru/en) кӯчонида мешавад (ниг. docs/roadmap.md).
class AppStrings {
  AppStrings._();

  static const appName = 'PAYDO.TJ';
  static const appTagline = 'Ҳама чиз дар як барнома';

  // Auth
  static const continueWithGoogle = 'Идома бо Google';
  static const signingIn = 'Даровардан...';
  static const signOut = 'Баромадан';
  static const authErrorGeneric = 'Хатогӣ рух дод. Лутфан аз нав кӯшиш кунед.';
  static const authErrorNoInternet = 'Интернет пайваст нест.';
  static const authErrorCancelled = 'Даровардан бекор карда шуд.';

  // Common
  static const loading = 'Боркунӣ...';
  static const retry = 'Аз нав кӯшиш кардан';
  static const noInternet = 'Интернет пайваст нест';
  static const somethingWentWrong = 'Хатогӣ рух дод';
  static const empty = 'Ҳеҷ чиз ёфт нашуд';
  static const save = 'Нигоҳ доштан';
  static const cancel = 'Бекор кардан';
  static const edit = 'Тағйир додан';
  static const delete = 'Нест кардан';
  static const confirm = 'Тасдиқ';

  // Bottom navigation (Phase 3+ истифода мешавад)
  static const navHome = 'Асосӣ';
  static const navSearch = 'Ҷустуҷӯ';
  static const navAdd = 'Илова';
  static const navMap = 'Харита';
  static const navProfile = 'Профил';

  // Advertising / Premium (Phase 18 MVP)
  static const advertisingTitle = 'Реклама ва Premium';
  static const advertisingSubtitle = 'Эълонатонро пешбарӣ кунед';
  static const advertisingMyAds = 'Эълонҳои ман';
  static const advertisingBoost = 'Пешбарӣ';
  static const advertisingPremium = 'PAYDO Premium';
  static const advertisingBackendPending = 'Пардохт ва сервер баъдтар пайваст мешавад.';
}
