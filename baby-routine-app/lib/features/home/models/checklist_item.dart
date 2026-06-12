import 'package:json_annotation/json_annotation.dart';

part 'checklist_item.g.dart';

@JsonSerializable()
class ChecklistItem {
  final String type; // 'routine' or 'event'
  final String? routineId;
  final String activityType;
  final String? scheduledTime;
  final String? eventType;
  final String status; // 'completed', 'pending', 'missed'
  final String? eventId;
  final String? occurredAt;
  final String? notes;

  const ChecklistItem({
    required this.type,
    this.routineId,
    required this.activityType,
    this.scheduledTime,
    this.eventType,
    required this.status,
    this.eventId,
    this.occurredAt,
    this.notes,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$ChecklistItemFromJson(json);

  Map<String, dynamic> toJson() => _$ChecklistItemToJson(this);

  ChecklistItem copyWith({
    String? type,
    String? routineId,
    String? activityType,
    String? scheduledTime,
    String? eventType,
    String? status,
    String? eventId,
    String? occurredAt,
    String? notes,
  }) {
    return ChecklistItem(
      type: type ?? this.type,
      routineId: routineId ?? this.routineId,
      activityType: activityType ?? this.activityType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      occurredAt: occurredAt ?? this.occurredAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'ChecklistItem(type: $type, activityType: $activityType, '
      'scheduledTime: $scheduledTime, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistItem &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          routineId == other.routineId &&
          activityType == other.activityType &&
          scheduledTime == other.scheduledTime &&
          eventType == other.eventType &&
          status == other.status &&
          eventId == other.eventId &&
          occurredAt == other.occurredAt &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
        type,
        routineId,
        activityType,
        scheduledTime,
        eventType,
        status,
        eventId,
        occurredAt,
        notes,
      );
}

@JsonSerializable()
class ChecklistResponse {
  final String date;
  final List<ChecklistItem> items;

  const ChecklistResponse({
    required this.date,
    required this.items,
  });

  factory ChecklistResponse.fromJson(Map<String, dynamic> json) =>
      _$ChecklistResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChecklistResponseToJson(this);

  @override
  String toString() =>
      'ChecklistResponse(date: $date, itemsCount: ${items.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistResponse &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          _listsEqual(items, other.items);

  @override
  int get hashCode => Object.hash(date, Object.hashAll(items));
}

bool _listsEqual<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
