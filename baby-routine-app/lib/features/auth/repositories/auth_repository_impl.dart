import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../models/user.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;

  AuthRepositoryImpl(this._dioClient);

  @override
  Future<LoginResponse> login(String email, String password) async {
    final response = await _dioClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<RegisterResponse> register(
      String name, String email, String password) async {
    final response = await _dioClient.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    return RegisterResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    await _dioClient.patch('/auth/fcm-token', data: {
      'fcmToken': fcmToken,
    });
  }
}
