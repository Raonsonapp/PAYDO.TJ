import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';

/// Handler-и background/terminated (banди 19: FCM). Бояд функсияи
/// top-level бошад (на метод дар класс) — талаботи худи package-и
/// firebase_messaging. Дар ин ҳолат мо ҳеҷ коре намекунем ба ғайр аз
/// иҷозат додан ба системаи OS системаи нишондиҳии notification-ро
/// худаш идора кунад (Firebase аллакай banner-и системавиро месозад
/// барои "notification"-и стандартӣ — коди иловагӣ дар ин ҷо лозим
/// нест, ба шарте ки backend/Cloud Function паёмро дар шакли
/// "notification payload" (на танҳо "data payload") фиристад).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Қасдан холӣ — ниг. эзоҳи боло.
}

/// PHASE 15: FCM — гирифтани иҷозат, синхронизатсияи token, коркарди
/// паёмҳо. Ин ҷо ҳаргиз бе ризояти корбар (иҷозати OS-и push) кор
/// намекунад — `requestPermission()` муколамаи стандартии системавиро
/// нишон медиҳад пеш аз гирифтани ягон паём.
class FcmService {
  final Ref _ref;
  bool _initialized = false;

  FcmService(this._ref);

  Future<void> initializeForCurrentUser() async {
    if (_initialized) return;
    _initialized = true;

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // Корбар иҷозат надод — PAYDO.TJ бе push кор мекунад (banди 19-и
      // notification-ҳо ихтиёрӣ мемонанд, на маҷбурӣ барои истифодаи app).
      return;
    }

    await _syncToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((_) => _syncToken());

    // Паёме, ки вақти барнома кушода аст (foreground) меояд — ин ҷо
    // мо системаи худии SnackBar/UI-и дигар истифода мебарем (на
    // package-и иловагии flutter_local_notifications, барои соддагӣ
    // дар MVP — ниг. docs/notifications.md барои сабаб).
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM foreground message: ${message.notification?.title}');
    });

    // Вақте корбар push-ро пахш карда, барномаро аз background кушод.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('FCM opened from background: ${message.notification?.title}');
    });
  }

  Future<void> _syncToken() async {
    final uid = _ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await _ref.read(profileRepositoryProvider).updateProfile(uid: uid, fcmToken: token);
  }
}

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService(ref));
