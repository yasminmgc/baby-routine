import 'package:flutter_test/flutter_test.dart';
import 'package:baby_routine_app/features/auth/models/user.dart';

void main() {
  group('User model', () {
    test('should create User instance from JSON', () {
      final json = {
        'id': 'usr-001',
        'name': 'Maria Silva',
        'email': 'maria@example.com',
        'createdAt': '2025-06-01T10:30:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, 'usr-001');
      expect(user.name, 'Maria Silva');
      expect(user.email, 'maria@example.com');
      expect(user.createdAt, DateTime.parse('2025-06-01T10:30:00.000Z'));
    });

    test('should handle null createdAt', () {
      final json = {
        'id': 'usr-002',
        'name': 'João Souza',
        'email': 'joao@example.com',
        'createdAt': null,
      };

      final user = User.fromJson(json);

      expect(user.createdAt, isNull);
    });

    test('should serialize User to JSON', () {
      final user = User(
        id: 'usr-003',
        name: 'Ana Costa',
        email: 'ana@example.com',
        createdAt: DateTime.parse('2025-05-15T08:00:00.000Z'),
      );

      final json = user.toJson();

      expect(json['id'], 'usr-003');
      expect(json['name'], 'Ana Costa');
      expect(json['email'], 'ana@example.com');
      expect(json['createdAt'], '2025-05-15T08:00:00.000');
    });

    test('should omit null createdAt in JSON', () {
      final user = User(
        id: 'usr-004',
        name: 'Pedro Lima',
        email: 'pedro@example.com',
      );

      final json = user.toJson();

      expect(json.containsKey('createdAt'), isFalse);
    });

    test('should support copyWith', () {
      final user = User(
        id: 'usr-005',
        name: 'Test User',
        email: 'test@example.com',
      );

      final updated = user.copyWith(name: 'Updated Name');

      expect(updated.id, 'usr-005');
      expect(updated.name, 'Updated Name');
      expect(updated.email, 'test@example.com');
    });

    test('should have value equality', () {
      final user1 = User(id: '1', name: 'A', email: 'a@b.com');
      final user2 = User(id: '1', name: 'A', email: 'a@b.com');

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });
  });

  group('LoginResponse model', () {
    test('should create LoginResponse from JSON', () {
      final json = {
        'token': 'jwt-token-123',
        'user': {
          'id': 'usr-001',
          'name': 'Maria',
          'email': 'maria@example.com',
          'createdAt': '2025-06-01T10:30:00.000Z',
        },
      };

      final response = LoginResponse.fromJson(json);

      expect(response.token, 'jwt-token-123');
      expect(response.user.id, 'usr-001');
      expect(response.user.name, 'Maria');
    });

    test('should serialize LoginResponse to JSON', () {
      final response = LoginResponse(
        token: 'jwt-abc',
        user: User(
          id: '1',
          name: 'Test',
          email: 'test@example.com',
        ),
      );

      final json = response.toJson();

      expect(json['token'], 'jwt-abc');
      expect(json['user']['id'], '1');
    });
  });

  group('RegisterResponse model', () {
    test('should create RegisterResponse from JSON', () {
      final json = {
        'id': 'usr-new',
        'name': 'New User',
        'email': 'new@example.com',
        'token': 'jwt-new-token',
      };

      final response = RegisterResponse.fromJson(json);

      expect(response.id, 'usr-new');
      expect(response.name, 'New User');
      expect(response.email, 'new@example.com');
      expect(response.token, 'jwt-new-token');
    });

    test('should serialize RegisterResponse to JSON', () {
      final response = RegisterResponse(
        id: 'r1',
        name: 'Reg User',
        email: 'reg@example.com',
        token: 'token-xyz',
      );

      final json = response.toJson();

      expect(json['id'], 'r1');
      expect(json['name'], 'Reg User');
      expect(json['email'], 'reg@example.com');
      expect(json['token'], 'token-xyz');
    });
  });
}
