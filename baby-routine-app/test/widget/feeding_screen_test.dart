import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/core/constants/app_colors.dart';
import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/features/events/controllers/event_controller.dart';
import 'package:baby_routine_app/features/events/models/routine_event.dart';
import 'package:baby_routine_app/features/events/presentation/feeding_screen.dart';
import 'package:baby_routine_app/features/events/repositories/event_repository.dart';
import 'package:baby_routine_app/shared/providers/selected_baby_provider.dart';

class MockEventRepository implements EventRepository {
  RoutineEvent? createResult;
  Object? createError;
  List<RoutineEvent>? listResult;
  RoutineEvent? getByIdResult;
  RoutineEvent? updateResult;

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
    return getByIdResult ??
        RoutineEvent(
          id: eventId,
          eventType: 'feeding',
          status: 'completed',
        );
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
    return updateResult ??
        RoutineEvent(
          id: eventId,
          eventType: 'feeding',
          occurredAt: occurredAt,
          status: status ?? 'completed',
        );
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

Widget wrapFeedingScreen({MockEventRepository? mockRepo}) {
  return ProviderScope(
    overrides: [
      if (mockRepo != null)
        eventRepositoryProvider.overrideWithValue(mockRepo),
      selectedBabyProvider.overrideWithValue(_testBaby),
    ],
    child: const MaterialApp(
      home: FeedingScreen(),
    ),
  );
}

void main() {
  group('FeedingScreen', () {
    testWidgets('shows app bar title in pt-BR', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapFeedingScreen(mockRepo: mockRepo));

      expect(find.text('Registrar Alimentação'), findsOneWidget);
    });

    testWidgets('shows feeding type dropdown with pt-BR labels', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapFeedingScreen(mockRepo: mockRepo));

      expect(find.text('Tipo de alimentação'), findsOneWidget);
      expect(find.text('Mamadeira'), findsOneWidget);
    });

    testWidgets('shows amount and duration fields', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapFeedingScreen(mockRepo: mockRepo));

      expect(find.text('Quantidade (ml)'), findsOneWidget);
      expect(find.text('Duração (min)'), findsOneWidget);
    });

    testWidgets('shows notes field', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapFeedingScreen(mockRepo: mockRepo));

      expect(find.text('Observações'), findsOneWidget);
    });

    testWidgets('shows register and cancel buttons', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapFeedingScreen(mockRepo: mockRepo));

      expect(find.text('Registrar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('submit button triggers loading state and success', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapFeedingScreen(mockRepo: mockRepo));

      // Tap register button without filling anything — still submits
      await tester.tap(find.text('Registrar'));
      await tester.pump();

      // Should show CircularProgressIndicator while loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error snackbar on failure', (tester) async {
      final mockRepo = MockEventRepository()
        ..createError = Exception('Erro ao registrar alimentação');

      await tester.pumpWidget(wrapFeedingScreen(mockRepo: mockRepo));

      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(find.text('Exception: Erro ao registrar alimentação'),
          findsOneWidget);
    });

    testWidgets('cancel button is present', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapFeedingScreen(mockRepo: mockRepo));

      final cancelButton = find.text('Cancelar');
      expect(cancelButton, findsOneWidget);

      // Verify it's enabled
      final button = tester.widget<OutlinedButton>(cancelButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('all dropdown options are present', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapFeedingScreen(mockRepo: mockRepo));

      // Tap the dropdown to expand
      await tester.tap(find.text('Mamadeira'));
      await tester.pumpAndSettle();

      expect(find.text('Mamadeira'), findsWidgets); // may appear multiple times
      expect(find.text('Peito'), findsOneWidget);
      expect(find.text('Sólidos'), findsOneWidget);
    });

    testWidgets('renders in lilac theme', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapFeedingScreen(mockRepo: mockRepo));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.lilacDark);
      expect(appBar.foregroundColor, AppColors.white);
    });
  });
}
