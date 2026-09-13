import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../models/courier_model.dart';
import '../../../models/delivery_model.dart';
import '../../../models/notification_model.dart';
import '../../../models/order_model.dart';
import '../data/delivery_repository_impl.dart';
import '../domain/delivery_repository.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../business/presentation/business_providers.dart';
import '../../notifications/presentation/notification_providers.dart';
import '../../orders/presentation/order_providers.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepositoryImpl();
});

final myCourierProfileProvider = StreamProvider<CourierModel?>((ref) {
  final repo = ref.watch(deliveryRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(null);
  return repo.watchMyCourierProfile(uid);
});

final availableCouriersProvider = StreamProvider<List<CourierModel>>((ref) {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.watchAvailableCouriers();
});

final deliveryForOrderProvider =
    StreamProvider.family<DeliveryModel?, String>((ref, orderId) {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.watchDeliveryForOrder(orderId);
});

final myDeliveriesProvider = StreamProvider<List<DeliveryModel>>((ref) {
  final repo = ref.watch(deliveryRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return repo.watchMyDeliveries(uid);
});

class DeliveryActionState {
  final bool isSaving;
  const DeliveryActionState({this.isSaving = false});
  DeliveryActionState copyWith({bool? isSaving}) =>
      DeliveryActionState(isSaving: isSaving ?? this.isSaving);
}

/// Composition-и байни Delivery ва Orders (PHASE 7) — ба ҷои он ки
/// OrderRepository/DeliveryRepository якдигарро бевосита донанд
/// (coupling дар сатҳи data layer), координатсия дар сатҳи
/// presentation controller анҷом дода мешавад.
class DeliveryActionController extends StateNotifier<DeliveryActionState> {
  final DeliveryRepository _deliveryRepository;
  final Ref _ref;

  DeliveryActionController(this._deliveryRepository, this._ref)
      : super(const DeliveryActionState());

  Future<bool> saveCourierProfile(CourierModel courier) async {
    state = state.copyWith(isSaving: true);
    try {
      await _deliveryRepository.saveCourierProfile(courier);
      return true;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<void> setMyStatus(String uid, CourierStatus status) =>
      _deliveryRepository.setCourierStatus(uid: uid, status: status);

  /// Business/seller курьерро таъин мекунад: DeliveryModel сохта
  /// мешавад, courier → busy, order → shipped.
  Future<bool> assignCourier({
    required OrderModel order,
    required CourierModel courier,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      // Нуқтаи гирифтани бор (banди 18: "🏪 Store") — аз бизнеси
      // корбари ҳозира (seller-и таъинкунанда), агар дошта бошад.
      final sellerUid = _ref.read(authStateProvider).value?.uid;
      final sellerBusiness = sellerUid != null
          ? await _ref.read(businessRepositoryProvider).getBusinessByOwner(sellerUid)
          : null;

      final delivery = DeliveryModel(
        id: '',
        orderId: order.id,
        courierId: courier.uid,
        courierName: courier.name,
        customerId: order.customerId,
        customerName: order.customerName,
        customerAddress: order.customerAddress ?? '',
        customerCity: order.customerCity,
        pickupCity: sellerBusiness?.city ?? order.customerCity,
        pickupLocation: sellerBusiness?.location,
      );
      await _deliveryRepository.assignCourier(delivery);
      await _deliveryRepository.setCourierStatus(
          uid: courier.uid, status: CourierStatus.busy);
      await _ref.read(orderStatusUpdateProvider)(order.id, OrderStatus.shipped);

      await _ref.read(createNotificationProvider)(
        recipientId: order.customerId,
        type: NotificationType.courierAssigned,
        title: 'Courier таъин шуд',
        body: '${courier.name} фармоиши шуморо мерасонад.',
        contextType: 'order',
        contextId: order.id,
      );

      return true;
    } catch (e) {
      return false;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  /// Courier ҳолати доставкаро пеш мебарад; вақте "delivered" шавад,
  /// order → completed ва courier → available худкор мешаванд.
  Future<void> advanceDeliveryStatus({
    required DeliveryModel delivery,
    required String courierId,
  }) async {
    final next = delivery.status.next;
    if (next == null) return;

    await _deliveryRepository.updateDeliveryStatus(deliveryId: delivery.id, status: next);

    if (next == DeliveryStatus.delivered) {
      await _ref.read(orderStatusUpdateProvider)(delivery.orderId, OrderStatus.completed);
      await _deliveryRepository.setCourierStatus(uid: courierId, status: CourierStatus.available);
      await _ref.read(createNotificationProvider)(
        recipientId: delivery.customerId,
        type: NotificationType.deliveryArrived,
        title: 'Фармоиш расонида шуд',
        body: '${delivery.courierName} фармоиши шуморо расонид.',
        contextType: 'order',
        contextId: delivery.orderId,
      );
    } else if (next == DeliveryStatus.onTheWay) {
      await _ref.read(orderStatusUpdateProvider)(delivery.orderId, OrderStatus.delivering);
      await _ref.read(createNotificationProvider)(
        recipientId: delivery.customerId,
        type: NotificationType.deliveryStarted,
        title: 'Доставка дар роҳ аст',
        body: '${delivery.courierName} ба сӯи шумо равона шуд.',
        contextType: 'order',
        contextId: delivery.orderId,
      );
    }
  }
}

final deliveryActionControllerProvider =
    StateNotifierProvider<DeliveryActionController, DeliveryActionState>((ref) {
  final repo = ref.watch(deliveryRepositoryProvider);
  return DeliveryActionController(repo, ref);
});

/// Натиҷаи санҷиши иҷозати GPS (banди 18: "Do not collect location
/// without user permission").
enum LocationPermissionResult { granted, denied, deniedForever, serviceDisabled }

/// PHASE 14: идоракунии GPS-и courier дар вақти воқеӣ.
///
/// Қарори тарроҳӣ: tracking ҲАРГИЗ худкор оғоз намешавад — корбар
/// (courier) бояд бо тугмаи равшан "Фаъол кардани GPS" ризоят диҳад
/// (ҳам дар сатҳи OS-permission, ҳам дар сатҳи UX-и худи барнома).
/// `distanceFilter` (на interval-и вақт) истифода мешавад, то навсозии
/// Firestore танҳо вақте courier воқеан ҳаракат кунад сурат гирад —
/// арзонтар барои free-tier (banди 25), ва батареяи камтар сарф мекунад.
class LocationTrackingController extends StateNotifier<bool> {
  final DeliveryRepository _repository;
  StreamSubscription<Position>? _positionSub;
  String? _activeDeliveryId;

  LocationTrackingController(this._repository) : super(false);

  bool get isTracking => state;

  Future<LocationPermissionResult> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionResult.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionResult.deniedForever;
    }
    if (permission == LocationPermission.denied) {
      return LocationPermissionResult.denied;
    }
    return LocationPermissionResult.granted;
  }

  /// Оғози tracking барои як delivery мушаххас. Бармегардонад
  /// натиҷаи иҷозат — UI паёми дахлдорро (масалан "ба танзимот равед")
  /// нишон медиҳад агар granted набошад.
  Future<LocationPermissionResult> startTracking(String deliveryId) async {
    final permission = await _ensurePermission();
    if (permission != LocationPermissionResult.granted) return permission;

    await stopTracking();
    _activeDeliveryId = deliveryId;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 25, // метр — навсозӣ танҳо баъд аз ин масофаи ҳаракат
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (position) {
        if (_activeDeliveryId != null) {
          _repository.updateCourierLiveLocation(
            deliveryId: _activeDeliveryId!,
            latitude: position.latitude,
            longitude: position.longitude,
          );
        }
      },
    );

    state = true;
    return LocationPermissionResult.granted;
  }

  Future<void> stopTracking() async {
    await _positionSub?.cancel();
    _positionSub = null;
    _activeDeliveryId = null;
    state = false;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}

final locationTrackingControllerProvider =
    StateNotifierProvider<LocationTrackingController, bool>((ref) {
  final repo = ref.watch(deliveryRepositoryProvider);
  final controller = LocationTrackingController(repo);
  ref.onDispose(() => controller.stopTracking());
  return controller;
});
