import 'package:flutter_test/flutter_test.dart';
import 'package:baby_routine_app/features/routines/models/routine.dart';

void main() {
  group('Routine', () {
    final json = {
      'id': 'r1',
      'babyId': 'baby-001',
      'activityType': 'Sono',
      'intervalMinutes': 120,
      'defaultStartTime': '20:00',
      'active': true,
      'createdAt': '2026-06-10T10:00:00.000',
      'updatedAt': '2026-06-10T10:00:00.000',
    };

    final minimalJson = {
      'id': 'r2',
      'babyId': 'baby-001',
      'activityType': 'Alimentação',
      'active': false,
      'createdAt': '2026-06-10T10:00:00.000',
      'updatedAt': '2026-06-10T10:00:00.000',
    };

    test('fromJson parses all fields', () {
      final routine = Routine.fromJson(json);

      expect(routine.id, 'r1');
      expect(routine.babyId, 'baby-001');
      expect(routine.activityType, 'Sono');
      expect(routine.intervalMinutes, 120);
      expect(routine.defaultStartTime, '20:00');
      expect(routine.active, isTrue);
      expect(routine.createdAt, DateTime.parse('2026-06-10T10:00:00.000'));
      expect(routine.updatedAt, DateTime.parse('2026-06-10T10:00:00.000'));
    });

    test('fromJson handles null optional fields', () {
      final routine = Routine.fromJson(minimalJson);

      expect(routine.intervalMinutes, isNull);
      expect(routine.defaultStartTime, isNull);
      expect(routine.active, isFalse);
    });

    test('toJson produces correct map', () {
      final routine = Routine.fromJson(json);
      final output = routine.toJson();

      expect(output['id'], 'r1');
      expect(output['activityType'], 'Sono');
      expect(output['intervalMinutes'], 120);
      expect(output['defaultStartTime'], '20:00');
      expect(output['active'], true);
    });

    test('toJson omits null optional fields', () {
      final routine = Routine.fromJson(minimalJson);
      final output = routine.toJson();

      expect(output.containsKey('intervalMinutes'), isFalse);
      expect(output.containsKey('defaultStartTime'), isFalse);
    });

    test('copyWith creates new instance with updated fields', () {
      final routine = Routine.fromJson(json);
      final updated = routine.copyWith(activityType: 'Banho', active: false);

      expect(updated.activityType, 'Banho');
      expect(updated.active, isFalse);
      expect(updated.id, routine.id);
      expect(updated.babyId, routine.babyId);
    });

    test('copyWith preserves existing values when no args', () {
      final routine = Routine.fromJson(json);
      final copy = routine.copyWith();

      expect(copy, equals(routine));
    });

    test('supports equality', () {
      final a = Routine.fromJson(json);
      final b = Routine.fromJson(json);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different routines are not equal', () {
      final a = Routine.fromJson(json);
      final b = Routine.fromJson(minimalJson);

      expect(a, isNot(equals(b)));
    });

    test('toString contains key fields', () {
      final routine = Routine.fromJson(json);
      final str = routine.toString();

      expect(str, contains('r1'));
      expect(str, contains('Sono'));
      expect(str, contains('active: true'));
    });
  });
}
