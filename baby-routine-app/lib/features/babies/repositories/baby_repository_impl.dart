import '../../../core/network/dio_client.dart';
import '../models/baby.dart';
import 'baby_repository.dart';

class BabyRepositoryImpl implements BabyRepository {
  final DioClient _dioClient;

  BabyRepositoryImpl(this._dioClient);

  @override
  Future<Baby> create({
    required String name,
    required DateTime birthDate,
    String? gender,
    double? initialWeightKg,
    double? initialHeightCm,
    String? allergies,
  }) async {
    final response = await _dioClient.post('/babies', data: {
      'name': name,
      'birthDate': birthDate.toIso8601String().split('T').first,
      if (gender != null) 'gender': gender,
      if (initialWeightKg != null) 'initialWeightKg': initialWeightKg,
      if (initialHeightCm != null) 'initialHeightCm': initialHeightCm,
      if (allergies != null && allergies.isNotEmpty) 'allergies': allergies,
    });
    return Baby.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Baby>> list() async {
    final response = await _dioClient.get('/babies');
    final list = response.data as List<dynamic>;
    return list.map((item) => Baby.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<Baby> getById(String id) async {
    final response = await _dioClient.get('/babies/$id');
    return Baby.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Baby> update(
    String id, {
    String? name,
    DateTime? birthDate,
    String? gender,
    double? initialWeightKg,
    double? initialHeightCm,
    String? allergies,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (birthDate != null) {
      data['birthDate'] = birthDate.toIso8601String().split('T').first;
    }
    if (gender != null) data['gender'] = gender;
    if (initialWeightKg != null) data['initialWeightKg'] = initialWeightKg;
    if (initialHeightCm != null) data['initialHeightCm'] = initialHeightCm;
    if (allergies != null) data['allergies'] = allergies;

    final response = await _dioClient.put('/babies/$id', data: data);
    return Baby.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String id) async {
    await _dioClient.delete('/babies/$id');
  }

  @override
  Future<void> addCaregiver(String babyId, String email) async {
    await _dioClient.post('/babies/$babyId/caregivers', data: {
      'email': email,
    });
  }

  @override
  Future<void> removeCaregiver(String babyId, String userId) async {
    await _dioClient.delete('/babies/$babyId/caregivers/$userId');
  }

  @override
  Future<List<Caregiver>> listCaregivers(String babyId) async {
    final response = await _dioClient.get('/babies/$babyId/caregivers');
    final list = response.data as List<dynamic>;
    return list
        .map((item) => Caregiver.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
