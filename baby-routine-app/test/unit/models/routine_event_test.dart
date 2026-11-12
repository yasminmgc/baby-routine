import 'package:flutter_test/flutter_test.dart';
import 'package:baby_routine_app/features/events/models/routine_event.dart';

void main() {
  group('RoutineEvent model', () {
    test('should create RoutineEvent from JSON with all fields', () {
      final json = {
        'id': 'evt-001',
        'eventType': 'feeding',
        'scheduledAt': '2026-06-12T06:00:00.000Z',
        'occurredAt': '2026-06-12T06:15:00.000Z',
        'status': 'completed',
        'details': {
          'feedingType': 'bottle',
          'amountMl': 120,
          'durationMin': 15,
        },
        'notes': 'Drank well',
      };

      final event = RoutineEvent.fromJson(json);

      expect(event.id, 'evt-001');
      expect(event.eventType, 'feeding');
      expect(event.scheduledAt, DateTime.parse('2026-06-12T06:00:00.000Z'));
      expect(event.occurredAt, DateTime.parse('2026-06-12T06:15:00.000Z'));
      expect(event.status, 'completed');
      expect(event.details, isNotNull);
      expect(event.details!['feedingType'], 'bottle');
      expect(event.details!['amountMl'], 120);
      expect(event.details!['durationMin'], 15);
      expect(event.notes, 'Drank well');
    });

    test('should create RoutineEvent with null optional fields', () {
      final json = {
        'id': 'evt-002',
        'eventType': 'sleep',
        'status': 'completed',
      };

      final event = RoutineEvent.fromJson(json);

      expect(event.scheduledAt, isNull);
      expect(event.occurredAt, isNull);
      expect(event.details, isNull);
      expect(event.notes, isNull);
    });

    test('should serialize RoutineEvent to JSON', () {
      final event = RoutineEvent(
        id: 'evt-003',
        eventType: 'diaper',
        occurredAt: DateTime.parse('2026-06-12T08:30:00.000Z'),
        status: 'completed',
        details: {'type': 'pee', 'color': 'yellow'},
        notes: 'Normal',
      );

      final json = event.toJson();

      expect(json['id'], 'evt-003');
      expect(json['eventType'], 'diaper');
      expect(json['occurredAt'], '2026-06-12T08:30:00.000');
      expect(json['status'], 'completed');
      expect(json['details'], {'type': 'pee', 'color': 'yellow'});
      expect(json['notes'], 'Normal');
    });

    test('should omit null fields in JSON', () {
      final event = RoutineEvent(
        id: 'evt-004',
        eventType: 'feeding',
        status: 'completed',
      );

      final json = event.toJson();

      expect(json.containsKey('scheduledAt'), isFalse);
      expect(json.containsKey('occurredAt'), isFalse);
      expect(json.containsKey('details'), isFalse);
      expect(json.containsKey('notes'), isFalse);
    });

    test('should support copyWith', () {
      final event = RoutineEvent(
        id: 'evt-005',
        eventType: 'feeding',
        occurredAt: DateTime.parse('2025-01-01T00:00:00Z'),
        status: 'missed',
      );

      final updated = event.copyWith(
        occurredAt: DateTime.parse('2025-01-01T10:00:00Z'),
        status: 'completed',
        notes: 'Updated notes',
      );

      expect(updated.id, 'evt-005');
      expect(updated.eventType, 'feeding');
      expect(updated.occurredAt, DateTime.parse('2025-01-01T10:00:00Z'));
      expect(updated.status, 'completed');
      expect(updated.notes, 'Updated notes');
    });

    test('should have value equality', () {
      final event1 = RoutineEvent(
        id: '1',
        eventType: 'sleep',
        occurredAt: DateTime.parse('2025-01-01T00:00:00Z'),
        status: 'completed',
        details: {'durationMin': 90},
      );

      final event2 = RoutineEvent(
        id: '1',
        eventType: 'sleep',
        occurredAt: DateTime.parse('2025-01-01T00:00:00Z'),
        status: 'completed',
        details: {'durationMin': 90},
      );

      expect(event1, equals(event2));
    });

    test('should not be equal with different details', () {
      final event1 = RoutineEvent(
        id: '1',
        eventType: 'sleep',
        status: 'completed',
        details: {'durationMin': 90},
      );
      final event2 = RoutineEvent(
        id: '1',
        eventType: 'sleep',
        status: 'completed',
        details: {'durationMin': 60},
      );

      expect(event1, isNot(equals(event2)));
    });

    test('should handle hashCode consistently', () {
      final event1 = RoutineEvent(
        id: '1',
        eventType: 'sleep',
        status: 'completed',
      );
      final event2 = RoutineEvent(
        id: '1',
        eventType: 'sleep',
        status: 'completed',
      );

      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('should stringify event correctly', () {
      final event = RoutineEvent(
        id: 'abc-123',
        eventType: 'feeding',
        occurredAt: DateTime.parse('2025-06-12T12:00:00Z'),
        status: 'completed',
      );

      expect(event.toString(), contains('abc-123'));
      expect(event.toString(), contains('feeding'));
      expect(event.toString(), contains('completed'));
    });

    test('should handle sleep event details', () {
      final json = {
        'id': 'evt-010',
        'eventType': 'sleep',
        'occurredAt': '2026-06-12T20:00:00.000Z',
        'status': 'completed',
        'details': {
          'startTime': '2026-06-12T20:00:00.000Z',
          'endTime': '2026-06-12T21:30:00.000Z',
          'durationMin': 90,
          'location': 'crib',
        },
      };

      final event = RoutineEvent.fromJson(json);

      expect(event.details!['durationMin'], 90);
      expect(event.details!['location'], 'crib');
    });

    test('should handle diaper event details', () {
      final json = {
        'id': 'evt-011',
        'eventType': 'diaper',
        'status': 'completed',
        'details': {
          'type': 'both',
          'color': 'yellow',
          'consistency': 'normal',
          'rash': false,
        },
      };

      final event = RoutineEvent.fromJson(json);

      expect(event.details!['type'], 'both');
      expect(event.details!['color'], 'yellow');
      expect(event.details!['consistency'], 'normal');
      expect(event.details!['rash'], false);
    });

    test('should handle eventType values', () {
      for (final type in [
        'feeding',
        'sleep',
        'diaper',
        'bath',
        'appointment',
        'vaccination',
        'medication',
      ]) {
        final event = RoutineEvent(
          id: '1',
          eventType: type,
          status: 'completed',
        );
        expect(event.eventType, type);
      }
    });

    test('should handle all status values', () {
      for (final status in ['completed', 'missed', 'cancelled']) {
        final event = RoutineEvent(
          id: '1',
          eventType: 'feeding',
          status: status,
        );
        expect(event.status, status);
      }
    });
  });
}
