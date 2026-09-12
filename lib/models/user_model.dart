import 'package:cloud_firestore/cloud_firestore.dart';

/// Намудҳои account, ки дар спецификация зикр шудаанд.
/// Як корбар метавонад дар оянда якчанд role дошта бошад
/// (масалан ҳам customer, ҳам seller) — барои ҳамин accountTypes
/// list аст, на як enum-и ягона.
enum AccountType { user, business, worker, employer, courier, admin }

extension AccountTypeX on AccountType {
  String get value => name;

  static AccountType fromString(String value) {
    return AccountType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AccountType.user,
    );
  }
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final int? age;
  final String? nickname;
  final String? photoUrl;
  final String? instagramUrl;
  final String? whatsapp;
  final String? city;
  final List<AccountType> accountTypes;

  /// PHASE 15: FCM device token — барои фиристодани push notification
  /// ба ин корбар (тавассути Cloud Function, ниг. docs/notifications.md).
  final String? fcmToken;

  /// Privacy: агар phone/age бояд пинҳон бошад.
  final bool phoneVisible;
  final bool ageVisible;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.age,
    this.nickname,
    this.photoUrl,
    this.instagramUrl,
    this.whatsapp,
    this.city,
    this.accountTypes = const [AccountType.user],
    this.fcmToken,
    this.phoneVisible = false,
    this.ageVisible = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Профили нав аз маълумоти Google Sign-In (истифода ҳангоми Phase 1).
  factory UserModel.newFromGoogle({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      accountTypes: const [AccountType.user],
    );
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      age: map['age'] as int?,
      nickname: map['nickname'] as String?,
      photoUrl: map['photoUrl'] as String?,
      instagramUrl: map['instagramUrl'] as String?,
      whatsapp: map['whatsapp'] as String?,
      city: map['city'] as String?,
      accountTypes: ((map['accountTypes'] as List?) ?? const ['user'])
          .map((e) => AccountTypeX.fromString(e as String))
          .toList(),
      phoneVisible: map['phoneVisible'] as bool? ?? false,
      ageVisible: map['ageVisible'] as bool? ?? false,
      fcmToken: map['fcmToken'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'nickname': nickname,
      'photoUrl': photoUrl,
      'instagramUrl': instagramUrl,
      'whatsapp': whatsapp,
      'city': city,
      'accountTypes': accountTypes.map((e) => e.value).toList(),
      'phoneVisible': phoneVisible,
      'ageVisible': ageVisible,
      'fcmToken': fcmToken,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    int? age,
    String? nickname,
    String? photoUrl,
    String? instagramUrl,
    String? whatsapp,
    String? city,
    List<AccountType>? accountTypes,
    bool? phoneVisible,
    bool? ageVisible,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      nickname: nickname ?? this.nickname,
      photoUrl: photoUrl ?? this.photoUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      whatsapp: whatsapp ?? this.whatsapp,
      city: city ?? this.city,
      accountTypes: accountTypes ?? this.accountTypes,
      phoneVisible: phoneVisible ?? this.phoneVisible,
      ageVisible: ageVisible ?? this.ageVisible,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
