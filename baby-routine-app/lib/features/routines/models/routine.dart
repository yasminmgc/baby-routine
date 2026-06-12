import 'package:json_annotation/json_annotation.dart';

part 'routine.g.dart';

@JsonSerializable()
class Routine {
  final String id;
  final String babyId;
  final String activityType;
  final int? intervalMinutes;
  final String? defaultStartTime;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Routine({
    required this.id,
    required this.babyId,
    required this.activityType,
    this.intervalMinutes,
    this.defaultStartTime,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Routine.fromJson(Map<String, dynamic> json) =>
      _$RoutineFromJson(json);

  Map<String, dynamic> toJson() => _$RoutineToJson(this);

  Routine copyWith({
    String? id,
    String? babyId,
    String? activityType,
    int? intervalMinutes,
    String? defaultStartTime,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Routine(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      activityType: activityType ?? this.activityType,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      defaultStartTime: defaultStartTime ?? this.defaultStartTime,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Routine(id: $id, activityType: $activityType, active: $active)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Routine &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          babyId == other.babyId &&
          activityType == other.activityType &&
          intervalMinutes == other.intervalMinutes &&
          defaultStartTime == other.defaultStartTime &&
          active == other.active;

  @override
  int get hashCode => Object.hash(
        id,
        babyId,
        activityType,
        intervalMinutes,
        defaultStartTime,
        active,
      );
}
