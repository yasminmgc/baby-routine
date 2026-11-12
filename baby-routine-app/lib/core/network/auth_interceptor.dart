import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear stored token on auth failure so the redirect logic
      // in GoRouter picks it up and sends the user to /login.
      _storage.deleteToken();
    }
    handler.next(err);
  }
}
