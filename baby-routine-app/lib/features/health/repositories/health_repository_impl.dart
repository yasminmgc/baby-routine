import '../../../../core/network/dio_client.dart';
import '../models/health_record.dart';
import 'health_repository.dart';

class HealthRepositoryImpl implements HealthRepository {
  final DioClient _dioClient;

  HealthRepositoryImpl(this._dioClient);

  @override
  Future<List<HealthRecord>> list(String babyId, {String? type}) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;

    final response = await _dioClient.get(
      '/babies/$babyId/health',
      params: params.isNotEmpty ? params : null,
    );

    final list = response.data as List<dynamic>;
    return list
        .map((item) => HealthRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
