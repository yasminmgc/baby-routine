import '../../../../core/network/dio_client.dart';
import '../models/note.dart';
import 'note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final DioClient _dioClient;

  NoteRepositoryImpl(this._dioClient);

  @override
  Future<Note> create(String babyId, String content) async {
    final response = await _dioClient.post(
      '/babies/$babyId/notes',
      data: {'content': content},
    );
    return Note.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Note>> list(String babyId) async {
    final response = await _dioClient.get('/babies/$babyId/notes');
    final list = response.data as List<dynamic>;
    return list
        .map((item) => Note.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Note> update(String babyId, String noteId, String content) async {
    final response = await _dioClient.put(
      '/babies/$babyId/notes/$noteId',
      data: {'content': content},
    );
    return Note.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String babyId, String noteId) async {
    await _dioClient.delete('/babies/$babyId/notes/$noteId');
  }
}
