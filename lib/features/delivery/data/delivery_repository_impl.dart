import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../models/courier_model.dart';
import '../../../models/delivery_model.dart';
import '../domain/delivery_repository.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  final FirebaseFirestore _firestore;

  DeliveryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _couriersRef =>
      _firestore.collection(FirestorePaths.couriers);

  CollectionReference<Map<String, dynamic>> get _deliveriesRef =>
      _firestore.collection(FirestorePaths.deliveries);

  @override
  Stream<CourierModel?> watchMyCourierProfile(String uid) {
    return _couriersRef.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return CourierModel.fromMap(snap.id, snap.data()!);
    });
  }

  @override
  Future<void> saveCourierProfile(CourierModel courier) async {
    final docRef = _couriersRef.doc(courier.uid);
    final existing = await docRef.get();
    try {
      await docRef.set(
        courier.toMap(isCreate: !existing.exists),
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии нигоҳдории профили курьер: ${e.message}');
    }
  }

  @override
  Future<void> setCourierStatus({required String uid, required CourierStatus status}) async {
    await _couriersRef.doc(uid).update({
      'status': status.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<CourierModel>> watchAvailableCouriers() {
    return _couriersRef
        .where('status', isEqualTo: CourierStatus.available.value)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CourierModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<String> assignCourier(DeliveryModel delivery) async {
    try {
      // docId детерминистӣ = orderId — як order танҳо як delivery
      // дошта метавонад (пешгирии таъини дучандӣ, ҳамон мантиқи
      // favorites/chats/job_applications).
      final docRef = _deliveriesRef.doc(delivery.orderId);
      await docRef.set(delivery.toMap(isCreate: true));
      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии таъини courier: ${e.message}');
    }
  }

  @override
  Stream<DeliveryModel?> watchDeliveryForOrder(String orderId) {
    return _deliveriesRef.doc(orderId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return DeliveryModel.fromMap(snap.id, snap.data()!);
    });
  }

  @override
  Stream<List<DeliveryModel>> watchMyDeliveries(String courierId) {
    return _deliveriesRef
        .where('courierId', isEqualTo: courierId)
        .orderBy('assignedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => DeliveryModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<void> updateDeliveryStatus({
    required String deliveryId,
    required DeliveryStatus status,
  }) async {
    await _deliveriesRef.doc(deliveryId).update({
      'status': status.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateCourierLiveLocation({
    required String deliveryId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _deliveriesRef.doc(deliveryId).update({
        'courierLocation': GeoPoint(latitude, longitude),
        'courierLocationUpdatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      // Хатогии як навсозии GPS критикӣ нест (навсозии навбатӣ пас аз
      // якчанд сония меояд) — silent-fail, то stream-и tracking канда
      // нашавад.
    }
  }
}
