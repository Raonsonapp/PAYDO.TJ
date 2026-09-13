import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/review_model.dart';

void main() {
  group('ReviewModel', () {
    test('fromMap намуди дурустро мехонад', () {
      final map = {
        'authorId': 'u1',
        'authorName': 'Алишер',
        'targetType': 'business',
        'targetId': 'b1',
        'contextId': 'o1',
        'rating': 4,
        'text': 'Хуб буд',
      };
      final review = ReviewModel.fromMap('o1_business_b1', map);

      expect(review.targetType, ReviewTargetType.business);
      expect(review.rating, 4);
      expect(review.id, 'o1_business_b1');
    });

    test('targetCollection мутобиқати дурустро дорад', () {
      expect(ReviewTargetType.product.targetCollection, 'products');
      expect(ReviewTargetType.business.targetCollection, 'businesses');
      expect(ReviewTargetType.serviceProvider.targetCollection, 'services');
      expect(ReviewTargetType.courier.targetCollection, 'couriers');
    });

    test('намуди номаълум ба product fallback мекунад', () {
      expect(ReviewTargetTypeX.fromString('unknown'), ReviewTargetType.product);
    });
  });

  group('Формулаи миёнаи rating (мутобиқ ба functions/index.js)', () {
    double recalcRating(double oldRating, int oldCount, int newReviewRating) {
      final newCount = oldCount + 1;
      return ((oldRating * oldCount) + newReviewRating) / newCount;
    }

    test('якум баҳо → rating баробар ба худи баҳо', () {
      expect(recalcRating(0, 0, 5), 5);
    });

    test('баҳои дуввум миёнаро дуруст ҳисоб мекунад', () {
      // Баҳои якум 5, дуввум 3 → миёна 4
      expect(recalcRating(5, 1, 3), 4);
    });
  });
}
