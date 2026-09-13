import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../models/review_model.dart';
import '../domain/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reviewsRef =>
      _firestore.collection(FirestorePaths.reviews);

  String _docId({
    required String contextId,
    required ReviewTargetType targetType,
    required String targetId,
  }) =>
      '${contextId}_${targetType.value}_$targetId';

  @override
  Stream<List<ReviewModel>> watchReviewsForTarget({
    required ReviewTargetType targetType,
    required String targetId,
  }) {
    return _reviewsRef
        .where('targetType', isEqualTo: targetType.value)
        .where('targetId', isEqualTo: targetId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ReviewModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<bool> hasReviewed({
    required String contextId,
    required ReviewTargetType targetType,
    required String targetId,
  }) async {
    final docId = _docId(contextId: contextId, targetType: targetType, targetId: targetId);
    final snap = await _reviewsRef.doc(docId).get();
    return snap.exists;
  }

  @override
  Future<void> submitReview(ReviewModel review) async {
    final docId = _docId(
      contextId: review.contextId,
      targetType: review.targetType,
      targetId: review.targetId,
    );

    try {
      // PHASE 16 (қарори тарроҳӣ): ин ҷо ТАНҲО худи баҳо сабт мешавад.
      // Навсозии rating/reviewsCount-и target (products/businesses/
      // services/couriers) БЕВОСИТА аз client АНҶОМ НАМЕШАВАД — он
      // тавассути Cloud Function-и `recalculateRatingOnReviewCreated`
      // (functions/index.js, Admin SDK) сурат мегирад. Сабаб: агар
      // client-ро иҷозат медодем rating-ро бевосита нависад, ягон
      // корбари бадният метавонист rating-ро бе ягон баҳои воқеӣ
      // дасткорӣ кунад (Security Rules натавонанд санҷанд, ки "ин
      // навсозӣ воқеан аз баҳои нав меояд"). Ниг. docs/reviews.md.
      await _reviewsRef.doc(docId).set(review.toMap(isCreate: true));
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии сабти баҳо: ${e.message}');
    }
  }
}
