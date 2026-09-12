import 'package:cloud_firestore/cloud_firestore.dart';

/// Ҳолати "Order delivery" (banди 16, айнан бо ҳамин 4 ном).
/// Диққат: ин БО `OrderStatus`-и marketplace (PHASE 7) як чиз нест —
/// `DeliveryStatus` танҳо марҳилаи ба courier вобастаро тасвир мекунад
/// (баъд аз он ки order аллакай "ready" аст), дар ҳоле ки `OrderStatus`
/// тамоми pipeline-и тиҷоратиро (pending→...→completed) дар бар мегирад.
/// Ниг. тавзеҳи муфассал дар docs/architecture.md.
enum DeliveryStatus { assigned, pickedUp, onTheWay, delivered }

extension DeliveryStatusX on DeliveryStatus {
  String get value => name;
  static DeliveryStatus fromString(String value) =>
      DeliveryStatus.values.firstWhere((e) => e.value == value,
          orElse: () => DeliveryStatus.assigned);

  String get label {
    switch (this) {
      case DeliveryStatus.assigned:
        return 'Таъин шуд';
      case DeliveryStatus.pickedUp:
        return 'Гирифта шуд';
      case DeliveryStatus.onTheWay:
        return 'Дар роҳ';
      case DeliveryStatus.delivered:
        return 'Расонида шуд';
    }
  }

  DeliveryStatus? get next {
    switch (this) {
      case DeliveryStatus.assigned:
        return DeliveryStatus.pickedUp;
      case DeliveryStatus.pickedUp:
        return DeliveryStatus.onTheWay;
      case DeliveryStatus.onTheWay:
        return DeliveryStatus.delivered;
      case DeliveryStatus.delivered:
        return null;
    }
  }
}

/// Иҷрои доставка барои як order (banди 16 ва 27: `deliveries`).
class DeliveryModel {
  final String id;
  final String orderId;
  final String courierId;
  final String courierName;
  final String customerId;
  final String customerName;
  final String customerAddress;
  final String customerCity;

  /// Нуқтаи гирифтани бор (banди 18: "🏪 Store" дар диаграмма). Аз
  /// профили бизнеси seller-и таъинкунанда гирифта мешавад (агар
  /// бошад); fallback ба `customerCity` агар seller бизнес надошта
  /// бошад (ниг. `DeliveryActionController.assignCourier`).
  final String pickupCity;
  final GeoPoint? pickupLocation;

  final DeliveryStatus status;

  /// Ҷои зиндаи courier (banди 18: Live Delivery Tracking). Танҳо
  /// вақте courier худаш GPS-ро фаъол мекунад (тугмаи равшан дар UI —
  /// "бе иҷозат маълумоти ҷой ҷамъ намекунем", ниг. banди 18) навсозӣ
  /// мешавад. null маънои онро дорад, ки courier ҳанӯз tracking-ро
  /// фаъол накардааст.
  final GeoPoint? courierLocation;
  final DateTime? courierLocationUpdatedAt;

  final DateTime? assignedAt;
  final DateTime? updatedAt;

  const DeliveryModel({
    required this.id,
    required this.orderId,
    required this.courierId,
    required this.courierName,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    required this.customerCity,
    required this.pickupCity,
    this.pickupLocation,
    this.status = DeliveryStatus.assigned,
    this.courierLocation,
    this.courierLocationUpdatedAt,
    this.assignedAt,
    this.updatedAt,
  });

  factory DeliveryModel.fromMap(String id, Map<String, dynamic> map) {
    return DeliveryModel(
      id: id,
      orderId: map['orderId'] as String? ?? '',
      courierId: map['courierId'] as String? ?? '',
      courierName: map['courierName'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerAddress: map['customerAddress'] as String? ?? '',
      customerCity: map['customerCity'] as String? ?? '',
      pickupCity: map['pickupCity'] as String? ?? (map['customerCity'] as String? ?? ''),
      pickupLocation: map['pickupLocation'] as GeoPoint?,
      status: DeliveryStatusX.fromString(map['status'] as String? ?? 'assigned'),
      courierLocation: map['courierLocation'] as GeoPoint?,
      courierLocationUpdatedAt:
          (map['courierLocationUpdatedAt'] as Timestamp?)?.toDate(),
      assignedAt: (map['assignedAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'orderId': orderId,
      'courierId': courierId,
      'courierName': courierName,
      'customerId': customerId,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerCity': customerCity,
      'pickupCity': pickupCity,
      'pickupLocation': pickupLocation,
      'status': status.value,
      'courierLocation': courierLocation,
      if (isCreate) 'assignedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
