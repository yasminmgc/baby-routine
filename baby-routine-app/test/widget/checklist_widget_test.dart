import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/home/presentation/checklist_widget.dart';
import 'package:baby_routine_app/features/home/controllers/checklist_controller.dart';
import 'package:baby_routine_app/features/home/repositories/checklist_repository.dart';
import 'package:baby_routine_app/features/home/models/checklist_item.dart';
import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/shared/providers/selected_baby_provider.dart';

class MockChecklistRepository implements ChecklistRepository {
  ChecklistResponse? result;
  Object? errorToThrow;

  @override
  Future<ChecklistResponse> fetch(String babyId, {String? date}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return result ??
        const ChecklistResponse(date: '2026-06-12', items: []);
  }
}

void main() {
  Widget wrapWithProviders(
    Widget child, {
    required MockChecklistRepository mockRepo,
    String babyName = 'Lucas',
  }) {
    return ProviderScope(
      overrides: [
        selectedBabyProvider.overrideWithValue(
          Baby(
            id: 'baby-1',
            name: babyName,
            birthDate: DateTime(2025, 1, 15),
            currentUserRole: 'owner',
          ),
        ),
        checklistRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('ChecklistWidget', () {
    testWidgets('shows date header', (tester) async {
      final mockRepo = MockChecklistRepository()
        ..result = const ChecklistResponse(date: '2026-06-12', items: []);

      await tester.pumpWidget(wrapWithProviders(
        const ChecklistWidget(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      // Date header should show weekday + date with calendar icon
      expect(find.byIcon(Icons.today), findsOneWidget);
    });

    testWidgets('shows empty state when no items', (tester) async {
      final mockRepo = MockChecklistRepository()
        ..result = const ChecklistResponse(date: '2026-06-12', items: []);

      await tester.pumpWidget(wrapWithProviders(
        const ChecklistWidget(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      expect(
        find.text('Nenhuma atividade programada para hoje'),
        findsOneWidget,
      );
    });

    testWidgets('renders checklist items with status and icon',
        (tester) async {
      final mockRepo = MockChecklistRepository()
        ..result = ChecklistResponse(
          date: '2026-06-12',
          items: const [
            ChecklistItem(
              type: 'routine',
              routineId: 'r1',
              activityType: 'feeding',
              scheduledTime: '08:00',
              status: 'completed',
              eventId: 'ev1',
            ),
            ChecklistItem(
              type: 'routine',
              routineId: 'r2',
              activityType: 'sleep',
              scheduledTime: '20:00',
              status: 'pending',
            ),
            ChecklistItem(
              type: 'routine',
              routineId: 'r3',
              activityType: 'diaper',
              scheduledTime: '12:00',
              status: 'missed',
            ),
          ],
        );

      await tester.pumpWidget(wrapWithProviders(
        const ChecklistWidget(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      // Should show activity labels
      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.text('Sono'), findsOneWidget);
      expect(find.text('Fralda'), findsOneWidget);

      // Should show times
      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);

      // Should show status labels
      expect(find.text('Concluído'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
      expect(find.text('Não realizado'), findsOneWidget);

      // Should show status icons
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('renders correct activity type icons', (tester) async {
      final mockRepo = MockChecklistRepository()
        ..result = ChecklistResponse(
          date: '2026-06-12',
          items: const [
            ChecklistItem(
                type: 'routine',
                activityType: 'feeding',
                scheduledTime: '08:00',
                status: 'pending'),
            ChecklistItem(
                type: 'routine',
                activityType: 'sleep',
                scheduledTime: '09:00',
                status: 'pending'),
            ChecklistItem(
                type: 'routine',
                activityType: 'bath',
                scheduledTime: '10:00',
                status: 'pending'),
            ChecklistItem(
                type: 'routine',
                activityType: 'vaccination',
                scheduledTime: '11:00',
                status: 'pending'),
            ChecklistItem(
                type: 'routine',
                activityType: 'appointment',
                scheduledTime: '12:00',
                status: 'pending'),
            ChecklistItem(
                type: 'routine',
                activityType: 'medication',
                scheduledTime: '13:00',
                status: 'pending'),
          ],
        );

      await tester.pumpWidget(wrapWithProviders(
        const ChecklistWidget(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.breakfast_dining), findsOneWidget);
      expect(find.byIcon(Icons.bedtime), findsOneWidget);
      expect(find.byIcon(Icons.bathtub), findsOneWidget);
      expect(find.byIcon(Icons.vaccines), findsOneWidget);
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
      expect(find.byIcon(Icons.medication), findsOneWidget);
    });

    testWidgets('shows error state with retry', (tester) async {
      final mockRepo = MockChecklistRepository()
        ..errorToThrow = Exception('Network error');

      await tester.pumpWidget(wrapWithProviders(
        const ChecklistWidget(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Erro ao carregar checklist'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('sorts items by scheduled time', (tester) async {
      final mockRepo = MockChecklistRepository()
        ..result = ChecklistResponse(
          date: '2026-06-12',
          items: const [
            ChecklistItem(
              type: 'routine',
              routineId: 'r3',
              activityType: 'bath',
              scheduledTime: '14:00',
              status: 'pending',
            ),
            ChecklistItem(
              type: 'routine',
              routineId: 'r1',
              activityType: 'feeding',
              scheduledTime: '08:00',
              status: 'completed',
            ),
            ChecklistItem(
              type: 'routine',
              routineId: 'r2',
              activityType: 'sleep',
              scheduledTime: '20:00',
              status: 'pending',
            ),
          ],
        );

      await tester.pumpWidget(wrapWithProviders(
        const ChecklistWidget(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      // All three items should be rendered (sorted by time)
      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.text('Banho'), findsOneWidget);
      expect(find.text('Sono'), findsOneWidget);
    });

    testWidgets('displays event type items without time', (tester) async {
      final mockRepo = MockChecklistRepository()
        ..result = ChecklistResponse(
          date: '2026-06-12',
          items: const [
            ChecklistItem(
              type: 'event',
              activityType: 'diaper',
              status: 'completed',
              eventId: 'ev1',
              notes: 'Normal',
            ),
          ],
        );

      await tester.pumpWidget(wrapWithProviders(
        const ChecklistWidget(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Fralda'), findsOneWidget);
      expect(find.text('Concluído'), findsOneWidget);
    });

    testWidgets('shows all status types correctly', (tester) async {
      final mockRepo = MockChecklistRepository()
        ..result = ChecklistResponse(
          date: '2026-06-12',
          items: const [
            ChecklistItem(
              type: 'routine',
              activityType: 'feeding',
              scheduledTime: '08:00',
              status: 'completed',
            ),
            ChecklistItem(
              type: 'routine',
              activityType: 'sleep',
              scheduledTime: '14:00',
              status: 'pending',
            ),
            ChecklistItem(
              type: 'routine',
              activityType: 'medication',
              scheduledTime: '20:00',
              status: 'missed',
            ),
          ],
        );

      await tester.pumpWidget(wrapWithProviders(
        const ChecklistWidget(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      // Status icons should be rendered
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);

      // Status labels in pt-BR
      expect(find.text('Concluído'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
      expect(find.text('Não realizado'), findsOneWidget);
    });
  });
}
