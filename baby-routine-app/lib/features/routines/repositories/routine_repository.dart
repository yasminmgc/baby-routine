import '../models/routine.dart';

abstract class RoutineRepository {
  Future<Routine> create({
    required String babyId,
    required String activityType,
    int? intervalMinutes,
    String? defaultStartTime,
  });

  Future<List<Routine>> list(String babyId);

  Future<Routine> update(
    String babyId,
    String routineId, {
    String? activityType,
    int? intervalMinutes,
    String? defaultStartTime,
  });

  Future<void> delete(String babyId, String routineId);

  Future<Routine> toggle(String babyId, String routineId, bool active);
}
