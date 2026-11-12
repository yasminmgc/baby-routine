// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record.dart';

HealthRecord _$HealthRecordFromJson(Map<String, dynamic> json) => HealthRecord(
      id: json['id'] as String,
      babyId: json['babyId'] as String,
      userId: json['userId'] as String,
      recordType: json['recordType'] as String,
      occurredAt: json['occurredAt'] != null
          ? DateTime.parse(json['occurredAt'] as String)
          : null,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$HealthRecordToJson(HealthRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'userId': instance.userId,
      'recordType': instance.recordType,
      if (instance.occurredAt != null)
        'occurredAt': instance.occurredAt!.toIso8601String(),
      'title': instance.title,
      if (instance.description != null) 'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
    };
