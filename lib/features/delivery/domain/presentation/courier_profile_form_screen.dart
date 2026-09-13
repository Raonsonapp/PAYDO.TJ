import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/courier_model.dart';
import '../../../models/user_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import 'delivery_providers.dart';
import 'my_deliveries_screen.dart';

class CourierProfileFormScreen extends ConsumerStatefulWidget {
  const CourierProfileFormScreen({super.key});

  @override
  ConsumerState<CourierProfileFormScreen> createState() => _CourierProfileFormScreenState();
}

class _CourierProfileFormScreenState extends ConsumerState<CourierProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _vehicleTypeCtrl = TextEditingController();
  String _vehicle = 'Мошин';
  bool _initialized = false;

  static const _vehicles = ['Мошин', 'Мотоцикл', 'Дучарха', 'Пиёда'];

  void _fillFrom(CourierModel? courier) {
    if (_initialized || courier == null) return;
    _initialized = true;
    _phoneCtrl.text = courier.phone;
    _vehicleTypeCtrl.text = courier.vehicleType ?? '';
    _vehicle = courier.vehicle.isEmpty ? 'Мошин' : courier.vehicle;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _vehicleTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    final existing = ref.read(myCourierProfileProvider).valueOrNull;

    final courier = CourierModel(
      uid: me.uid,
      name: me.name,
      phone: _phoneCtrl.text.trim(),
      vehicle: _vehicle,
      vehicleType: _vehicleTypeCtrl.text.trim().isEmpty ? null : _vehicleTypeCtrl.text.trim(),
      status: existing?.status ?? CourierStatus.offline,
    );

    final ok = await ref.read(deliveryActionControllerProvider.notifier).saveCourierProfile(courier);

    if (ok) {
      final currentUser = await ref.read(profileRepositoryProvider).getUser(me.uid);
      if (!currentUser.accountTypes.contains(AccountType.courier)) {
        await ref.read(profileRepositoryProvider).updateProfile(
              uid: me.uid,
              accountTypes: [...currentUser.accountTypes, AccountType.courier],
            );
      }
    }

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Профили courier нигоҳ дошта шуд.')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.somethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final myProfileAsync = ref.watch(myCourierProfileProvider);
    final state = ref.watch(deliveryActionControllerProvider);
    final me = ref.watch(authStateProvider).value;

    myProfileAsync.whenData(_fillFrom);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профили courier'),
        actions: [
          if (myProfileAsync.valueOrNull != null)
            IconButton(
              icon: const Icon(Icons.local_shipping_outlined),
              tooltip: 'Фармоишҳои ман',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyDeliveriesScreen()),
              ),
            ),
          TextButton(
            onPressed: state.isSaving ? null : _save,
            child: state.isSaving
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text(AppStrings.save),
          ),
        ],
      ),
      body: myProfileAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (myProfileAsync.valueOrNull != null) ...[
                    _StatusSelector(
                      current: myProfileAsync.valueOrNull!.status,
                      onChanged: (s) {
                        if (me != null) {
                          ref.read(deliveryActionControllerProvider.notifier).setMyStatus(me.uid, s);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Телефон *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ҳатмист' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _vehicle,
                    decoration: const InputDecoration(labelText: 'Намуди воситаи нақлиёт *'),
                    items: _vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setState(() => _vehicle = v ?? _vehicle),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehicleTypeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Модел/рақами мошин (ихтиёрӣ)',
                      hintText: 'масалан: Cobalt, 01 A 123 AA',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final CourierStatus current;
  final ValueChanged<CourierStatus> onChanged;
  const _StatusSelector({required this.current, required this.onChanged});

  Color _colorOf(CourierStatus s) {
    switch (s) {
      case CourierStatus.available:
        return AppColors.success;
      case CourierStatus.busy:
        return AppColors.warning;
      case CourierStatus.offline:
        return AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CourierStatus>(
      segments: CourierStatus.values
          .map((s) => ButtonSegment(
                value: s,
                label: Text(s.label),
              ))
          .toList(),
      selected: {current},
      onSelectionChanged: (s) => onChanged(s.first),
      style: SegmentedButton.styleFrom(
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: _colorOf(current),
      ),
    );
  }
}
