import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/courier_model.dart';
import '../../../models/order_model.dart';
import 'delivery_providers.dart';

class AssignCourierScreen extends ConsumerWidget {
  final OrderModel order;
  const AssignCourierScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couriersAsync = ref.watch(availableCouriersProvider);
    final state = ref.watch(deliveryActionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Таъини courier')),
      body: couriersAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(availableCouriersProvider)),
        data: (couriers) {
          if (couriers.isEmpty) {
            return const EmptyView(
              message: 'Ҳоло courier-и озод нест.',
              icon: Icons.local_shipping_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: couriers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final courier = couriers[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.delivery_dining_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(courier.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${courier.vehicle}${courier.vehicleType != null ? ' · ${courier.vehicleType}' : ''}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: state.isSaving
                          ? null
                          : () => _assign(context, ref, courier),
                      child: const Text('Таъин кардан'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _assign(BuildContext context, WidgetRef ref, CourierModel courier) async {
    final ok = await ref
        .read(deliveryActionControllerProvider.notifier)
        .assignCourier(order: order, courier: courier);

    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${courier.name} таъин карда шуд.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Хатогии таъини courier.')),
      );
    }
  }
}
