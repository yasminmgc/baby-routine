import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/dio_provider.dart';
import '../../../../shared/providers/selected_baby_provider.dart';
import '../models/health_record.dart';
import '../repositories/health_repository.dart';
import '../repositories/health_repository_impl.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepositoryImpl(ref.watch(dioClientProvider));
});

final healthControllerProvider =
    AsyncNotifierProvider<HealthController, void>(HealthController.new);

class HealthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  HealthRepository get _repository => ref.read(healthRepositoryProvider);

  String get _babyId {
    final baby = ref.read(selectedBabyProvider);
    if (baby == null) {
      throw Exception('Nenhum bebê selecionado');
    }
    return baby.id;
  }

  Future<List<HealthRecord>> listHealthRecords({String? type}) async {
    return _repository.list(_babyId, type: type);
  }
}
