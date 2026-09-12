import 'package:cloud_firestore/cloud_firestore.dart';

/// Намуди notification (banди 19, айнан аз рӯи рӯйхати спецификатсия).
enum NotificationType {
  newOrder,
  orderStatusChanged,
  newMessage,
  courierAssigned,
  deliveryStarted,
  deliveryArrived,
  jobApplication,
  newVacancy,
  review,
  system,
}

extension NotificationTypeX on NotificationType {
  String get value => name;
  static NotificationType fromString(String value) =>
      NotificationType.values.firstWhere((e) => e.value == value,
          orElse: () => NotificationType.system);

  /// Icon барои намоиш дар NotificationsScreen (Material icon name —
  /// худи IconData дар презентатсия сохта мешавад, ин ҷо танҳо калид).
  String get iconKey {
    switch (this) {
      case NotificationType.newOrder:
        return 'receipt_long';
      case NotificationType.orderStatusChanged:
        return 'local_shipping';
      case NotificationType.newMessage:
        return 'chat_bubble';
      case NotificationType.courierAssigned:
        return 'delivery_dining';
      case NotificationType.deliveryStarted:
        return 'directions_run';
      case NotificationType.deliveryArrived:
        return 'check_circle';
      case NotificationType.jobApplication:
        return 'work';
      case NotificationType.newVacancy:
        return 'work_outline';
      case NotificationType.review:
        return 'star';
      case NotificationType.system:
        return 'info';
    }
  }
}

/// Notification (banди 19 ва 27: `notifications`).
///
/// Қарори тарроҳӣ: ин ҷо ҳамеша дар Firestore СОХТА МЕШАВАД (аз
/// тарафи client, ҳангоми амали дахлдор — масалан checkout, chat
/// message) — ин "in-app notification center"-ро таъмин мекунад
/// (real-time, кор мекунад бе ягон танзими иловагӣ). Push-и воқеии
/// FCM (ки корбарро вақте барнома пӯшида аст огоҳ мекунад) ба
/// Cloud Function ниёз дорад, ки ба сохтани ин документ гӯш медиҳад
/// ва ба `recipientFcmToken` мефиристад — ниг. `functions/index.js`
/// ва тавзеҳи пурра дар `docs/notifications.md`.
class NotificationModel {
  final String id;
  final String recipientId;
  final NotificationType type;
  final String title;
  final String body;
  final String? contextType; // 'order' | 'chat' | 'job' | 'delivery' | ...
  final String? contextId;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    this.contextType,
    this.contextId,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      recipientId: map['recipientId'] as String? ?? '',
      type: NotificationTypeX.fromString(map['type'] as String? ?? 'system'),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      contextType: map['contextType'] as String?,
      contextId: map['contextId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'recipientId': recipientId,
      'type': type.value,
      'title': title,
      'body': body,
      'contextType': contextType,
      'contextId': contextId,
      'isRead': isRead,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
