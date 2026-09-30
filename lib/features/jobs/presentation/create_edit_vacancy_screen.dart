import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/tj_cities.dart';
import '../../../models/user_model.dart';
import '../../../models/vacancy_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import 'jobs_providers.dart';

class CreateEditVacancyScreen extends ConsumerStatefulWidget {
  final VacancyModel? existing;
  const CreateEditVacancyScreen({super.key, this.existing});

  @override
  ConsumerState<CreateEditVacancyScreen> createState() => _CreateEditVacancyScreenState();
}

class _CreateEditVacancyScreenState extends ConsumerState<CreateEditVacancyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _salaryMinCtrl;
  late final TextEditingController _salaryMaxCtrl;
  late final TextEditingController _ageMinCtrl;
  late final TextEditingController _ageMaxCtrl;
  late final TextEditingController _experienceCtrl;
  late final TextEditingController _educationCtrl;
  late final TextEditingController _scheduleCtrl;
  late final TextEditingController _contactCtrl;

  String? _selectedCity;
  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final v = widget.existing;
    _titleCtrl = TextEditingController(text: v?.title ?? '');
    _descriptionCtrl = TextEditingController(text: v?.description ?? '');
    _salaryMinCtrl = TextEditingController(text: v?.salaryMin?.toStringAsFixed(0) ?? '');
    _salaryMaxCtrl = TextEditingController(text: v?.salaryMax?.toStringAsFixed(0) ?? '');
    _ageMinCtrl = TextEditingController(text: v?.ageMin?.toString() ?? '');
    _ageMaxCtrl = TextEditingController(text: v?.ageMax?.toString() ?? '');
    _experienceCtrl = TextEditingController(text: v?.experience ?? '');
    _educationCtrl = TextEditingController(text: v?.education ?? '');
    _scheduleCtrl = TextEditingController(text: v?.schedule ?? '');
    _contactCtrl = TextEditingController(text: v?.contact ?? '');
    _selectedCity = v?.city;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _ageMinCtrl.dispose();
    _ageMaxCtrl.dispose();
    _experienceCtrl.dispose();
    _educationCtrl.dispose();
    _scheduleCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Лутфан шаҳрро интихоб кунед.')));
      return;
    }

    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    final vacancy = VacancyModel(
      id: widget.existing?.id ?? '',
      employerId: me.uid,
      employerName: me.name,
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      salaryMin: double.tryParse(_salaryMinCtrl.text.trim()),
      salaryMax: double.tryParse(_salaryMaxCtrl.text.trim()),
      ageMin: int.tryParse(_ageMinCtrl.text.trim()),
      ageMax: int.tryParse(_ageMaxCtrl.text.trim()),
      city: _selectedCity!,
      experience: _experienceCtrl.text.trim().isEmpty ? null : _experienceCtrl.text.trim(),
      education: _educationCtrl.text.trim().isEmpty ? null : _educationCtrl.text.trim(),
      schedule: _scheduleCtrl.text.trim().isEmpty ? null : _scheduleCtrl.text.trim(),
      contact: _contactCtrl.text.trim().isEmpty ? null : _contactCtrl.text.trim(),
      isClosed: widget.existing?.isClosed ?? false,
    );

    final controller = ref.read(jobsActionControllerProvider.notifier);
    final ok = _isEditing
        ? await controller.updateVacancy(vacancy)
        : await controller.createVacancy(vacancy);

    if (ok && !_isEditing) {
      // Ҳангоми сохтани вакансия аз тарафи корфармо, ба accountTypes-и
      // корбар 'employer' илова мешавад (banди 15, ҳамон мантиқи PHASE 5).
      final currentUser = await ref.read(profileRepositoryProvider).getUser(me.uid);
      if (!currentUser.accountTypes.contains(AccountType.employer)) {
        await ref.read(profileRepositoryProvider).updateProfile(
              uid: me.uid,
              accountTypes: [...currentUser.accountTypes, AccountType.employer],
            );
      }
    }

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.somethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobsActionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Тағйири вакансия' : 'Вакансияи нав'),
        actions: [
          TextButton(
            onPressed: state.isSaving ? null : _save,
            child: state.isSaving
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text(AppStrings.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Номи вазифа *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ҳатмист' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Тавсиф *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ҳатмист' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _salaryMinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Маош аз (сомонӣ)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _salaryMaxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Маош то (сомонӣ)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(labelText: 'Шаҳр *'),
              items: TjCities.all.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCity = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageMinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Синну сол аз'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _ageMaxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Синну сол то'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _experienceCtrl,
              decoration: const InputDecoration(
                  labelText: 'Таҷриба', hintText: 'масалан: 1-3 сол'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _educationCtrl,
              decoration: const InputDecoration(labelText: 'Маълумот'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _scheduleCtrl,
              decoration: const InputDecoration(
                  labelText: 'Ҷадвали корӣ', hintText: 'масалан: Пурра рӳз'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactCtrl,
              decoration: const InputDecoration(labelText: 'Тамос (телефон/email)'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
