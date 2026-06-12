import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/features/notes/controllers/note_controller.dart';
import 'package:baby_routine_app/features/notes/models/note.dart';
import 'package:baby_routine_app/features/notes/presentation/notes_screen.dart';
import 'package:baby_routine_app/features/notes/repositories/note_repository.dart';
import 'package:baby_routine_app/shared/providers/selected_baby_provider.dart';

class MockNoteRepository implements NoteRepository {
  List<Note> listResult = [];
  Object? listError;
  Note? createResult;
  Object? createError;
  Note? updateResult;
  Object? updateError;
  Object? deleteError;

  @override
  Future<Note> create(String babyId, String content) async {
    if (createError != null) throw createError!;
    return createResult ??
        Note(
          id: 'new-note',
          babyId: babyId,
          content: content,
          createdAt: DateTime.now(),
        );
  }

  @override
  Future<List<Note>> list(String babyId) async {
    if (listError != null) throw listError!;
    return listResult;
  }

  @override
  Future<Note> update(String babyId, String noteId, String content) async {
    if (updateError != null) throw updateError!;
    return updateResult ??
        Note(
          id: noteId,
          babyId: babyId,
          content: content,
          createdAt: DateTime.now(),
        );
  }

  @override
  Future<void> delete(String babyId, String noteId) async {
    if (deleteError != null) throw deleteError!;
  }
}

final _testBaby = Baby(
  id: 'baby-001',
  name: 'Lucas',
  birthDate: DateTime.parse('2025-01-15'),
  gender: 'male',
  currentUserRole: 'owner',
);

final _testNotes = [
  Note(
    id: 'n1',
    babyId: 'baby-001',
    content: 'Começou a engatinhar hoje!',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Note(
    id: 'n2',
    babyId: 'baby-001',
    content: 'Dormiu a noite toda pela primeira vez.',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

Widget wrapNotesScreen({MockNoteRepository? mockRepo}) {
  return ProviderScope(
    overrides: [
      if (mockRepo != null)
        noteRepositoryProvider.overrideWithValue(mockRepo),
      selectedBabyProvider.overrideWithValue(_testBaby),
    ],
    child: const MaterialApp(
      home: NotesScreen(),
    ),
  );
}

void main() {
  group('NotesScreen', () {
    testWidgets('shows app bar title in pt-BR', (tester) async {
      final mockRepo = MockNoteRepository();
      await tester.pumpWidget(wrapNotesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Anotações'), findsOneWidget);
    });

    testWidgets('shows notes list with content and dates', (tester) async {
      final mockRepo = MockNoteRepository()
        ..listResult = _testNotes;

      await tester.pumpWidget(wrapNotesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Começou a engatinhar hoje!'), findsOneWidget);
      expect(
          find.text('Dormiu a noite toda pela primeira vez.'), findsOneWidget);
    });

    testWidgets('shows relative time for recent notes', (tester) async {
      final mockRepo = MockNoteRepository()
        ..listResult = _testNotes;

      await tester.pumpWidget(wrapNotesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Recent note should show "Há X h" or "Agora mesmo"
      expect(find.text('Há 2 h'), findsOneWidget);
    });

    testWidgets('shows full date for older notes', (tester) async {
      final mockRepo = MockNoteRepository()
        ..listResult = _testNotes;

      await tester.pumpWidget(wrapNotesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Older note (2 days ago) should show formatted date
      final now = DateTime.now();
      final expectedDate =
          '${(now.day - 2).toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('shows FAB to add new note', (tester) async {
      final mockRepo = MockNoteRepository()
        ..listResult = _testNotes;

      await tester.pumpWidget(wrapNotesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows empty state when no notes', (tester) async {
      final mockRepo = MockNoteRepository()
        ..listResult = [];

      await tester.pumpWidget(wrapNotesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma anotação'), findsOneWidget);
    });

    testWidgets('shows error state on load failure', (tester) async {
      final mockRepo = MockNoteRepository()
        ..listError = Exception('Erro de rede');

      await tester.pumpWidget(wrapNotesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Erro ao carregar anotações'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      final mockRepo = MockNoteRepository();
      await tester.pumpWidget(wrapNotesScreen(mockRepo: mockRepo));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('FAB opens add note dialog', (tester) async {
      final mockRepo = MockNoteRepository()
        ..listResult = _testNotes;

      await tester.pumpWidget(wrapNotesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Nova anotação'), findsOneWidget);
      expect(find.text('Criar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('shows popup menu on each note', (tester) async {
      final mockRepo = MockNoteRepository()
        ..listResult = _testNotes;

      await tester.pumpWidget(wrapNotesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Show popup menu by tapping the more_vert icon
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);
    });

    testWidgets('supports pull to refresh', (tester) async {
      final mockRepo = MockNoteRepository()
        ..listResult = _testNotes;

      await tester.pumpWidget(wrapNotesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
