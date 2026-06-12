import '../models/note.dart';

abstract class NoteRepository {
  Future<Note> create(String babyId, String content);
  Future<List<Note>> list(String babyId);
  Future<Note> update(String babyId, String noteId, String content);
  Future<void> delete(String babyId, String noteId);
}
