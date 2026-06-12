import 'package:json_annotation/json_annotation.dart';

part 'health_record.g.dart';

@JsonSerializable()
class HealthRecord {
  final String id;
  final String babyId;
  final String userId;
  final String recordType;
  final DateTime? occurredAt;
  final String title;
  final String? description;
  final DateTime createdAt;

  const HealthRecord({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.recordType,
    this.occurredAt,
    required this.title,
    this.description,
    required this.createdAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) =>
      _$HealthRecordFromJson(json);

  Map<String, dynamic> toJson() => _$HealthRecordToJson(this);

  @override
  String toString() =>
      'HealthRecord(id: $id, recordType: $recordType, title: $title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          recordType == other.recordType &&
          title == other.title;

  @override
  int get hashCode => Object.hash(id, recordType, title);
}
