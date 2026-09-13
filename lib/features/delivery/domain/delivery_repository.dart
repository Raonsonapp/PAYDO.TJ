import '../../../models/courier_model.dart';
import '../../../models/delivery_model.dart';

abstract class DeliveryRepository {
  // ---- Courier profile ----
  Stream<CourierModel?> watchMyCourierProfile(String uid);
  Future<void> saveCourierProfile(CourierModel courier);
  Future<void> setCourierStatus({required String uid, required CourierStatus status});

  /// Courier-ҳои "available" — барои Business ҳангоми таъин кардан.
  Stream<List<CourierModel>> watchAvailableCouriers();

  // ---- Deliveries ----
  Future<String> assignCourier(DeliveryModel delivery);
  Stream<DeliveryModel?> watchDeliveryForOrder(String orderId);
  Stream<List<DeliveryModel>> watchMyDeliveries(String courierId);
  Future<void> updateDeliveryStatus({
    required String deliveryId,
    required DeliveryStatus status,
  });

  /// PHASE 14: Live Delivery Tracking. Танҳо вақте courier худаш GPS-ро
  /// фаъол кардааст (ниг. эзоҳи `DeliveryModel.courierLocation`).
  Future<void> updateCourierLiveLocation({
    required String deliveryId,
    required double latitude,
    required double longitude,
  });
}
