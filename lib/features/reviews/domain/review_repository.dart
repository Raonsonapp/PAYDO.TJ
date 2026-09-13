import '../../../models/review_model.dart';

abstract class ReviewRepository {
  Stream<List<ReviewModel>> watchReviewsForTarget({
    required ReviewTargetType targetType,
    required String targetId,
  });

  /// Санҷиши пешгирии такрор (banди 20) — ниг. эзоҳи тарроҳӣ дар
  /// lib/models/review_model.dart.
  Future<bool> hasReviewed({
    required String contextId,
    required ReviewTargetType targetType,
    required String targetId,
  });

  /// Сохтани баҳо ВА навсозии rating/reviewsCount-и target дар як
  /// амали атомӣ (Firestore transaction) — ниг. эзоҳ дар impl.
  Future<void> submitReview(ReviewModel review);
}
