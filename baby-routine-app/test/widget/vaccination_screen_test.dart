import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/core/constants/app_colors.dart';
import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/features/events/controllers/event_controller.dart';
import 'package:baby_routine_app/features/events/models/routine_event.dart';
import 'package:baby_routine_app/features/events/presentation/vaccination_screen.dart';
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
          eventType: 'vaccination',
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
          eventType: 'vaccination',
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

Widget wrapVaccinationScreen({MockEventRepository? mockRepo}) {
  return ProviderScope(
    overrides: [
      if (mockRepo != null)
        eventRepositoryProvider.overrideWithValue(mockRepo),
      selectedBabyProvider.overrideWithValue(_testBaby),
    ],
    child: const MaterialApp(
      home: VaccinationScreen(),
    ),
  );
}

void main() {
  group('VaccinationScreen', () {
    testWidgets('shows app bar title in pt-BR', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      expect(find.text('Registrar Vacina'), findsOneWidget);
    });

    testWidgets('shows vaccine name field', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      expect(find.text('Nome da vacina'), findsOneWidget);
    });

    testWidgets('shows lot field', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      expect(find.text('Lote'), findsOneWidget);
    });

    testWidgets('shows application site dropdown with pt-BR labels',
        (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      expect(find.text('Local de aplicação'), findsOneWidget);
      expect(find.text('Coxa esquerda'), findsOneWidget);
    });

    testWidgets('shows applied by field', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      expect(find.text('Aplicado por'), findsOneWidget);
    });

    testWidgets('shows reactions field', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      expect(find.text('Reações'), findsOneWidget);
    });

    testWidgets('shows notes field', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      expect(find.text('Observações'), findsOneWidget);
    });

    testWidgets('shows register and cancel buttons', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      expect(find.text('Registrar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('validates vaccine name is required', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      // Tap register with empty vaccine name
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe o nome da vacina'), findsOneWidget);
    });

    testWidgets('submits vaccination event with required fields', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      // Fill vaccine name (required)
      await tester.enterText(
          find.widgetWithText(AppTextField, 'Nome da vacina'), 'Pentavalente');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(find.text('Vacina registrada com sucesso!'), findsOneWidget);
    });

    testWidgets('shows error snackbar on failure', (tester) async {
      final mockRepo = MockEventRepository()
        ..createError = Exception('Erro ao registrar vacina');

      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      // Fill required vaccine name first
      await tester.enterText(
          find.widgetWithText(AppTextField, 'Nome da vacina'), 'Pentavalente');

      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(find.text('Exception: Erro ao registrar vacina'), findsOneWidget);
    });

    testWidgets('site dropdown has all 4 options', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      await tester.tap(find.text('Coxa esquerda'));
      await tester.pumpAndSettle();

      expect(find.text('Coxa direita'), findsOneWidget);
      expect(find.text('Braço esquerdo'), findsOneWidget);
      expect(find.text('Braço direito'), findsOneWidget);
    });

    testWidgets('renders in lilac theme', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.lilacDark);
      expect(appBar.foregroundColor, AppColors.white);
    });

    testWidgets('cancel button is enabled', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapVaccinationScreen(mockRepo: mockRepo));

      final cancelButton = find.text('Cancelar');
      expect(cancelButton, findsOneWidget);

      final button = tester.widget<OutlinedButton>(cancelButton);
      expect(button.onPressed, isNotNull);
    });
  });
}
