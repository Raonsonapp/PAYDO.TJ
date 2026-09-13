import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/delivery_model.dart';
import '../../auth/presentation/auth_providers.dart';
import 'delivery_providers.dart';

/// Экрани courier барои як delivery мушаххас — ин ҷо GPS-и зинда
/// (banди 18) фаъол/хомӯш карда мешавад. Tracking ҲАРГИЗ худкор оғоз
/// намешавад: корбар бояд тугмаи "Фаъол кардани GPS"-ро худаш пахш
/// кунад (ризояти ошкоро, дар болои иҷозати OS).
class ActiveDeliveryScreen extends ConsumerStatefulWidget {
  final DeliveryModel delivery;
  const ActiveDeliveryScreen({super.key, required this.delivery});

  @override
  ConsumerState<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends ConsumerState<ActiveDeliveryScreen> {
  @override
  void dispose() {
    // Агар корбар аз экран барояд, tracking-и ин delivery қатъ мешавад
    // (батарея сарф намешавад бе зарурат).
    ref.read(locationTrackingControllerProvider.notifier).stopTracking();
    super.dispose();
  }

  Future<void> _toggleTracking() async {
    final controller = ref.read(locationTrackingControllerProvider.notifier);
    if (ref.read(locationTrackingControllerProvider)) {
      await controller.stopTracking();
      return;
    }

    final result = await controller.startTracking(widget.delivery.id);
    if (!mounted) return;

    String? message;
    switch (result) {
      case LocationPermissionResult.granted:
        message = null;
        break;
      case LocationPermissionResult.denied:
        message = 'Иҷозати GPS дода нашуд.';
        break;
      case LocationPermissionResult.deniedForever:
        message = 'Иҷозати GPS бастааст — аз танзимоти телефон фаъол кунед.';
        break;
      case LocationPermissionResult.serviceDisabled:
        message = 'GPS-и телефон хомӯш аст — онро фаъол кунед.';
        break;
    }
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTracking = ref.watch(locationTrackingControllerProvider);
    final myUid = ref.watch(authStateProvider).value?.uid ?? '';
    final next = widget.delivery.status.next;

    return Scaffold(
      appBar: AppBar(title: const Text('Доставкаи ҷорӣ')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.delivery.customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                          '${widget.delivery.customerAddress}, ${widget.delivery.customerCity}'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined,
                        size: 16, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text('Гирифтан аз: ${widget.delivery.pickupCity}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isTracking
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  isTracking ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
                  size: 36,
                  color: isTracking ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(height: 8),
                Text(
                  isTracking
                      ? 'GPS фаъол аст — мизоҷ ҷои шуморо мебинад'
                      : 'GPS хомӯш аст — мизоҷ ҳанӯз ҷои шуморо намебинад',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(isTracking ? Icons.stop_circle_outlined : Icons.play_circle_outline),
                    label: Text(isTracking ? 'Хомӯш кардани GPS' : 'Фаъол кардани GPS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTracking ? AppColors.error : AppColors.primary,
                    ),
                    onPressed: _toggleTracking,
                  ),
                ),
              ],
            ),
          ),
          if (next != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(deliveryActionControllerProvider.notifier).advanceDeliveryStatus(
                        delivery: widget.delivery,
                        courierId: myUid,
                      );
                  if (next == DeliveryStatus.delivered) {
                    await ref.read(locationTrackingControllerProvider.notifier).stopTracking();
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text('→ ${next.label}'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
