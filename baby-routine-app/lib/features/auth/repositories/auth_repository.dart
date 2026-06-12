import '../models/user.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String email, String password);

  Future<RegisterResponse> register(String name, String email, String password);

  Future<void> updateFcmToken(String fcmToken);
}
