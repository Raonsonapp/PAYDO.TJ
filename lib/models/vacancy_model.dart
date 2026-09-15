import 'package:cloud_firestore/cloud_firestore.dart';

/// Вакансия (banди 13 спецификатсия).
class VacancyModel {
  final String id;
  final String employerId;
  final String employerName;
  final String title;
  final String description;
  final double? salaryMin;
  final double? salaryMax;
  final int? ageMin;
  final int? ageMax;
  final String city;
  final String? experience; // озод-матн, масалан "1-3 сол"
  final String? education;
  final String? schedule; // масалан "Пурра рӳз", "Нимрӳза"
  final String? contact;
  final bool isClosed; // вакансия пур шуд ё бекор карда шуд
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VacancyModel({
    required this.id,
    required this.employerId,
    required this.employerName,
    required this.title,
    required this.description,
    this.salaryMin,
    this.salaryMax,
    this.ageMin,
    this.ageMax,
    required this.city,
    this.experience,
    this.education,
    this.schedule,
    this.contact,
    this.isClosed = false,
    this.createdAt,
    this.updatedAt,
  });

  String get salaryRangeLabel {
    if (salaryMin == null && salaryMax == null) return 'Мувофиқа мешавад';
    if (salaryMin != null && salaryMax != null) {
      return '${salaryMin!.toStringAsFixed(0)} - ${salaryMax!.toStringAsFixed(0)} с.';
    }
    return '${(salaryMin ?? salaryMax)!.toStringAsFixed(0)} с.';
  }

  /// Мутобиқат бо профили корҷӳ (banди 13: "Matching: city, age, salary,
  /// profession, experience"). Ин функсия дар UI (worker → vacancy list)
  /// барои ҳисоб кардани "мутобиқ ё не" истифода мешавад.
  bool matchesAge(int? workerAge) {
    if (workerAge == null) return true;
    if (ageMin != null && workerAge < ageMin!) return false;
    if (ageMax != null && workerAge > ageMax!) return false;
    return true;
  }

  factory VacancyModel.fromMap(String id, Map<String, dynamic> map) {
    return VacancyModel(
      id: id,
      employerId: map['employerId'] as String? ?? '',
      employerName: map['employerName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      salaryMin: (map['salaryMin'] as num?)?.toDouble(),
      salaryMax: (map['salaryMax'] as num?)?.toDouble(),
      ageMin: map['ageMin'] as int?,
      ageMax: map['ageMax'] as int?,
      city: map['city'] as String? ?? '',
      experience: map['experience'] as String?,
      education: map['education'] as String?,
      schedule: map['schedule'] as String?,
      contact: map['contact'] as String?,
      isClosed: map['isClosed'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'employerId': employerId,
      'employerName': employerName,
      'title': title,
      'titleLower': title.toLowerCase(), // PHASE 17: prefix-search
      'description': description,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'ageMin': ageMin,
      'ageMax': ageMax,
      'city': city,
      'experience': experience,
      'education': education,
      'schedule': schedule,
      'contact': contact,
      'isClosed': isClosed,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
