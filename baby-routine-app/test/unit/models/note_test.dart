import 'package:flutter_test/flutter_test.dart';
import 'package:baby_routine_app/features/notes/models/note.dart';

void main() {
  group('Note', () {
    final json = {
      'id': 'note-001',
      'babyId': 'baby-001',
      'content': 'Começou a engatinhar hoje!',
      'createdAt': '2026-06-10T15:30:00.000',
    };

    test('fromJson parses all fields', () {
      final note = Note.fromJson(json);

      expect(note.id, 'note-001');
      expect(note.babyId, 'baby-001');
      expect(note.content, 'Começou a engatinhar hoje!');
      expect(note.createdAt, DateTime.parse('2026-06-10T15:30:00.000'));
    });

    test('toJson produces correct map', () {
      final note = Note.fromJson(json);
      final output = note.toJson();

      expect(output['id'], 'note-001');
      expect(output['babyId'], 'baby-001');
      expect(output['content'], 'Começou a engatinhar hoje!');
      expect(output['createdAt'], '2026-06-10T15:30:00.000');
    });

    test('copyWith creates new instance with updated fields', () {
      final note = Note.fromJson(json);
      final updated = note.copyWith(content: 'Novo conteúdo');

      expect(updated.content, 'Novo conteúdo');
      expect(updated.id, note.id);
      expect(updated.babyId, note.babyId);
      expect(updated.createdAt, note.createdAt);
    });

    test('copyWith preserves existing values when no args', () {
      final note = Note.fromJson(json);
      final copy = note.copyWith();

      expect(copy, equals(note));
    });

    test('supports equality', () {
      final a = Note.fromJson(json);
      final b = Note.fromJson(json);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different notes are not equal', () {
      final a = Note.fromJson(json);
      final b = Note(
        id: 'note-002',
        babyId: 'baby-001',
        content: 'Outro conteúdo',
        createdAt: DateTime.now(),
      );

      expect(a, isNot(equals(b)));
    });

    test('toString contains key fields', () {
      final note = Note.fromJson(json);
      final str = note.toString();

      expect(str, contains('note-001'));
      expect(str, contains('Começou a engatinhar hoje!'));
    });
  });
}
