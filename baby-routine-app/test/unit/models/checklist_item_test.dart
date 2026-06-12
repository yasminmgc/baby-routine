import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/home/models/checklist_item.dart';

void main() {
  group('ChecklistItem', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'type': 'routine',
        'routineId': 'r1',
        'activityType': 'feeding',
        'scheduledTime': '08:00',
        'eventType': null,
        'status': 'pending',
        'eventId': null,
        'occurredAt': null,
        'notes': null,
      };

      final item = ChecklistItem.fromJson(json);

      expect(item.type, 'routine');
      expect(item.routineId, 'r1');
      expect(item.activityType, 'feeding');
      expect(item.scheduledTime, '08:00');
      expect(item.eventType, isNull);
      expect(item.status, 'pending');
      expect(item.eventId, isNull);
    });

    test('fromJson handles event type items', () {
      final json = {
        'type': 'event',
        'routineId': null,
        'activityType': 'bath',
        'scheduledTime': null,
        'eventType': 'bath',
        'status': 'completed',
        'eventId': 'ev1',
        'occurredAt': '2026-06-12T10:30:00.000Z',
        'notes': 'Água morna',
      };

      final item = ChecklistItem.fromJson(json);

      expect(item.type, 'event');
      expect(item.eventType, 'bath');
      expect(item.status, 'completed');
      expect(item.eventId, 'ev1');
      expect(item.occurredAt, '2026-06-12T10:30:00.000Z');
      expect(item.notes, 'Água morna');
    });

    test('fromJson handles missed status', () {
      final json = {
        'type': 'routine',
        'routineId': 'r2',
        'activityType': 'medication',
        'scheduledTime': '14:00',
        'eventType': null,
        'status': 'missed',
        'eventId': null,
        'occurredAt': null,
        'notes': null,
      };

      final item = ChecklistItem.fromJson(json);

      expect(item.status, 'missed');
      expect(item.activityType, 'medication');
    });

    test('toJson serializes correctly', () {
      final item = const ChecklistItem(
        type: 'routine',
        routineId: 'r1',
        activityType: 'sleep',
        scheduledTime: '20:00',
        status: 'completed',
        eventId: 'ev1',
      );

      final json = item.toJson();

      expect(json['type'], 'routine');
      expect(json['routineId'], 'r1');
      expect(json['activityType'], 'sleep');
      expect(json['scheduledTime'], '20:00');
      expect(json['status'], 'completed');
      expect(json['eventId'], 'ev1');
    });

    test('toJson omits null fields', () {
      final item = const ChecklistItem(
        type: 'event',
        activityType: 'diaper',
        status: 'completed',
      );

      final json = item.toJson();

      expect(json.containsKey('routineId'), false);
      expect(json.containsKey('scheduledTime'), false);
      expect(json.containsKey('eventType'), false);
    });

    test('copyWith creates copy with changed fields', () {
      final item = const ChecklistItem(
        type: 'routine',
        routineId: 'r1',
        activityType: 'feeding',
        scheduledTime: '08:00',
        status: 'pending',
      );

      final updated = item.copyWith(
        status: 'completed',
        eventId: 'ev1',
      );

      expect(updated.type, 'routine');
      expect(updated.routineId, 'r1');
      expect(updated.activityType, 'feeding');
      expect(updated.scheduledTime, '08:00');
      expect(updated.status, 'completed');
      expect(updated.eventId, 'ev1');
    });

    test('equality works correctly', () {
      final a = const ChecklistItem(
        type: 'routine',
        activityType: 'feeding',
        scheduledTime: '08:00',
        status: 'pending',
        routineId: 'r1',
      );

      final b = const ChecklistItem(
        type: 'routine',
        activityType: 'feeding',
        scheduledTime: '08:00',
        status: 'pending',
        routineId: 'r1',
      );

      final c = const ChecklistItem(
        type: 'routine',
        activityType: 'feeding',
        scheduledTime: '08:00',
        status: 'completed',
        routineId: 'r1',
      );

      expect(a, b);
      expect(a, isNot(c));
    });

    test('toString contains key fields', () {
      final item = const ChecklistItem(
        type: 'routine',
        activityType: 'sleep',
        scheduledTime: '20:00',
        status: 'pending',
      );

      final str = item.toString();
      expect(str, contains('routine'));
      expect(str, contains('sleep'));
      expect(str, contains('20:00'));
      expect(str, contains('pending'));
    });

    test('hashCode is consistent with equality', () {
      final a = const ChecklistItem(
        type: 'routine',
        activityType: 'feeding',
        status: 'pending',
      );

      final b = const ChecklistItem(
        type: 'routine',
        activityType: 'feeding',
        status: 'pending',
      );

      expect(a.hashCode, b.hashCode);
    });

    test('all activity types are supported', () {
      const types = [
        'feeding',
        'sleep',
        'diaper',
        'bath',
        'vaccination',
        'appointment',
        'medication',
      ];

      for (final type in types) {
        final item = ChecklistItem.fromJson({
          'type': 'routine',
          'activityType': type,
          'status': 'pending',
        });
        expect(item.activityType, type);
      }
    });
  });

  group('ChecklistResponse', () {
    test('fromJson parses date and items correctly', () {
      final json = {
        'date': '2026-06-12',
        'items': [
          {
            'type': 'routine',
            'routineId': 'r1',
            'activityType': 'feeding',
            'scheduledTime': '08:00',
            'status': 'completed',
            'eventId': 'ev1',
          },
          {
            'type': 'routine',
            'routineId': 'r2',
            'activityType': 'sleep',
            'scheduledTime': '20:00',
            'status': 'pending',
          },
        ],
      };

      final response = ChecklistResponse.fromJson(json);

      expect(response.date, '2026-06-12');
      expect(response.items, hasLength(2));
      expect(response.items[0].activityType, 'feeding');
      expect(response.items[0].status, 'completed');
      expect(response.items[1].activityType, 'sleep');
      expect(response.items[1].status, 'pending');
    });

    test('fromJson handles empty items list', () {
      final json = {
        'date': '2026-06-12',
        'items': <Map<String, dynamic>>[],
      };

      final response = ChecklistResponse.fromJson(json);

      expect(response.date, '2026-06-12');
      expect(response.items, isEmpty);
    });

    test('toJson serializes with items', () {
      final response = ChecklistResponse(
        date: '2026-06-12',
        items: const [
          ChecklistItem(
            type: 'routine',
            activityType: 'feeding',
            status: 'completed',
            routineId: 'r1',
            scheduledTime: '08:00',
          ),
        ],
      );

      final json = response.toJson();

      expect(json['date'], '2026-06-12');
      expect(json['items'], isA<List>());
      expect((json['items'] as List).length, 1);
    });

    test('equality works correctly', () {
      final a = ChecklistResponse(
        date: '2026-06-12',
        items: const [
          ChecklistItem(
            type: 'routine',
            activityType: 'feeding',
            status: 'completed',
            routineId: 'r1',
          ),
        ],
      );

      final b = ChecklistResponse(
        date: '2026-06-12',
        items: const [
          ChecklistItem(
            type: 'routine',
            activityType: 'feeding',
            status: 'completed',
            routineId: 'r1',
          ),
        ],
      );

      final c = ChecklistResponse(
        date: '2026-06-13',
        items: const [
          ChecklistItem(
            type: 'routine',
            activityType: 'feeding',
            status: 'completed',
            routineId: 'r1',
          ),
        ],
      );

      expect(a, b);
      expect(a, isNot(c));
    });

    test('hashCode is consistent', () {
      final a = ChecklistResponse(
        date: '2026-06-12',
        items: const [],
      );
      final b = ChecklistResponse(
        date: '2026-06-12',
        items: const [],
      );

      expect(a.hashCode, b.hashCode);
    });

    test('toString contains date and item count', () {
      final response = ChecklistResponse(
        date: '2026-06-12',
        items: const [
          ChecklistItem(
            type: 'routine',
            activityType: 'feeding',
            status: 'pending',
          ),
          ChecklistItem(
            type: 'routine',
            activityType: 'sleep',
            status: 'pending',
          ),
        ],
      );

      final str = response.toString();
      expect(str, contains('2026-06-12'));
      expect(str, contains('2'));
    });
  });
}
