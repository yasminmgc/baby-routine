import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/storage_provider.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRepositoryImpl(dioClient);
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);
      final response = await repository.login(email, password);
      await storage.saveToken(response.token);
      await _registerFcmToken(repository);
    });
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);
      final response = await repository.register(name, email, password);
      await storage.saveToken(response.token);
      await _registerFcmToken(repository);
    });
  }

  Future<void> _registerFcmToken(AuthRepository repository) async {
    try {
      final notificationService = NotificationService();
      final fcmToken = await notificationService.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await repository.updateFcmToken(fcmToken);
      }
    } catch (_) {
      // Silently ignore FCM token registration failures —
      // notifications will be retried on next login or via updateFcmToken.
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.updateFcmToken(fcmToken);
    });
  }
}
