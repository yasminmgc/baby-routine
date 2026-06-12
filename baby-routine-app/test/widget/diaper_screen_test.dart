import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/core/constants/app_colors.dart';
import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/features/events/controllers/event_controller.dart';
import 'package:baby_routine_app/features/events/models/routine_event.dart';
import 'package:baby_routine_app/features/events/presentation/diaper_screen.dart';
import 'package:baby_routine_app/features/events/repositories/event_repository.dart';
import 'package:baby_routine_app/shared/providers/selected_baby_provider.dart';

class MockEventRepository implements EventRepository {
  RoutineEvent? createResult;
  Object? createError;
  List<RoutineEvent>? listResult;

  @override
  Future<RoutineEvent> create({
    required String babyId,
    required String eventType,
    required DateTime occurredAt,
    DateTime? scheduledAt,
    String status = 'completed',
    Map<String, dynamic>? details,
    String? notes,
  }) async {
    if (createError != null) throw createError!;
    return createResult ??
        RoutineEvent(
          id: 'new-event',
          eventType: eventType,
          occurredAt: occurredAt,
          status: status,
          details: details,
          notes: notes,
        );
  }

  @override
  Future<List<RoutineEvent>> list(
    String babyId, {
    String? type,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  }) async {
    return listResult ?? [];
  }

  @override
  Future<RoutineEvent> getById(String babyId, String eventId) async {
    return RoutineEvent(id: eventId, eventType: 'diaper', status: 'completed');
  }

  @override
  Future<RoutineEvent> update(
    String babyId,
    String eventId, {
    DateTime? occurredAt,
    String? status,
    Map<String, dynamic>? details,
    String? notes,
  }) async {
    return RoutineEvent(id: eventId, eventType: 'diaper', status: 'completed');
  }

  @override
  Future<void> delete(String babyId, String eventId) async {}
}

final _testBaby = Baby(
  id: 'baby-001',
  name: 'Lucas',
  birthDate: DateTime.parse('2025-01-15'),
  gender: 'male',
  currentUserRole: 'owner',
);

Widget wrapDiaperScreen({MockEventRepository? mockRepo}) {
  return ProviderScope(
    overrides: [
      if (mockRepo != null)
        eventRepositoryProvider.overrideWithValue(mockRepo),
      selectedBabyProvider.overrideWithValue(_testBaby),
    ],
    child: const MaterialApp(
      home: DiaperScreen(),
    ),
  );
}

void main() {
  group('DiaperScreen', () {
    testWidgets('shows app bar title in pt-BR', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      expect(find.text('Registrar Fralda'), findsOneWidget);
    });

    testWidgets('shows type section label', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      expect(find.text('Tipo'), findsOneWidget);
    });

    testWidgets('shows three type choice chips in pt-BR', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      expect(find.text('Xixi'), findsOneWidget);
      expect(find.text('Cocô'), findsOneWidget);
      expect(find.text('Ambos'), findsOneWidget);
    });

    testWidgets('shows consistency dropdown with pt-BR labels', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      expect(find.text('Consistência'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('shows rash toggle', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      expect(find.text('Assadura'), findsOneWidget);
      expect(find.text('Sem assadura'), findsOneWidget);
    });

    testWidgets('rash toggle changes state when tapped', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      // Initially shows "Sem assadura"
      expect(find.text('Sem assadura'), findsOneWidget);

      // Tap the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Should now show "Com assadura"
      expect(find.text('Com assadura'), findsOneWidget);
    });

    testWidgets('shows notes field', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      expect(find.text('Observações'), findsOneWidget);
    });

    testWidgets('shows register and cancel buttons', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      expect(find.text('Registrar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('shows error snackbar on failure', (tester) async {
      final mockRepo = MockEventRepository()
        ..createError = Exception('Erro ao registrar fralda');

      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(find.text('Exception: Erro ao registrar fralda'),
          findsOneWidget);
    });

    testWidgets('renders in lilac theme', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.lilacDark);
    });

    testWidgets('submit button shows loading spinner', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      // Tap register
      await tester.tap(find.text('Registrar'));
      await tester.pump();

      // Should show CircularProgressIndicator while loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('consistency dropdown has all options in pt-BR', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      // Tap consistency dropdown to expand
      await tester.tap(find.text('Normal'));
      await tester.pumpAndSettle();

      expect(find.text('Normal'), findsWidgets);
      expect(find.text('Pastosa'), findsOneWidget);
      expect(find.text('Líquida'), findsOneWidget);
    });

    testWidgets('choosing poop type shows color options', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapDiaperScreen(mockRepo: mockRepo));

      // Tap "Cocô" chip
      await tester.tap(find.text('Cocô'));
      await tester.pumpAndSettle();

      // Should now show color section
      expect(find.text('Cor'), findsOneWidget);
      expect(find.text('Amarelo'), findsOneWidget);
      expect(find.text('Verde'), findsOneWidget);
      expect(find.text('Marrom'), findsOneWidget);
    });
  });
}
