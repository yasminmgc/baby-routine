import '../../../core/network/dio_client.dart';
import '../models/routine_event.dart';
import 'event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final DioClient _dioClient;

  EventRepositoryImpl(this._dioClient);

  @override
  Future<RoutineEvent> create({
    required String babyId,
    required String eventType,
    required DateTime occurredAt,
    DateTime? scheduledAt,
    String status = 'completed',
    Map<String, dynamic>? details,
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'eventType': eventType,
      'occurredAt': occurredAt.toIso8601String(),
      'status': status,
    };
    if (scheduledAt != null) {
      data['scheduledAt'] = scheduledAt.toIso8601String();
    }
    if (details != null && details.isNotEmpty) {
      data['details'] = details;
    }
    if (notes != null && notes.isNotEmpty) {
      data['notes'] = notes;
    }

    final response = await _dioClient.post(
      '/babies/$babyId/events',
      data: data,
    );

    return RoutineEvent.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<RoutineEvent>> list(
    String babyId, {
    String? type,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  }) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;

    final response = await _dioClient.get(
      '/babies/$babyId/events',
      params: params.isNotEmpty ? params : null,
    );

    final list = response.data as List<dynamic>;
    return list
        .map((item) => RoutineEvent.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RoutineEvent> getById(String babyId, String eventId) async {
    final response = await _dioClient.get('/babies/$babyId/events/$eventId');
    return RoutineEvent.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<RoutineEvent> update(
    String babyId,
    String eventId, {
    DateTime? occurredAt,
    String? status,
    Map<String, dynamic>? details,
    String? notes,
  }) async {
    final data = <String, dynamic>{};
    if (occurredAt != null) data['occurredAt'] = occurredAt.toIso8601String();
    if (status != null) data['status'] = status;
    if (details != null && details.isNotEmpty) data['details'] = details;
    if (notes != null) data['notes'] = notes;

    final response = await _dioClient.put(
      '/babies/$babyId/events/$eventId',
      data: data,
    );

    return RoutineEvent.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String babyId, String eventId) async {
    await _dioClient.delete('/babies/$babyId/events/$eventId');
  }
}
