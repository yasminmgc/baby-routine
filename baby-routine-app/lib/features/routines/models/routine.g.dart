// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

Routine _$RoutineFromJson(Map<String, dynamic> json) => Routine(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      activityType: json['activityType'] as String,
      intervalMinutes: json['intervalMinutes'] as int?,
      defaultStartTime: json['defaultStartTime'] as String?,
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RoutineToJson(Routine instance) => <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'activityType': instance.activityType,
      if (instance.intervalMinutes != null)
        'intervalMinutes': instance.intervalMinutes,
      if (instance.defaultStartTime != null)
        'defaultStartTime': instance.defaultStartTime,
      'active': instance.active,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
