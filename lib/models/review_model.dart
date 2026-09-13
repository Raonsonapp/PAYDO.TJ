import 'package:cloud_firestore/cloud_firestore.dart';

/// Ҳадафи баҳо (banди 20: "seller, product, service provider, courier").
/// "seller" дар ин лоиҳа = business (ниг. эзоҳи тарроҳӣ дар
/// docs/architecture.md — баҳо ба seller-и бе Business Profile дода
/// намешавад, танҳо ба худи маҳсулот).
enum ReviewTargetType { product, business, serviceProvider, courier }

extension ReviewTargetTypeX on ReviewTargetType {
  String get value => name;
  static ReviewTargetType fromString(String value) =>
      ReviewTargetType.values.firstWhere((e) => e.value == value,
          orElse: () => ReviewTargetType.product);

  /// Номи коллексияе, ки rating/reviewsCount-и он бояд навсозӣ шавад.
  String get targetCollection {
    switch (this) {
      case ReviewTargetType.product:
        return 'products';
      case ReviewTargetType.business:
        return 'businesses';
      case ReviewTargetType.serviceProvider:
        return 'services';
      case ReviewTargetType.courier:
        return 'couriers';
    }
  }
}

/// Баҳо/шарҳ (banди 20 ва 27: `reviews`).
///
/// Қарори тарроҳии пешгирии такрор: documentId ДЕТЕРМИНИСТӢ аст —
/// `{contextId}_{targetType}_{targetId}` (contextId = orderId ё
/// serviceOrderId-и АНҶОМЁФТА). Азбаски ҳар order/serviceOrder ба ЯК
/// customerId тааллуқ дорад, ин ба таври табиӣ "ҳамин харидор аллакай
/// барои ҳамин фармоиш баҳо додааст" -ро пешгирӣ мекунад — бе ниёз ба
/// authorId дар docId (ҳамон мантиқи favorites/chats/job_applications).
class ReviewModel {
  final String id;
  final String authorId;
  final String authorName;
  final ReviewTargetType targetType;
  final String targetId;
  final String contextId; // orderId ё serviceOrderId-и анҷомёфта
  final int rating; // 1-5
  final String text;
  final DateTime? createdAt;

  const ReviewModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.targetType,
    required this.targetId,
    required this.contextId,
    required this.rating,
    this.text = '',
    this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      targetType: ReviewTargetTypeX.fromString(map['targetType'] as String? ?? 'product'),
      targetId: map['targetId'] as String? ?? '',
      contextId: map['contextId'] as String? ?? '',
      rating: map['rating'] as int? ?? 5,
      text: map['text'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'targetType': targetType.value,
      'targetId': targetId,
      'contextId': contextId,
      'rating': rating,
      'text': text,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
