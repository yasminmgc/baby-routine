import 'package:flutter_test/flutter_test.dart';
import 'package:baby_routine_app/features/reports/models/report_data.dart';

void main() {
  group('SleepReportItem', () {
    final json = {
      'date': '2026-06-10',
      'totalDurationMin': 480.0,
      'eventsCount': 2,
    };

    test('fromJson parses correctly', () {
      final item = SleepReportItem.fromJson(json);
      expect(item.date, '2026-06-10');
      expect(item.totalDurationMin, 480.0);
      expect(item.eventsCount, 2);
    });

    test('toJson produces correct map', () {
      final item = SleepReportItem.fromJson(json);
      final output = item.toJson();
      expect(output['date'], '2026-06-10');
      expect(output['totalDurationMin'], 480.0);
      expect(output['eventsCount'], 2);
    });
  });

  group('FeedingReportItem', () {
    final json = {
      'date': '2026-06-10',
      'bottle': 4,
      'breast': 2,
      'solids': 1,
    };

    test('fromJson parses correctly', () {
      final item = FeedingReportItem.fromJson(json);
      expect(item.date, '2026-06-10');
      expect(item.bottle, 4);
      expect(item.breast, 2);
      expect(item.solids, 1);
    });

    test('toJson produces correct map', () {
      final item = FeedingReportItem.fromJson(json);
      final output = item.toJson();
      expect(output['date'], '2026-06-10');
      expect(output['bottle'], 4);
      expect(output['breast'], 2);
      expect(output['solids'], 1);
    });
  });

  group('DiapersReportItem', () {
    final json = {
      'date': '2026-06-10',
      'pee': 5,
      'poop': 2,
      'both': 1,
    };

    test('fromJson parses correctly', () {
      final item = DiapersReportItem.fromJson(json);
      expect(item.date, '2026-06-10');
      expect(item.pee, 5);
      expect(item.poop, 2);
      expect(item.both, 1);
    });

    test('toJson produces correct map', () {
      final item = DiapersReportItem.fromJson(json);
      final output = item.toJson();
      expect(output['date'], '2026-06-10');
      expect(output['pee'], 5);
      expect(output['poop'], 2);
      expect(output['both'], 1);
    });
  });

  group('GrowthReportItem', () {
    final fullJson = {
      'id': 'g1',
      'measuredAt': '2026-06-10T10:00:00.000',
      'weightKg': 4.5,
      'heightCm': 55.0,
      'headCircumferenceCm': 38.0,
    };

    final partialJson = {
      'id': 'g2',
      'measuredAt': '2026-06-11T10:00:00.000',
      'weightKg': 4.7,
      'heightCm': null,
      'headCircumferenceCm': null,
    };

    test('fromJson parses all fields', () {
      final item = GrowthReportItem.fromJson(fullJson);
      expect(item.id, 'g1');
      expect(item.measuredAt, DateTime.parse('2026-06-10T10:00:00.000'));
      expect(item.weightKg, 4.5);
      expect(item.heightCm, 55.0);
      expect(item.headCircumferenceCm, 38.0);
    });

    test('fromJson handles null optional fields', () {
      final item = GrowthReportItem.fromJson(partialJson);
      expect(item.weightKg, 4.7);
      expect(item.heightCm, isNull);
      expect(item.headCircumferenceCm, isNull);
    });

    test('toJson omits null fields', () {
      final item = GrowthReportItem.fromJson(partialJson);
      final output = item.toJson();
      expect(output.containsKey('heightCm'), isFalse);
      expect(output.containsKey('headCircumferenceCm'), isFalse);
    });

    test('toJson includes all non-null fields', () {
      final item = GrowthReportItem.fromJson(fullJson);
      final output = item.toJson();
      expect(output['id'], 'g1');
      expect(output['weightKg'], 4.5);
      expect(output['heightCm'], 55.0);
      expect(output['headCircumferenceCm'], 38.0);
    });
  });

  group('MedicationReportItem', () {
    final fullJson = {
      'id': 'm1',
      'occurredAt': '2026-06-10T14:00:00.000',
      'medicationName': 'Dipirona',
      'dose': '5ml',
      'reason': 'Febre',
      'notes': 'Após banho',
    };

    final minimalJson = {
      'id': 'm2',
      'occurredAt': null,
      'medicationName': 'Paracetamol',
      'dose': '3ml',
      'reason': null,
      'notes': null,
    };

    test('fromJson parses all fields', () {
      final item = MedicationReportItem.fromJson(fullJson);
      expect(item.id, 'm1');
      expect(item.occurredAt, DateTime.parse('2026-06-10T14:00:00.000'));
      expect(item.medicationName, 'Dipirona');
      expect(item.dose, '5ml');
      expect(item.reason, 'Febre');
      expect(item.notes, 'Após banho');
    });

    test('fromJson handles null optional fields', () {
      final item = MedicationReportItem.fromJson(minimalJson);
      expect(item.medicationName, 'Paracetamol');
      expect(item.reason, isNull);
      expect(item.notes, isNull);
      expect(item.occurredAt, isNull);
    });

    test('toJson omits null fields', () {
      final item = MedicationReportItem.fromJson(minimalJson);
      final output = item.toJson();
      expect(output.containsKey('reason'), isFalse);
      expect(output.containsKey('notes'), isFalse);
      expect(output.containsKey('occurredAt'), isFalse);
    });
  });
}
