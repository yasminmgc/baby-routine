import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/selected_baby_provider.dart';
import '../models/checklist_item.dart';
import '../repositories/checklist_repository.dart';
import '../repositories/checklist_repository_impl.dart';

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  return ChecklistRepositoryImpl(ref.watch(dioClientProvider));
});

final checklistControllerProvider =
    AsyncNotifierProvider<ChecklistController, ChecklistResponse>(
        ChecklistController.new);

class ChecklistController extends AsyncNotifier<ChecklistResponse> {
  Future<ChecklistResponse> _fetch(String babyId, {String? date}) async {
    final repository = ref.read(checklistRepositoryProvider);
    return repository.fetch(babyId, date: date);
  }

  @override
  Future<ChecklistResponse> build() async {
    final baby = ref.read(selectedBabyProvider);
    if (baby == null) {
      throw Exception('Nenhum bebê selecionado');
    }
    return _fetch(baby.id);
  }

  Future<void> refresh({String? date}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final baby = ref.read(selectedBabyProvider);
      if (baby == null) {
        throw Exception('Nenhum bebê selecionado');
      }
      return _fetch(baby.id, date: date);
    });
  }

  Future<ChecklistResponse> refreshSync({String? date}) async {
    final baby = ref.read(selectedBabyProvider);
    if (baby == null) {
      throw Exception('Nenhum bebê selecionado');
    }
    return _fetch(baby.id, date: date);
  }
}
