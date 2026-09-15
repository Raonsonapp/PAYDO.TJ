import 'package:cloud_firestore/cloud_firestore.dart';

/// Модели бизнес (banди 9 спецификатсия).
class BusinessModel {
  final String id;
  final String ownerId; // = UserModel.uid, соҳиби бизнес
  final String businessName;
  final String? logoUrl;
  final String? coverImageUrl;
  final String description;
  final String? phone;
  final String? whatsapp;
  final String? instagramUrl;
  final String city;
  final String? address;
  final GeoPoint? location;
  final bool deliveryAvailable;
  final String? workingHours;
  final double rating;
  final int reviewsCount;
  final bool isVerified; // admin verify (banди 19/23)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BusinessModel({
    required this.id,
    required this.ownerId,
    required this.businessName,
    this.logoUrl,
    this.coverImageUrl,
    this.description = '',
    this.phone,
    this.whatsapp,
    this.instagramUrl,
    required this.city,
    this.address,
    this.location,
    this.deliveryAvailable = false,
    this.workingHours,
    this.rating = 0,
    this.reviewsCount = 0,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  factory BusinessModel.fromMap(String id, Map<String, dynamic> map) {
    return BusinessModel(
      id: id,
      ownerId: map['ownerId'] as String? ?? '',
      businessName: map['businessName'] as String? ?? '',
      logoUrl: map['logoUrl'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
      description: map['description'] as String? ?? '',
      phone: map['phone'] as String?,
      whatsapp: map['whatsapp'] as String?,
      instagramUrl: map['instagramUrl'] as String?,
      city: map['city'] as String? ?? '',
      address: map['address'] as String?,
      location: map['location'] as GeoPoint?,
      deliveryAvailable: map['deliveryAvailable'] as bool? ?? false,
      workingHours: map['workingHours'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: map['reviewsCount'] as int? ?? 0,
      isVerified: map['isVerified'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'ownerId': ownerId,
      'businessName': businessName,
      'nameLower': businessName.toLowerCase(), // PHASE 17: prefix-search
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'description': description,
      'phone': phone,
      'whatsapp': whatsapp,
      'instagramUrl': instagramUrl,
      'city': city,
      'address': address,
      'location': location,
      'deliveryAvailable': deliveryAvailable,
      'workingHours': workingHours,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isVerified': isVerified,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  BusinessModel copyWith({
    String? businessName,
    String? logoUrl,
    String? coverImageUrl,
    String? description,
    String? phone,
    String? whatsapp,
    String? instagramUrl,
    String? city,
    String? address,
    bool? deliveryAvailable,
    String? workingHours,
  }) {
    return BusinessModel(
      id: id,
      ownerId: ownerId,
      businessName: businessName ?? this.businessName,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      city: city ?? this.city,
      address: address ?? this.address,
      location: location,
      deliveryAvailable: deliveryAvailable ?? this.deliveryAvailable,
      workingHours: workingHours ?? this.workingHours,
      rating: rating,
      reviewsCount: reviewsCount,
      isVerified: isVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
