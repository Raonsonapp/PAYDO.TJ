import 'package:cloud_firestore/cloud_firestore.dart';

/// Ҳолати courier (banди 16, айнан бо ҳамин 3 ном).
enum CourierStatus { available, busy, offline }

extension CourierStatusX on CourierStatus {
  String get value => name;
  static CourierStatus fromString(String value) =>
      CourierStatus.values.firstWhere((e) => e.value == value,
          orElse: () => CourierStatus.offline);

  String get label {
    switch (this) {
      case CourierStatus.available:
        return 'Озод';
      case CourierStatus.busy:
        return 'Банд';
      case CourierStatus.offline:
        return 'Офлайн';
    }
  }
}

/// Профили courier (banди 16 спецификатсия).
/// Ҳамон нақшаи такроршавандаи "profile-per-user": documentId = uid.
class CourierModel {
  final String uid;
  final String name;
  final String phone;
  final String vehicle; // масалан "Мошин", "Мотоцикл", "Пиёда"
  final String? vehicleType; // масалан марка/рақами мошин
  final GeoPoint? location;
  final CourierStatus status;

  /// PHASE 16: баҳо (мисли products/businesses/services — навсозӣ
  /// мешавад аз ReviewRepository ҳангоми баҳои нав).
  final double rating;
  final int reviewsCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CourierModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.vehicle,
    this.vehicleType,
    this.location,
    this.status = CourierStatus.offline,
    this.rating = 0,
    this.reviewsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CourierModel.fromMap(String uid, Map<String, dynamic> map) {
    return CourierModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      vehicle: map['vehicle'] as String? ?? '',
      vehicleType: map['vehicleType'] as String?,
      location: map['location'] as GeoPoint?,
      status: CourierStatusX.fromString(map['status'] as String? ?? 'offline'),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: map['reviewsCount'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'vehicle': vehicle,
      'vehicleType': vehicleType,
      'location': location,
      'status': status.value,
      'rating': rating,
      'reviewsCount': reviewsCount,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
