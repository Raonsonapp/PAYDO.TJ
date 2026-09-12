import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/notification_model.dart';
import '../data/notification_repository_impl.dart';
import '../domain/notification_repository.dart';
import '../../auth/presentation/auth_providers.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});

final myNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return repo.watchMyNotifications(uid);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(myNotificationsProvider).valueOrNull ?? const [];
  return notifications.where((n) => !n.isRead).length;
});

/// Функсияи ёридиҳанда — истифода аз феҳаҳои дигар (orders/chat/jobs/
/// delivery) барои сохтани notification бе такрори boilerplate.
/// Ниг. эзоҳи тарроҳӣ дар lib/models/notification_model.dart.
final createNotificationProvider = Provider<
    Future<void> Function({
      required String recipientId,
      required NotificationType type,
      required String title,
      required String body,
      String? contextType,
      String? contextId,
    })>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return ({
    required recipientId,
    required type,
    required title,
    required body,
    contextType,
    contextId,
  }) {
    return repo.create(NotificationModel(
      id: '',
      recipientId: recipientId,
      type: type,
      title: title,
      body: body,
      contextType: contextType,
      contextId: contextId,
    ));
  };
});
