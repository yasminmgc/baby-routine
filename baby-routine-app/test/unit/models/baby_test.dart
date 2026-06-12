import 'package:flutter_test/flutter_test.dart';
import 'package:baby_routine_app/features/babies/models/baby.dart';

void main() {
  group('Baby model', () {
    test('should create Baby instance from JSON', () {
      final json = {
        'id': 'baby-001',
        'name': 'Lucas Silva',
        'birthDate': '2025-01-15',
        'gender': 'male',
        'initialWeightKg': 3.5,
        'initialHeightCm': 50.0,
        'allergies': null,
        'currentUserRole': 'owner',
      };

      final baby = Baby.fromJson(json);

      expect(baby.id, 'baby-001');
      expect(baby.name, 'Lucas Silva');
      expect(baby.birthDate, DateTime.parse('2025-01-15'));
      expect(baby.gender, 'male');
      expect(baby.initialWeightKg, 3.5);
      expect(baby.initialHeightCm, 50.0);
      expect(baby.allergies, isNull);
      expect(baby.currentUserRole, 'owner');
    });

    test('should handle optional fields as null', () {
      final json = {
        'id': 'baby-002',
        'name': 'Ana Silva',
        'birthDate': '2025-03-20',
        'currentUserRole': 'caregiver',
      };

      final baby = Baby.fromJson(json);

      expect(baby.gender, isNull);
      expect(baby.initialWeightKg, isNull);
      expect(baby.initialHeightCm, isNull);
      expect(baby.allergies, isNull);
      expect(baby.currentUserRole, 'caregiver');
    });

    test('should serialize Baby to JSON', () {
      final baby = Baby(
        id: 'baby-003',
        name: 'Pedro Costa',
        birthDate: DateTime.parse('2024-12-01'),
        gender: 'male',
        initialWeightKg: 4.2,
        initialHeightCm: 52.0,
        allergies: 'lactose',
        currentUserRole: 'owner',
      );

      final json = baby.toJson();

      expect(json['id'], 'baby-003');
      expect(json['name'], 'Pedro Costa');
      expect(json['birthDate'], '2024-12-01');
      expect(json['gender'], 'male');
      expect(json['initialWeightKg'], 4.2);
      expect(json['initialHeightCm'], 52.0);
      expect(json['allergies'], 'lactose');
      expect(json['currentUserRole'], 'owner');
    });

    test('should omit null optional fields in JSON', () {
      final baby = Baby(
        id: 'baby-004',
        name: 'Clara',
        birthDate: DateTime.parse('2025-06-01'),
        currentUserRole: 'caregiver',
      );

      final json = baby.toJson();

      expect(json.containsKey('gender'), isFalse);
      expect(json.containsKey('initialWeightKg'), isFalse);
      expect(json.containsKey('initialHeightCm'), isFalse);
      expect(json.containsKey('allergies'), isFalse);
    });

    test('should support copyWith', () {
      final baby = Baby(
        id: 'baby-005',
        name: 'Original',
        birthDate: DateTime.parse('2025-01-01'),
        currentUserRole: 'owner',
      );

      final updated = baby.copyWith(name: 'Updated', gender: 'female');

      expect(updated.id, 'baby-005');
      expect(updated.name, 'Updated');
      expect(updated.gender, 'female');
      expect(updated.currentUserRole, 'owner');
      expect(updated.birthDate, DateTime.parse('2025-01-01'));
    });

    test('should have value equality', () {
      final baby1 = Baby(
        id: '1',
        name: 'Test',
        birthDate: DateTime.parse('2025-01-01'),
        currentUserRole: 'owner',
      );
      final baby2 = Baby(
        id: '1',
        name: 'Test',
        birthDate: DateTime.parse('2025-01-01'),
        currentUserRole: 'owner',
      );

      expect(baby1, equals(baby2));
      expect(baby1.hashCode, equals(baby2.hashCode));
    });

    test('birthDate serializes as date-only string', () {
      final baby = Baby(
        id: '1',
        name: 'Baby',
        birthDate: DateTime.parse('2025-06-12T10:30:00.000Z'),
        currentUserRole: 'owner',
      );

      final json = baby.toJson();

      // Should be date-only, no time component
      expect(json['birthDate'], '2025-06-12');
    });
  });

  group('Caregiver model', () {
    test('should create Caregiver instance from JSON', () {
      final json = {
        'id': 'usr-001',
        'name': 'Maria Silva',
        'email': 'maria@example.com',
        'role': 'owner',
      };

      final caregiver = Caregiver.fromJson(json);

      expect(caregiver.id, 'usr-001');
      expect(caregiver.name, 'Maria Silva');
      expect(caregiver.email, 'maria@example.com');
      expect(caregiver.role, 'owner');
    });

    test('should serialize Caregiver to JSON', () {
      final caregiver = Caregiver(
        id: 'usr-002',
        name: 'João',
        email: 'joao@example.com',
        role: 'caregiver',
      );

      final json = caregiver.toJson();

      expect(json['id'], 'usr-002');
      expect(json['name'], 'João');
      expect(json['email'], 'joao@example.com');
      expect(json['role'], 'caregiver');
    });

    test('should have value equality', () {
      final c1 = Caregiver(
        id: '1',
        name: 'Test',
        email: 't@t.com',
        role: 'owner',
      );
      final c2 = Caregiver(
        id: '1',
        name: 'Test',
        email: 't@t.com',
        role: 'owner',
      );

      expect(c1, equals(c2));
    });
  });
}
