import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/delivery_model.dart';
import 'delivery_providers.dart';
import 'live_tracking_screen.dart';

/// Истифода дар `OrderHistoryScreen` (PHASE 7) — агар барои ин order
/// courier таъин шуда бошад, статуси доставкаро нишон медиҳад ва
/// tap мебарад ба Live Tracking (PHASE 14). Агар ҳанӯз courier таъин
/// нашуда бошад, ҳеҷ чиз намоён намешавад (SizedBox.shrink).
class DeliveryStatusChip extends ConsumerWidget {
  final String orderId;
  const DeliveryStatusChip({super.key, required this.orderId});

  Color _colorOf(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.assigned:
        return AppColors.warning;
      case DeliveryStatus.pickedUp:
        return AppColors.info;
      case DeliveryStatus.onTheWay:
        return AppColors.primary;
      case DeliveryStatus.delivered:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryAsync = ref.watch(deliveryForOrderProvider(orderId));

    return deliveryAsync.maybeWhen(
      data: (delivery) {
        if (delivery == null) return const SizedBox.shrink();
        final color = _colorOf(delivery.status);
        final canTrack = delivery.status != DeliveryStatus.delivered;

        return InkWell(
          onTap: canTrack
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LiveTrackingScreen(orderId: orderId)),
                  )
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_shipping_outlined, size: 12, color: color),
                const SizedBox(width: 4),
                Text('${delivery.courierName}: ${delivery.status.label}',
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                if (canTrack) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, size: 14, color: color),
                ],
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
