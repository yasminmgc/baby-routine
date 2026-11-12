import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  final Dio _dio;
  final SecureStorage _storage;

  DioClient(this._storage)
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(AuthInterceptor(_storage));
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? params,
  }) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(
    String path, {
    dynamic data,
  }) =>
      _dio.post(path, data: data);

  Future<Response> put(
    String path, {
    dynamic data,
  }) =>
      _dio.put(path, data: data);

  Future<Response> patch(
    String path, {
    dynamic data,
  }) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}
