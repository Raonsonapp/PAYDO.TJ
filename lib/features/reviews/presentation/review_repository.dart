import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/review_model.dart';
import '../data/review_repository_impl.dart';
import '../domain/review_repository.dart';
import '../../auth/presentation/auth_providers.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl();
});

class ReviewTarget {
  final ReviewTargetType type;
  final String id;
  const ReviewTarget(this.type, this.id);

  @override
  bool operator ==(Object other) =>
      other is ReviewTarget && other.type == type && other.id == id;
  @override
  int get hashCode => Object.hash(type, id);
}

final reviewsForTargetProvider =
    StreamProvider.family<List<ReviewModel>, ReviewTarget>((ref, target) {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.watchReviewsForTarget(targetType: target.type, targetId: target.id);
});

class ReviewCheckParams {
  final String contextId;
  final ReviewTargetType targetType;
  final String targetId;
  const ReviewCheckParams(this.contextId, this.targetType, this.targetId);

  @override
  bool operator ==(Object other) =>
      other is ReviewCheckParams &&
      other.contextId == contextId &&
      other.targetType == targetType &&
      other.targetId == targetId;
  @override
  int get hashCode => Object.hash(contextId, targetType, targetId);
}

final hasReviewedProvider =
    FutureProvider.family<bool, ReviewCheckParams>((ref, params) {
  final repo = ref.watch(reviewRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Future.value(false);
  return repo.hasReviewed(
    contextId: params.contextId,
    targetType: params.targetType,
    targetId: params.targetId,
  );
});

class ReviewSubmitState {
  final bool isSaving;
  final String? errorMessage;
  const ReviewSubmitState({this.isSaving = false, this.errorMessage});

  ReviewSubmitState copyWith({bool? isSaving, String? errorMessage}) =>
      ReviewSubmitState(isSaving: isSaving ?? this.isSaving, errorMessage: errorMessage);
}

class ReviewSubmitController extends StateNotifier<ReviewSubmitState> {
  final ReviewRepository _repository;
  ReviewSubmitController(this._repository) : super(const ReviewSubmitState());

  Future<bool> submit(ReviewModel review) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.submitReview(review);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Хатогии сабти баҳо.');
      return false;
    }
  }
}

final reviewSubmitControllerProvider =
    StateNotifierProvider<ReviewSubmitController, ReviewSubmitState>((ref) {
  final repo = ref.watch(reviewRepositoryProvider);
  return ReviewSubmitController(repo);
});
