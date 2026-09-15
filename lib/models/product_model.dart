import 'package:cloud_firestore/cloud_firestore.dart';

/// Модели маҳсулот (banди 8 спецификатсия).
/// PHASE 6 (Product management) ин модели ҳаминро барои create/update
/// истифода мебарад — бинобар ин дар lib/models/ (муштарак), на
/// дар features/marketplace/, то дучандиягӣ набошад.
class ProductModel {
  final String id;
  final String sellerId;
  final String? businessId;
  final String name;
  final String description;
  final double price;
  final double? purchasePrice; // нархи харид (PHASE 11: Дафтари ҳисоб — фоида)
  final double? oldPrice;
  final int? discount; // фоиз, масалан 20 = 20%
  final List<String> images;
  final String category;
  final int quantity;
  final String city;
  final GeoPoint? location;
  final bool deliveryAvailable;
  final double rating;
  final int reviewsCount;
  final bool isHidden;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.sellerId,
    this.businessId,
    required this.name,
    required this.description,
    required this.price,
    this.purchasePrice,
    this.oldPrice,
    this.discount,
    this.images = const [],
    required this.category,
    this.quantity = 0,
    required this.city,
    this.location,
    this.deliveryAvailable = false,
    this.rating = 0,
    this.reviewsCount = 0,
    this.isHidden = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAvailable => quantity > 0 && !isHidden;
  String get primaryImage => images.isNotEmpty ? images.first : '';
  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  /// Фоида барои як дона (PHASE 11: Дафтари ҳисоб). null агар
  /// нархи харид ворид карда нашуда бошад.
  double? get profitPerUnit => purchasePrice != null ? price - purchasePrice! : null;

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      sellerId: map['sellerId'] as String? ?? '',
      businessId: map['businessId'] as String?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble(),
      oldPrice: (map['oldPrice'] as num?)?.toDouble(),
      discount: map['discount'] as int?,
      images: (map['images'] as List?)?.map((e) => e as String).toList() ??
          const [],
      category: map['category'] as String? ?? 'Other',
      quantity: map['quantity'] as int? ?? 0,
      city: map['city'] as String? ?? '',
      location: map['location'] as GeoPoint?,
      deliveryAvailable: map['deliveryAvailable'] as bool? ?? false,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: map['reviewsCount'] as int? ?? 0,
      isHidden: map['isHidden'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'sellerId': sellerId,
      'businessId': businessId,
      'name': name,
      'nameLower': name.toLowerCase(), // PHASE 17: prefix-search (Firestore)
      'description': description,
      'price': price,
      'purchasePrice': purchasePrice,
      'oldPrice': oldPrice,
      'discount': discount,
      'images': images,
      'category': category,
      'quantity': quantity,
      'city': city,
      'location': location,
      'deliveryAvailable': deliveryAvailable,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isHidden': isHidden,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
