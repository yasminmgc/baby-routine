import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/dio_provider.dart';
import '../../../../shared/providers/selected_baby_provider.dart';
import '../models/note.dart';
import '../repositories/note_repository.dart';
import '../repositories/note_repository_impl.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(ref.watch(dioClientProvider));
});

final noteControllerProvider =
    AsyncNotifierProvider<NoteController, void>(NoteController.new);

class NoteController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  NoteRepository get _repository => ref.read(noteRepositoryProvider);

  String get _babyId {
    final baby = ref.read(selectedBabyProvider);
    if (baby == null) {
      throw Exception('Nenhum bebê selecionado');
    }
    return baby.id;
  }

  Future<Note> createNote(String content) async {
    state = const AsyncLoading();
    late Note note;
    state = await AsyncValue.guard(() async {
      note = await _repository.create(_babyId, content);
    });
    return note;
  }

  Future<List<Note>> listNotes() async {
    return _repository.list(_babyId);
  }

  Future<Note> updateNote(String noteId, String content) async {
    state = const AsyncLoading();
    late Note note;
    state = await AsyncValue.guard(() async {
      note = await _repository.update(_babyId, noteId, content);
    });
    return note;
  }

  Future<void> deleteNote(String noteId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.delete(_babyId, noteId);
    });
  }
}
