import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/delivery_model.dart';
import 'active_delivery_screen.dart';
import 'delivery_providers.dart';

class MyDeliveriesScreen extends ConsumerWidget {
  const MyDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesAsync = ref.watch(myDeliveriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Фармоишҳои ман (Courier)')),
      body: deliveriesAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(myDeliveriesProvider)),
        data: (deliveries) {
          final active =
              deliveries.where((d) => d.status != DeliveryStatus.delivered).toList();
          final done = deliveries.where((d) => d.status == DeliveryStatus.delivered).toList();

          if (deliveries.isEmpty) {
            return const EmptyView(
              message: 'Ҳанӯз фармоише ба шумо таъин нашудааст.',
              icon: Icons.local_shipping_outlined,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active.isNotEmpty) ...[
                const Text('Дар роҳ', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...active.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DeliveryTile(delivery: d),
                    )),
                const SizedBox(height: 12),
              ],
              if (done.isNotEmpty) ...[
                const Text('Анҷомёфта', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...done.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DeliveryTile(delivery: d),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DeliveryTile extends ConsumerWidget {
  final DeliveryModel delivery;
  const _DeliveryTile({required this.delivery});

  Color get _statusColor {
    switch (delivery.status) {
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
    final next = delivery.status.next;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: next == null
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ActiveDeliveryScreen(delivery: delivery)),
              ),
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(delivery.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(delivery.status.label,
                    style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${delivery.customerAddress}, ${delivery.customerCity}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.gps_fixed_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Кушодан — GPS ва ҳолат (→ ${next.label})',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }
}
