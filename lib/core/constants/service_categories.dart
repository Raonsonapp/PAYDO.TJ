import 'package:flutter/material.dart';

/// Категорияҳои хизматрасонӣ (banди 14 спецификатсия).
class ServiceCategories {
  ServiceCategories._();

  static const List<String> all = [
    'Electrician',
    'Plumber',
    'Welder',
    'Construction',
    'Cleaning',
    'IT',
    'PhoneRepair',
    'ComputerRepair',
    'CarRepair',
    'Photographer',
    'Designer',
    'Tutor',
    'Courier',
    'Beauty',
    'Other',
  ];

  static String labelOf(String key) {
    switch (key) {
      case 'Electrician':
        return 'Барқчӣ';
      case 'Plumber':
        return 'Сантехник';
      case 'Welder':
        return 'Дуредгар/Кайнокор';
      case 'Construction':
        return 'Сохтмон';
      case 'Cleaning':
        return 'Тозакунӣ';
      case 'IT':
        return 'IT';
      case 'PhoneRepair':
        return 'Таъмири телефон';
      case 'ComputerRepair':
        return 'Таъмири компютер';
      case 'CarRepair':
        return 'Таъмири мошин';
      case 'Photographer':
        return 'Аксбардор';
      case 'Designer':
        return 'Дизайнер';
      case 'Tutor':
        return 'Муаллим';
      case 'Courier':
        return 'Курьер';
      case 'Beauty':
        return 'Зебоӣ';
      default:
        return 'Дигар';
    }
  }

  static IconData iconOf(String key) {
    switch (key) {
      case 'Electrician':
        return Icons.electrical_services_outlined;
      case 'Plumber':
        return Icons.plumbing_outlined;
      case 'Welder':
        return Icons.construction_outlined;
      case 'Construction':
        return Icons.foundation_outlined;
      case 'Cleaning':
        return Icons.cleaning_services_outlined;
      case 'IT':
        return Icons.computer_outlined;
      case 'PhoneRepair':
        return Icons.phone_iphone_outlined;
      case 'ComputerRepair':
        return Icons.laptop_mac_outlined;
      case 'CarRepair':
        return Icons.car_repair_outlined;
      case 'Photographer':
        return Icons.camera_alt_outlined;
      case 'Designer':
        return Icons.brush_outlined;
      case 'Tutor':
        return Icons.school_outlined;
      case 'Courier':
        return Icons.delivery_dining_outlined;
      case 'Beauty':
        return Icons.spa_outlined;
      default:
        return Icons.build_outlined;
    }
  }
}
