import 'package:json_annotation/json_annotation.dart';

part 'baby.g.dart';

@JsonSerializable()
class Baby {
  final String id;
  final String name;

  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime birthDate;

  final String? gender;
  final double? initialWeightKg;
  final double? initialHeightCm;
  final String? allergies;
  final String currentUserRole;

  const Baby({
    required this.id,
    required this.name,
    required this.birthDate,
    this.gender,
    this.initialWeightKg,
    this.initialHeightCm,
    this.allergies,
    required this.currentUserRole,
  });

  factory Baby.fromJson(Map<String, dynamic> json) => _$BabyFromJson(json);

  Map<String, dynamic> toJson() => _$BabyToJson(this);

  Baby copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    double? initialWeightKg,
    double? initialHeightCm,
    String? allergies,
    String? currentUserRole,
  }) {
    return Baby(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      initialWeightKg: initialWeightKg ?? this.initialWeightKg,
      initialHeightCm: initialHeightCm ?? this.initialHeightCm,
      allergies: allergies ?? this.allergies,
      currentUserRole: currentUserRole ?? this.currentUserRole,
    );
  }

  static DateTime _dateFromJson(String value) => DateTime.parse(value);

  static String _dateToJson(DateTime date) =>
      date.toIso8601String().split('T').first;

  @override
  String toString() =>
      'Baby(id: $id, name: $name, birthDate: $birthDate, '
      'gender: $gender, role: $currentUserRole)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Baby &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          birthDate == other.birthDate &&
          gender == other.gender &&
          initialWeightKg == other.initialWeightKg &&
          initialHeightCm == other.initialHeightCm &&
          allergies == other.allergies &&
          currentUserRole == other.currentUserRole;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        birthDate,
        gender,
        initialWeightKg,
        initialHeightCm,
        allergies,
        currentUserRole,
      );
}

@JsonSerializable()
class Caregiver {
  final String id;
  final String name;
  final String email;
  final String role;

  const Caregiver({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory Caregiver.fromJson(Map<String, dynamic> json) =>
      _$CaregiverFromJson(json);

  Map<String, dynamic> toJson() => _$CaregiverToJson(this);

  @override
  String toString() => 'Caregiver(id: $id, name: $name, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Caregiver &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          role == other.role;

  @override
  int get hashCode => Object.hash(id, name, email, role);
}
