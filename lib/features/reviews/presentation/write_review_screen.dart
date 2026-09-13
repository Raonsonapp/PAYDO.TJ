import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../models/notification_model.dart';
import '../../../models/review_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../notifications/presentation/notification_providers.dart';
import 'review_providers.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final ReviewTargetType targetType;
  final String targetId;
  final String targetName;
  final String contextId;

  /// Танҳо барои targetType=product лозим аст — ID-и seller, то
  /// notification ба соҳиби воқеӣ фиристода шавад (products.sellerId
  /// баробар ба targetId нест, бар хилофи business/service/courier,
  /// ки documentId=ownerId/uid аст).
  final String? productSellerId;

  const WriteReviewScreen({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.contextId,
    this.productSellerId,
  });

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  int _rating = 5;
  final _textCtrl = TextEditingController();

  String? get _recipientId {
    switch (widget.targetType) {
      case ReviewTargetType.business:
      case ReviewTargetType.serviceProvider:
      case ReviewTargetType.courier:
        return widget.targetId; // documentId == ownerId/uid дар ин 3 ҳолат
      case ReviewTargetType.product:
        return widget.productSellerId;
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    final review = ReviewModel(
      id: '',
      authorId: me.uid,
      authorName: me.name,
      targetType: widget.targetType,
      targetId: widget.targetId,
      contextId: widget.contextId,
      rating: _rating,
      text: _textCtrl.text.trim(),
    );

    final ok = await ref.read(reviewSubmitControllerProvider.notifier).submit(review);

    if (ok) {
      final recipientId = _recipientId;
      if (recipientId != null && recipientId != me.uid) {
        await ref.read(createNotificationProvider)(
          recipientId: recipientId,
          type: NotificationType.review,
          title: 'Баҳои нав',
          body: '${me.name} ба шумо $_rating ситора дод.',
          contextType: widget.targetType == ReviewTargetType.business ? 'business' : null,
          contextId: widget.targetType == ReviewTargetType.business ? widget.targetId : null,
        );
      }
    }

    if (!mounted) return;
    if (ok) {
      ref.invalidate(hasReviewedProvider(
        ReviewCheckParams(widget.contextId, widget.targetType, widget.targetId),
      ));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ташаккур барои баҳои шумо!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.somethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewSubmitControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Баҳо додан')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.targetName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 24),
            StarRatingInput(
              rating: _rating,
              onChanged: (v) => setState(() => _rating = v),
              size: 42,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _textCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Шарҳи шумо (ихтиёрӣ)',
                hintText: 'Таҷрибаи шуморо чӣ гуна буд?',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isSaving ? null : _submit,
              child: state.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Фиристодан'),
            ),
          ],
        ),
      ),
    );
  }
}
