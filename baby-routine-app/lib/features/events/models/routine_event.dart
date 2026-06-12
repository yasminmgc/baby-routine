import 'package:json_annotation/json_annotation.dart';

part 'routine_event.g.dart';

@JsonSerializable()
class RoutineEvent {
  final String id;
  final String eventType;
  final DateTime? scheduledAt;
  final DateTime? occurredAt;
  final String status;
  final Map<String, dynamic>? details;
  final String? notes;

  const RoutineEvent({
    required this.id,
    required this.eventType,
    this.scheduledAt,
    this.occurredAt,
    required this.status,
    this.details,
    this.notes,
  });

  factory RoutineEvent.fromJson(Map<String, dynamic> json) =>
      _$RoutineEventFromJson(json);

  Map<String, dynamic> toJson() => _$RoutineEventToJson(this);

  RoutineEvent copyWith({
    String? id,
    String? eventType,
    DateTime? scheduledAt,
    DateTime? occurredAt,
    String? status,
    Map<String, dynamic>? details,
    String? notes,
  }) {
    return RoutineEvent(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      occurredAt: occurredAt ?? this.occurredAt,
      status: status ?? this.status,
      details: details ?? this.details,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'RoutineEvent(id: $id, eventType: $eventType, '
      'occurredAt: $occurredAt, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          eventType == other.eventType &&
          scheduledAt == other.scheduledAt &&
          occurredAt == other.occurredAt &&
          status == other.status &&
          _mapsEqual(details, other.details) &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
        id,
        eventType,
        scheduledAt,
        occurredAt,
        status,
        notes,
      );
}

bool _mapsEqual(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}
