// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_item.dart';

// ===========================================================================
// ChecklistItem
// ===========================================================================

ChecklistItem _$ChecklistItemFromJson(Map<String, dynamic> json) =>
    ChecklistItem(
      type: json['type'] as String,
      routineId: json['routineId'] as String?,
      activityType: json['activityType'] as String,
      scheduledTime: json['scheduledTime'] as String?,
      eventType: json['eventType'] as String?,
      status: json['status'] as String,
      eventId: json['eventId'] as String?,
      occurredAt: json['occurredAt'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ChecklistItemToJson(ChecklistItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      if (instance.routineId != null) 'routineId': instance.routineId,
      'activityType': instance.activityType,
      if (instance.scheduledTime != null)
        'scheduledTime': instance.scheduledTime,
      if (instance.eventType != null) 'eventType': instance.eventType,
      'status': instance.status,
      if (instance.eventId != null) 'eventId': instance.eventId,
      if (instance.occurredAt != null) 'occurredAt': instance.occurredAt,
      if (instance.notes != null) 'notes': instance.notes,
    };

// ===========================================================================
// ChecklistResponse
// ===========================================================================

ChecklistResponse _$ChecklistResponseFromJson(Map<String, dynamic> json) =>
    ChecklistResponse(
      date: json['date'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChecklistResponseToJson(ChecklistResponse instance) =>
    <String, dynamic>{
      'date': instance.date,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
