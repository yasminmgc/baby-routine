import '../models/health_record.dart';

abstract class HealthRepository {
  Future<List<HealthRecord>> list(String babyId, {String? type});
}
