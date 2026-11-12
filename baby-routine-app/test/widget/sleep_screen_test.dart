import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/core/constants/app_colors.dart';
import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/features/events/controllers/event_controller.dart';
import 'package:baby_routine_app/features/events/models/routine_event.dart';
import 'package:baby_routine_app/features/events/presentation/sleep_screen.dart';
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
    return RoutineEvent(id: eventId, eventType: 'sleep', status: 'completed');
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
    return RoutineEvent(id: eventId, eventType: 'sleep', status: 'completed');
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

Widget wrapSleepScreen({MockEventRepository? mockRepo}) {
  return ProviderScope(
    overrides: [
      if (mockRepo != null)
        eventRepositoryProvider.overrideWithValue(mockRepo),
      selectedBabyProvider.overrideWithValue(_testBaby),
    ],
    child: const MaterialApp(
      home: SleepScreen(),
    ),
  );
}

void main() {
  group('SleepScreen', () {
    testWidgets('shows app bar title in pt-BR', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapSleepScreen(mockRepo: mockRepo));

      expect(find.text('Registrar Sono'), findsOneWidget);
    });

    testWidgets('shows start time and end time pickers', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapSleepScreen(mockRepo: mockRepo));

      expect(find.text('Hora de início'), findsOneWidget);
      expect(find.text('Hora de término'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsNWidgets(2));
    });

    testWidgets('shows location dropdown with pt-BR labels', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapSleepScreen(mockRepo: mockRepo));

      expect(find.text('Local'), findsOneWidget);
      expect(find.text('Berço'), findsOneWidget);
    });

    testWidgets('shows notes field', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapSleepScreen(mockRepo: mockRepo));

      expect(find.text('Observações'), findsOneWidget);
    });

    testWidgets('shows register and cancel buttons', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapSleepScreen(mockRepo: mockRepo));

      expect(find.text('Registrar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('shows error if submitting without times selected', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapSleepScreen(mockRepo: mockRepo));

      // Tap register without selecting times
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Selecione o horário de início'),
        findsOneWidget,
      );
    });

    testWidgets('shows error snackbar on failure', (tester) async {
      final mockRepo = MockEventRepository()
        ..createError = Exception('Erro ao registrar sono');

      await tester.pumpWidget(wrapSleepScreen(mockRepo: mockRepo));

      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(find.text('Exception: Erro ao registrar sono'),
          findsOneWidget);
    });

    testWidgets('renders in lilac theme', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapSleepScreen(mockRepo: mockRepo));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.lilacDark);
    });

    testWidgets('location dropdown options are in pt-BR', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapSleepScreen(mockRepo: mockRepo));

      // Tap location dropdown to expand
      await tester.tap(find.text('Berço'));
      await tester.pumpAndSettle();

      expect(find.text('Berço'), findsWidgets);
      expect(find.text('Cama'), findsOneWidget);
      expect(find.text('Colo'), findsOneWidget);
    });

    testWidgets('time pickers show default labels', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapSleepScreen(mockRepo: mockRepo));

      // Default labels when no time selected
      expect(find.text('Selecionar'), findsNWidgets(2));
    });
  });
}
