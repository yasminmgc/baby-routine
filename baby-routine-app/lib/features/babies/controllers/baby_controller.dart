import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/selected_baby_provider.dart';
import '../models/baby.dart';
import '../repositories/baby_repository.dart';
import '../repositories/baby_repository_impl.dart';

final babyRepositoryProvider = Provider<BabyRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BabyRepositoryImpl(dioClient);
});

final babyControllerProvider =
    AsyncNotifierProvider<BabyController, void>(BabyController.new);

class BabyController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  BabyRepository get _repository => ref.read(babyRepositoryProvider);

  Future<List<Baby>> listBabies() async {
    return _repository.list();
  }

  Future<void> createBaby({
    required String name,
    required DateTime birthDate,
    String? gender,
    double? initialWeightKg,
    double? initialHeightCm,
    String? allergies,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final baby = await _repository.create(
        name: name,
        birthDate: birthDate,
        gender: gender,
        initialWeightKg: initialWeightKg,
        initialHeightCm: initialHeightCm,
        allergies: allergies,
      );
      ref.read(selectedBabyProvider.notifier).state = baby;
    });
  }

  Future<void> updateBaby(
    String id, {
    String? name,
    DateTime? birthDate,
    String? gender,
    double? initialWeightKg,
    double? initialHeightCm,
    String? allergies,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final baby = await _repository.update(
        id,
        name: name,
        birthDate: birthDate,
        gender: gender,
        initialWeightKg: initialWeightKg,
        initialHeightCm: initialHeightCm,
        allergies: allergies,
      );
      // Update the selected baby if it's the same one
      final current = ref.read(selectedBabyProvider);
      if (current?.id == baby.id) {
        ref.read(selectedBabyProvider.notifier).state = baby;
      }
    });
  }

  Future<void> deleteBaby(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.delete(id);
      ref.read(selectedBabyProvider.notifier).state = null;
    });
  }

  Future<void> addCaregiver(String babyId, String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.addCaregiver(babyId, email);
    });
  }

  Future<void> removeCaregiver(String babyId, String userId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.removeCaregiver(babyId, userId);
    });
  }

  Future<List<Caregiver>> listCaregivers(String babyId) async {
    return _repository.listCaregivers(babyId);
  }
}
