import '../../../core/network/dio_client.dart';
import '../models/routine.dart';
import 'routine_repository.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  final DioClient _dioClient;

  RoutineRepositoryImpl(this._dioClient);

  @override
  Future<Routine> create({
    required String babyId,
    required String activityType,
    int? intervalMinutes,
    String? defaultStartTime,
  }) async {
    final data = <String, dynamic>{
      'activityType': activityType,
    };
    if (intervalMinutes != null) data['intervalMinutes'] = intervalMinutes;
    if (defaultStartTime != null) {
      data['defaultStartTime'] = defaultStartTime;
    }

    final response = await _dioClient.post(
      '/babies/$babyId/routines',
      data: data,
    );

    return Routine.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Routine>> list(String babyId) async {
    final response = await _dioClient.get('/babies/$babyId/routines');
    final list = response.data as List<dynamic>;
    return list
        .map((item) => Routine.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Routine> update(
    String babyId,
    String routineId, {
    String? activityType,
    int? intervalMinutes,
    String? defaultStartTime,
  }) async {
    final data = <String, dynamic>{};
    if (activityType != null) data['activityType'] = activityType;
    if (intervalMinutes != null) data['intervalMinutes'] = intervalMinutes;
    if (defaultStartTime != null) {
      data['defaultStartTime'] = defaultStartTime;
    }

    final response = await _dioClient.put(
      '/babies/$babyId/routines/$routineId',
      data: data,
    );

    return Routine.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String babyId, String routineId) async {
    await _dioClient.delete('/babies/$babyId/routines/$routineId');
  }

  @override
  Future<Routine> toggle(String babyId, String routineId, bool active) async {
    final response = await _dioClient.patch(
      '/babies/$babyId/routines/$routineId/toggle',
      data: {'active': active},
    );

    return Routine.fromJson(response.data as Map<String, dynamic>);
  }
}
