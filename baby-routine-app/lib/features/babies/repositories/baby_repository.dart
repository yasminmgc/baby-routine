import '../models/baby.dart';

abstract class BabyRepository {
  Future<Baby> create({
    required String name,
    required DateTime birthDate,
    String? gender,
    double? initialWeightKg,
    double? initialHeightCm,
    String? allergies,
  });

  Future<List<Baby>> list();

  Future<Baby> getById(String id);

  Future<Baby> update(
    String id, {
    String? name,
    DateTime? birthDate,
    String? gender,
    double? initialWeightKg,
    double? initialHeightCm,
    String? allergies,
  });

  Future<void> delete(String id);

  Future<void> addCaregiver(String babyId, String email);

  Future<void> removeCaregiver(String babyId, String userId);

  Future<List<Caregiver>> listCaregivers(String babyId);
}
