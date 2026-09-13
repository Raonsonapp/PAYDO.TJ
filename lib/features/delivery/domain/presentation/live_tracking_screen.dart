import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../core/constants/tj_city_coordinates.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/delivery_model.dart';
import '../../maps/presentation/map_screen.dart' show osmDemoStyleUrl;
import 'delivery_providers.dart';

/// Экрани customer барои пайгирии зиндаи доставка (banди 18):
/// 🏪 Store → 🚚 Courier (зинда) → 📍 Customer.
class LiveTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const LiveTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  MapLibreMapController? _controller;

  Future<void> _redraw(DeliveryModel? delivery) async {
    final controller = _controller;
    if (controller == null || delivery == null) return;

    await controller.clearCircles();
    await controller.clearLines();

    final pickup = TjCityCoordinates.of(delivery.pickupCity);
    final pickupPoint = delivery.pickupLocation != null
        ? LatLng(delivery.pickupLocation!.latitude, delivery.pickupLocation!.longitude)
        : LatLng(pickup.lat, pickup.lng);

    final customer = TjCityCoordinates.of(delivery.customerCity);
    final customerPoint = LatLng(customer.lat, customer.lng);

    LatLng? courierPoint;
    if (delivery.courierLocation != null) {
      courierPoint =
          LatLng(delivery.courierLocation!.latitude, delivery.courierLocation!.longitude);
    }

    // 🏪 Store
    await controller.addCircle(CircleOptions(
      geometry: pickupPoint,
      circleRadius: 9,
      circleColor: '#12B76A',
      circleStrokeColor: '#FFFFFF',
      circleStrokeWidth: 2,
    ));

    // 📍 Customer
    await controller.addCircle(CircleOptions(
      geometry: customerPoint,
      circleRadius: 9,
      circleColor: '#F04438',
      circleStrokeColor: '#FFFFFF',
      circleStrokeWidth: 2,
    ));

    // 🚚 Courier (зинда — танҳо агар GPS фаъол бошад)
    if (courierPoint != null) {
      await controller.addCircle(CircleOptions(
        geometry: courierPoint,
        circleRadius: 11,
        circleColor: '#2563EB',
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 3,
      ));
    }

    // Масири соддаи хаттӣ (на роутинги воқеӣ — ниг. эзоҳи banди 36:
    // "advanced delivery routing" қасдан ба оянда гузошта шудааст).
    final routePoints = [pickupPoint, if (courierPoint != null) courierPoint, customerPoint];
    await controller.addLine(LineOptions(
      geometry: routePoints,
      lineColor: '#94A3B8',
      lineWidth: 3,
      lineOpacity: 0.8,
    ));

    // Камераро ба ҳудуди се нуқта мутобиқ кунем.
    final lats = routePoints.map((p) => p.latitude).toList();
    final lngs = routePoints.map((p) => p.longitude).toList();
    await controller.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(lats.reduce((a, b) => a < b ? a : b), lngs.reduce((a, b) => a < b ? a : b)),
        northeast: LatLng(lats.reduce((a, b) => a > b ? a : b), lngs.reduce((a, b) => a > b ? a : b)),
      ),
      left: 60,
      top: 60,
      right: 60,
      bottom: 60,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final deliveryAsync = ref.watch(deliveryForOrderProvider(widget.orderId));

    ref.listen(deliveryForOrderProvider(widget.orderId), (previous, next) {
      next.whenData(_redraw);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Пайгирии доставка')),
      body: deliveryAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => const ErrorView(),
        data: (delivery) {
          if (delivery == null) {
            return const EmptyView(
              message: 'Ҳанӯз courier таъин нашудааст.',
              icon: Icons.local_shipping_outlined,
            );
          }
          return Stack(
            children: [
              MapLibreMap(
                styleString: osmDemoStyleUrl,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(TjCityCoordinates.country.lat, TjCityCoordinates.country.lng),
                  zoom: TjCityCoordinates.countryZoom,
                ),
                onMapCreated: (c) => _controller = c,
                onStyleLoadedCallback: () => _redraw(delivery),
              ),
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: _StatusBanner(delivery: delivery),
              ),
              const Positioned(left: 8, bottom: 8, child: _Legend()),
            ],
          );
        },
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final DeliveryModel delivery;
  const _StatusBanner({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final hasLiveGps = delivery.courierLocation != null;
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(14),
      color: AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              hasLiveGps ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
              color: hasLiveGps ? AppColors.success : AppColors.textSecondaryLight,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${delivery.courierName} · ${delivery.status.label}'
                '${hasLiveGps ? '' : ' (GPS ҳанӯз фаъол нашуд)'}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendRow(color: Color(0xFF12B76A), label: '🏪 Дӯкон'),
          _LegendRow(color: Color(0xFF2563EB), label: '🚚 Courier'),
          _LegendRow(color: Color(0xFFF04438), label: '📍 Шумо'),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
