import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../models/notification_model.dart';
import '../domain/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(FirestorePaths.notifications);

  @override
  Stream<List<NotificationModel>> watchMyNotifications(String uid) {
    return _ref
        .where('recipientId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => NotificationModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<void> create(NotificationModel notification) async {
    try {
      await _ref.add(notification.toMap(isCreate: true));
    } catch (_) {
      // Хатогии сохтани notification набояд амали асосиро (масалан
      // checkout ё фиристодани хабар) вайрон кунад — silent-fail.
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _ref.doc(notificationId).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String uid) async {
    final snap = await _ref
        .where('recipientId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
