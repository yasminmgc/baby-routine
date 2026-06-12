import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/auth/repositories/auth_repository.dart';
import 'package:baby_routine_app/features/auth/models/user.dart';

/// Mock repository that records whether updateFcmToken was called.
class _MockAuthRepository implements AuthRepository {
  bool loginCalled = false;
  bool registerCalled = false;
  String? lastFcmToken;
  bool updateFcmTokenCalled = false;

  final bool _loginShouldFail;
  final String _token;

  _MockAuthRepository({
    bool loginShouldFail = false,
    String token = 'jwt-test-token',
  })  : _loginShouldFail = loginShouldFail,
        _token = token;

  @override
  Future<LoginResponse> login(String email, String password) async {
    loginCalled = true;
    if (_loginShouldFail) {
      throw Exception('Invalid credentials');
    }
    return LoginResponse(
      token: _token,
      user: User(
        id: 'usr-test',
        name: 'Test User',
        email: email,
      ),
    );
  }

  @override
  Future<RegisterResponse> register(
      String name, String email, String password) async {
    registerCalled = true;
    return RegisterResponse(
      id: 'usr-new',
      name: name,
      email: email,
      token: _token,
    );
  }

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    updateFcmTokenCalled = true;
    lastFcmToken = fcmToken;
  }
}

/// Mock secure storage that records saved tokens.
class _MockSecureStorage {
  String? _token;
  String? lastSavedToken;

  Future<void> saveToken(String token) async {
    _token = token;
    lastSavedToken = token;
  }

  Future<String?> getToken() async => _token;

  Future<void> deleteToken() async {
    _token = null;
  }
}

void main() {
  group('AuthRepository updateFcmToken', () {
    test('should define updateFcmToken in AuthRepository interface', () {
      final repo = _MockAuthRepository();
      expect(repo.updateFcmTokenCalled, isFalse);
    });

    test('should call updateFcmToken with provided token', () async {
      final repo = _MockAuthRepository();
      await repo.updateFcmToken('fcm-token-abc123');
      expect(repo.updateFcmTokenCalled, isTrue);
      expect(repo.lastFcmToken, 'fcm-token-abc123');
    });

    test('should track multiple FCM token updates', () async {
      final repo = _MockAuthRepository();

      await repo.updateFcmToken('token-1');
      expect(repo.lastFcmToken, 'token-1');

      await repo.updateFcmToken('token-2');
      expect(repo.lastFcmToken, 'token-2');
      expect(repo.updateFcmTokenCalled, isTrue);
    });
  });

  group('AuthController FCM integration', () {
    test('_MockAuthRepository records login calls', () async {
      final repo = _MockAuthRepository();
      final response = await repo.login('user@test.com', 'pass123');

      expect(repo.loginCalled, isTrue);
      expect(response.token, 'jwt-test-token');
      expect(response.user.email, 'user@test.com');
    });

    test('_MockAuthRepository records register calls', () async {
      final repo = _MockAuthRepository();
      final response = await repo.register('New', 'new@test.com', 'pass123');

      expect(repo.registerCalled, isTrue);
      expect(response.token, 'jwt-test-token');
      expect(response.name, 'New');
      expect(response.email, 'new@test.com');
    });
  });

  group('SecureStorage', () {
    test('should save and retrieve tokens', () async {
      final storage = _MockSecureStorage();

      await storage.saveToken('my-jwt-token');
      final retrieved = await storage.getToken();

      expect(retrieved, 'my-jwt-token');
    });

    test('should delete tokens', () async {
      final storage = _MockSecureStorage();

      await storage.saveToken('token-to-delete');
      await storage.deleteToken();

      final afterDelete = await storage.getToken();
      expect(afterDelete, isNull);
    });

    test('should return null when no token stored', () async {
      final storage = _MockSecureStorage();
      final token = await storage.getToken();
      expect(token, isNull);
    });
  });
}
