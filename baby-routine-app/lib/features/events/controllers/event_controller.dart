import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/selected_baby_provider.dart';
import '../models/routine_event.dart';
import '../repositories/event_repository.dart';
import '../repositories/event_repository_impl.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return EventRepositoryImpl(dioClient);
});

final eventControllerProvider =
    AsyncNotifierProvider<EventController, void>(EventController.new);

class EventController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  EventRepository get _repository => ref.read(eventRepositoryProvider);

  String get _babyId {
    final baby = ref.read(selectedBabyProvider);
    if (baby == null) {
      throw Exception('Nenhum bebê selecionado');
    }
    return baby.id;
  }

  Future<RoutineEvent> createEvent({
    required String eventType,
    required DateTime occurredAt,
    DateTime? scheduledAt,
    String status = 'completed',
    Map<String, dynamic>? details,
    String? notes,
  }) async {
    state = const AsyncLoading();
    late RoutineEvent event;
    state = await AsyncValue.guard(() async {
      event = await _repository.create(
        babyId: _babyId,
        eventType: eventType,
        occurredAt: occurredAt,
        scheduledAt: scheduledAt,
        status: status,
        details: details,
        notes: notes,
      );
    });
    return event;
  }

  Future<List<RoutineEvent>> listEvents({
    String? type,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  }) async {
    return _repository.list(
      _babyId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );
  }

  Future<RoutineEvent> updateEvent(
    String eventId, {
    DateTime? occurredAt,
    String? status,
    Map<String, dynamic>? details,
    String? notes,
  }) async {
    state = const AsyncLoading();
    late RoutineEvent event;
    state = await AsyncValue.guard(() async {
      event = await _repository.update(
        _babyId,
        eventId,
        occurredAt: occurredAt,
        status: status,
        details: details,
        notes: notes,
      );
    });
    return event;
  }

  Future<void> deleteEvent(String eventId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.delete(_babyId, eventId);
    });
  }
}
