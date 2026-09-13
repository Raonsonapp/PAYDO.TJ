import 'package:flutter/material.dart';

import '../../../models/review_model.dart';
import 'reviews_list_view.dart';

class ReviewsScreen extends StatelessWidget {
  final ReviewTargetType targetType;
  final String targetId;
  final String targetName;

  const ReviewsScreen({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.targetName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Шарҳҳо — $targetName')),
      body: ReviewsListView(targetType: targetType, targetId: targetId),
    );
  }
}
