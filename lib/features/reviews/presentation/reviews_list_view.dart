import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/review_model.dart';
import 'review_providers.dart';

/// Рӯйхати баҳоҳо барои як target (product/business/service/courier).
/// Истифодаи такрорӣ — на дар ҳар феҷа аз нав навишта мешавад.
class ReviewsListView extends ConsumerWidget {
  final ReviewTargetType targetType;
  final String targetId;

  const ReviewsListView({super.key, required this.targetType, required this.targetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync =
        ref.watch(reviewsForTargetProvider(ReviewTarget(targetType, targetId)));

    return reviewsAsync.when(
      loading: () => const LoadingView(),
      error: (e, _) => const ErrorView(),
      data: (reviews) {
        if (reviews.isEmpty) {
          return const EmptyView(
            message: 'Ҳанӯз шарҳе нест.',
            icon: Icons.star_border_rounded,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (context, index) => _ReviewTile(review: reviews[index]),
        );
      },
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(review.authorName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            if (review.createdAt != null)
              Text(
                DateFormat('dd.MM.yyyy').format(review.createdAt!),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            5,
            (i) => Icon(
              i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
              size: 16,
              color: AppColors.warning,
            ),
          ),
        ),
        if (review.text.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(review.text, style: const TextStyle(fontSize: 13)),
        ],
      ],
    );
  }
}
