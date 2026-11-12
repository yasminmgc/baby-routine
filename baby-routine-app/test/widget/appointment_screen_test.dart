import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/core/constants/app_colors.dart';
import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/features/events/controllers/event_controller.dart';
import 'package:baby_routine_app/features/events/models/routine_event.dart';
import 'package:baby_routine_app/features/events/presentation/appointment_screen.dart';
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
          eventType: 'appointment',
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
          eventType: 'appointment',
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

Widget wrapAppointmentScreen({MockEventRepository? mockRepo}) {
  return ProviderScope(
    overrides: [
      if (mockRepo != null)
        eventRepositoryProvider.overrideWithValue(mockRepo),
      selectedBabyProvider.overrideWithValue(_testBaby),
    ],
    child: const MaterialApp(
      home: AppointmentScreen(),
    ),
  );
}

void main() {
  group('AppointmentScreen', () {
    testWidgets('shows app bar title in pt-BR', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      expect(find.text('Registrar Consulta'), findsOneWidget);
    });

    testWidgets('shows professional name field', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      expect(find.text('Nome do profissional'), findsOneWidget);
    });

    testWidgets('shows specialty field', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      expect(find.text('Especialidade'), findsOneWidget);
    });

    testWidgets('shows appointment type dropdown with pt-BR labels',
        (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      expect(find.text('Tipo de consulta'), findsOneWidget);
      expect(find.text('Rotina'), findsOneWidget);
    });

    testWidgets('shows recommendations field', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      expect(find.text('Recomendações'), findsOneWidget);
    });

    testWidgets('shows requested exams section', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      expect(find.text('Exames solicitados'), findsOneWidget);
    });

    testWidgets('shows notes field', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      expect(find.text('Observações'), findsOneWidget);
    });

    testWidgets('shows register and cancel buttons', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      expect(find.text('Registrar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('validates professional name is required', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      // Tap register with empty professional name
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.text('Informe o nome do profissional'), findsOneWidget);
    });

    testWidgets('submits appointment event with all fields', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      // Fill professional name (required)
      final professionalField = find.text('Nome do profissional');
      // Use the TextField itself
      await tester.enterText(
          find.widgetWithText(AppTextField, 'Nome do profissional'),
          'Dr. João');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(
          find.text('Consulta registrada com sucesso!'), findsOneWidget);
    });

    testWidgets('shows error snackbar on failure', (tester) async {
      final mockRepo = MockEventRepository()
        ..createError = Exception('Erro ao registrar consulta');

      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      // Fill required professional name first
      await tester.enterText(
          find.widgetWithText(AppTextField, 'Nome do profissional'),
          'Dr. João');

      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(
          find.text('Exception: Erro ao registrar consulta'), findsOneWidget);
    });

    testWidgets('appointment type dropdown has routine and urgent', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      await tester.tap(find.text('Rotina'));
      await tester.pumpAndSettle();

      expect(find.text('Urgente'), findsOneWidget);
    });

    testWidgets('renders in lilac theme', (tester) async {
      final mockRepo = MockEventRepository();
      await tester.pumpWidget(wrapAppointmentScreen(mockRepo: mockRepo));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.lilacDark);
      expect(appBar.foregroundColor, AppColors.white);
    });
  });
}
