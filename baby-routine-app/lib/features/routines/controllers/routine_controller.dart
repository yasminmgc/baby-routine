import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/selected_baby_provider.dart';
import '../models/routine.dart';
import '../repositories/routine_repository.dart';
import '../repositories/routine_repository_impl.dart';

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return RoutineRepositoryImpl(dioClient);
});

final routineControllerProvider =
    AsyncNotifierProvider<RoutineController, void>(RoutineController.new);

class RoutineController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  RoutineRepository get _repository => ref.read(routineRepositoryProvider);

  String get _babyId {
    final baby = ref.read(selectedBabyProvider);
    if (baby == null) {
      throw Exception('Nenhum bebê selecionado');
    }
    return baby.id;
  }

  Future<Routine> createRoutine({
    required String activityType,
    int? intervalMinutes,
    String? defaultStartTime,
  }) async {
    state = const AsyncLoading();
    late Routine routine;
    state = await AsyncValue.guard(() async {
      routine = await _repository.create(
        babyId: _babyId,
        activityType: activityType,
        intervalMinutes: intervalMinutes,
        defaultStartTime: defaultStartTime,
      );
    });
    return routine;
  }

  Future<List<Routine>> listRoutines() async {
    return _repository.list(_babyId);
  }

  Future<Routine> updateRoutine(
    String routineId, {
    String? activityType,
    int? intervalMinutes,
    String? defaultStartTime,
  }) async {
    state = const AsyncLoading();
    late Routine routine;
    state = await AsyncValue.guard(() async {
      routine = await _repository.update(
        _babyId,
        routineId,
        activityType: activityType,
        intervalMinutes: intervalMinutes,
        defaultStartTime: defaultStartTime,
      );
    });
    return routine;
  }

  Future<void> deleteRoutine(String routineId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.delete(_babyId, routineId);
    });
  }

  Future<Routine> toggleRoutine(String routineId, bool active) async {
    state = const AsyncLoading();
    late Routine routine;
    state = await AsyncValue.guard(() async {
      routine = await _repository.toggle(_babyId, routineId, active);
    });
    return routine;
  }
}
