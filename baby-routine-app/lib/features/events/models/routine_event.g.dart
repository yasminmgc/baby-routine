// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_event.dart';

// ===========================================================================
// RoutineEvent
// ===========================================================================

RoutineEvent _$RoutineEventFromJson(Map<String, dynamic> json) => RoutineEvent(
      id: json['id'] as String,
      eventType: json['eventType'] as String,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      occurredAt: json['occurredAt'] != null
          ? DateTime.parse(json['occurredAt'] as String)
          : null,
      status: json['status'] as String,
      details: json['details'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$RoutineEventToJson(RoutineEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventType': instance.eventType,
      if (instance.scheduledAt != null)
        'scheduledAt': instance.scheduledAt!.toIso8601String(),
      if (instance.occurredAt != null)
        'occurredAt': instance.occurredAt!.toIso8601String(),
      'status': instance.status,
      if (instance.details != null) 'details': instance.details,
      if (instance.notes != null) 'notes': instance.notes,
    };
