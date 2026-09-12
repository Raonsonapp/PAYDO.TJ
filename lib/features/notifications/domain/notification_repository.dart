import '../../../models/notification_model.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> watchMyNotifications(String uid);

  Future<void> create(NotificationModel notification);

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String uid);
}
