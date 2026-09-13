import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import 'courier_profile_form_screen.dart';
import 'delivery_providers.dart';
import 'my_deliveries_screen.dart';

/// Нуқтаи вуруд барои PHASE 12 аз категорияи "Доставка" дар Home.
/// Худи ҷараёни доставка (таъин кардан, пешрафти status) дар дохили
/// Seller Orders (PHASE 7) ва ин ҷо (барои courier) сурат мегирад —
/// ин экран танҳо "дарвоза" аст.
class DeliveryHomeScreen extends ConsumerWidget {
  const DeliveryHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courierAsync = ref.watch(myCourierProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Доставка')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Доставкаи фармоишҳо байни дӯкон ва мизоҷ тавассути courier '
                    'идора карда мешавад.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          courierAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const SizedBox.shrink(),
            data: (courier) => Card(
              child: ListTile(
                leading: Icon(
                  Icons.badge_outlined,
                  color: courier != null ? AppColors.primary : AppColors.textSecondaryLight,
                ),
                title: Text(courier != null ? 'Профили courier' : 'Courier шудан'),
                subtitle: Text(
                  courier != null
                      ? 'Ҳолат: ${courier.status.label}'
                      : 'Барои расонидани фармоишҳо ва даромади иловагӣ',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CourierProfileFormScreen()),
                ),
              ),
            ),
          ),
          if (courierAsync.valueOrNull != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.list_alt_outlined, color: AppColors.primary),
                title: const Text('Фармоишҳои ман'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyDeliveriesScreen()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
