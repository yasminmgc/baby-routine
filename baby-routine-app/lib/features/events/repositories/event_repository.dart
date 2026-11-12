import '../models/routine_event.dart';

abstract class EventRepository {
  Future<RoutineEvent> create({
    required String babyId,
    required String eventType,
    required DateTime occurredAt,
    DateTime? scheduledAt,
    String status = 'completed',
    Map<String, dynamic>? details,
    String? notes,
  });

  Future<List<RoutineEvent>> list(
    String babyId, {
    String? type,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  });

  Future<RoutineEvent> getById(String babyId, String eventId);

  Future<RoutineEvent> update(
    String babyId,
    String eventId, {
    DateTime? occurredAt,
    String? status,
    Map<String, dynamic>? details,
    String? notes,
  });

  Future<void> delete(String babyId, String eventId);
}
