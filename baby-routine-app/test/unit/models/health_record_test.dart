import 'package:flutter_test/flutter_test.dart';
import 'package:baby_routine_app/features/health/models/health_record.dart';

void main() {
  group('HealthRecord', () {
    final json = {
      'id': 'hr-001',
      'babyId': 'baby-001',
      'userId': 'user-001',
      'recordType': 'appointment',
      'title': 'Consulta pediatra',
      'description': 'Dr. Silva — Rotina',
      'occurredAt': '2026-06-10T10:00:00.000',
      'createdAt': '2026-06-10T10:00:00.000',
    };

    final minimalJson = {
      'id': 'hr-002',
      'babyId': 'baby-002',
      'userId': 'user-002',
      'recordType': 'exam',
      'title': 'Hemograma',
      'occurredAt': null,
      'createdAt': '2026-06-05T08:00:00.000',
    };

    test('fromJson parses all fields', () {
      final record = HealthRecord.fromJson(json);

      expect(record.id, 'hr-001');
      expect(record.babyId, 'baby-001');
      expect(record.userId, 'user-001');
      expect(record.recordType, 'appointment');
      expect(record.title, 'Consulta pediatra');
      expect(record.description, 'Dr. Silva — Rotina');
      expect(record.occurredAt, DateTime.parse('2026-06-10T10:00:00.000'));
      expect(record.createdAt, DateTime.parse('2026-06-10T10:00:00.000'));
    });

    test('fromJson handles null occurredAt', () {
      final record = HealthRecord.fromJson(minimalJson);

      expect(record.id, 'hr-002');
      expect(record.occurredAt, isNull);
      expect(record.description, isNull);
    });

    test('toJson produces correct map', () {
      final record = HealthRecord.fromJson(json);
      final output = record.toJson();

      expect(output['id'], 'hr-001');
      expect(output['recordType'], 'appointment');
      expect(output['title'], 'Consulta pediatra');
      expect(output['description'], 'Dr. Silva — Rotina');
      expect(output['occurredAt'], '2026-06-10T10:00:00.000');
    });

    test('toJson omits null description and occurredAt', () {
      final record = HealthRecord.fromJson(minimalJson);
      final output = record.toJson();

      expect(output.containsKey('description'), isFalse);
      expect(output.containsKey('occurredAt'), isFalse);
    });

    test('supports equality', () {
      final a = HealthRecord.fromJson(json);
      final b = HealthRecord.fromJson(json);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString contains key fields', () {
      final record = HealthRecord.fromJson(json);
      final str = record.toString();

      expect(str, contains('Consulta pediatra'));
      expect(str, contains('appointment'));
    });

    test('different records are not equal', () {
      final a = HealthRecord.fromJson(json);
      final b = HealthRecord.fromJson(minimalJson);

      expect(a, isNot(equals(b)));
    });
  });
}
