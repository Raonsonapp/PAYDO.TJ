import 'package:cloud_firestore/cloud_firestore.dart';

/// Профили хизматрасон (banди 14 спецификатсия).
/// Қарори тарроҳӣ: ҳамон нақшаи `businesses/{ownerId}` ва
/// `worker_profiles/{uid}` — documentId = uid, як профил барои ҳар корбар.
class ServiceProviderModel {
  final String uid;
  final String name;
  final String? photoUrl;
  final String serviceCategory; // аз ServiceCategories.all
  final String description;
  final double? price; // нархи ибтидоӣ/соатона — озод-матн дар оянда лозим шавад
  final String city;
  final GeoPoint? location;
  final String? phone;
  final String? whatsapp;
  final String? instagramUrl;
  final double rating;
  final int reviewsCount;
  final bool isVisible;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceProviderModel({
    required this.uid,
    required this.name,
    this.photoUrl,
    required this.serviceCategory,
    this.description = '',
    this.price,
    required this.city,
    this.location,
    this.phone,
    this.whatsapp,
    this.instagramUrl,
    this.rating = 0,
    this.reviewsCount = 0,
    this.isVisible = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceProviderModel.fromMap(String uid, Map<String, dynamic> map) {
    return ServiceProviderModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      serviceCategory: map['serviceCategory'] as String? ?? 'Other',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble(),
      city: map['city'] as String? ?? '',
      location: map['location'] as GeoPoint?,
      phone: map['phone'] as String?,
      whatsapp: map['whatsapp'] as String?,
      instagramUrl: map['instagramUrl'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: map['reviewsCount'] as int? ?? 0,
      isVisible: map['isVisible'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'uid': uid,
      'name': name,
      'nameLower': name.toLowerCase(), // PHASE 17: prefix-search
      'photoUrl': photoUrl,
      'serviceCategory': serviceCategory,
      'description': description,
      'price': price,
      'city': city,
      'location': location,
      'phone': phone,
      'whatsapp': whatsapp,
      'instagramUrl': instagramUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isVisible': isVisible,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
