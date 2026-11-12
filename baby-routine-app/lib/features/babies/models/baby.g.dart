// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baby.dart';

// ===========================================================================
// Baby
// ===========================================================================

Baby _$BabyFromJson(Map<String, dynamic> json) => Baby(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] as String?,
      initialWeightKg: (json['initialWeightKg'] as num?)?.toDouble(),
      initialHeightCm: (json['initialHeightCm'] as num?)?.toDouble(),
      allergies: json['allergies'] as String?,
      currentUserRole: json['currentUserRole'] as String,
    );

Map<String, dynamic> _$BabyToJson(Baby instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'birthDate': instance.birthDate.toIso8601String().split('T').first,
      if (instance.gender != null) 'gender': instance.gender,
      if (instance.initialWeightKg != null)
        'initialWeightKg': instance.initialWeightKg,
      if (instance.initialHeightCm != null)
        'initialHeightCm': instance.initialHeightCm,
      if (instance.allergies != null) 'allergies': instance.allergies,
      'currentUserRole': instance.currentUserRole,
    };

// ===========================================================================
// Caregiver
// ===========================================================================

Caregiver _$CaregiverFromJson(Map<String, dynamic> json) => Caregiver(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$CaregiverToJson(Caregiver instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
    };
