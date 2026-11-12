import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/features/routines/controllers/routine_controller.dart';
import 'package:baby_routine_app/features/routines/models/routine.dart';
import 'package:baby_routine_app/features/routines/presentation/configure_routines_screen.dart';
import 'package:baby_routine_app/features/routines/repositories/routine_repository.dart';
import 'package:baby_routine_app/shared/providers/selected_baby_provider.dart';

class MockRoutineRepository implements RoutineRepository {
  List<Routine> listResult = [];
  Object? listError;
  Routine? toggleResult;
  Object? toggleError;
  Routine? createResult;
  Object? createError;
  Routine? updateResult;
  Object? updateError;
  Object? deleteError;

  @override
  Future<Routine> create({
    required String babyId,
    required String activityType,
    int? intervalMinutes,
    String? defaultStartTime,
  }) async {
    if (createError != null) throw createError!;
    return createResult ??
        Routine(
          id: 'new-routine',
          babyId: babyId,
          activityType: activityType,
          intervalMinutes: intervalMinutes,
          defaultStartTime: defaultStartTime,
          active: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }

  @override
  Future<List<Routine>> list(String babyId) async {
    if (listError != null) throw listError!;
    return listResult;
  }

  @override
  Future<Routine> update(
    String babyId,
    String routineId, {
    String? activityType,
    int? intervalMinutes,
    String? defaultStartTime,
  }) async {
    if (updateError != null) throw updateError!;
    return updateResult ??
        Routine(
          id: routineId,
          babyId: babyId,
          activityType: activityType ?? 'Sono',
          intervalMinutes: intervalMinutes,
          defaultStartTime: defaultStartTime,
          active: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }

  @override
  Future<void> delete(String babyId, String routineId) async {
    if (deleteError != null) throw deleteError!;
  }

  @override
  Future<Routine> toggle(String babyId, String routineId, bool active) async {
    if (toggleError != null) throw toggleError!;
    return toggleResult ??
        Routine(
          id: routineId,
          babyId: babyId,
          activityType: 'Sono',
          active: active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }
}

final _testBaby = Baby(
  id: 'baby-001',
  name: 'Lucas',
  birthDate: DateTime.parse('2025-01-15'),
  gender: 'male',
  currentUserRole: 'owner',
);

final _testRoutines = [
  Routine(
    id: 'r1',
    babyId: 'baby-001',
    activityType: 'Sono',
    intervalMinutes: 120,
    defaultStartTime: '20:00',
    active: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Routine(
    id: 'r2',
    babyId: 'baby-001',
    activityType: 'Alimentação',
    intervalMinutes: 180,
    defaultStartTime: '08:00',
    active: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

Widget wrapConfigureRoutinesScreen({MockRoutineRepository? mockRepo}) {
  return ProviderScope(
    overrides: [
      if (mockRepo != null)
        routineRepositoryProvider.overrideWithValue(mockRepo),
      selectedBabyProvider.overrideWithValue(_testBaby),
    ],
    child: const MaterialApp(
      home: ConfigureRoutinesScreen(),
    ),
  );
}

void main() {
  group('ConfigureRoutinesScreen', () {
    testWidgets('shows app bar title in pt-BR', (tester) async {
      final mockRepo = MockRoutineRepository();
      await tester.pumpWidget(wrapConfigureRoutinesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Rotinas'), findsOneWidget);
    });

    testWidgets('shows routines list', (tester) async {
      final mockRepo = MockRoutineRepository()
        ..listResult = _testRoutines;

      await tester.pumpWidget(wrapConfigureRoutinesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Sono'), findsOneWidget);
      expect(find.text('Alimentação'), findsOneWidget);
    });

    testWidgets('shows routine details (time and interval)', (tester) async {
      final mockRepo = MockRoutineRepository()
        ..listResult = _testRoutines;

      await tester.pumpWidget(wrapConfigureRoutinesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('20:00 • a cada 120 min'), findsOneWidget);
      expect(find.text('08:00 • a cada 180 min'), findsOneWidget);
    });

    testWidgets('shows toggle switches', (tester) async {
      final mockRepo = MockRoutineRepository()
        ..listResult = _testRoutines;

      await tester.pumpWidget(wrapConfigureRoutinesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Should have 2 switches
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('shows empty state when no routines', (tester) async {
      final mockRepo = MockRoutineRepository()
        ..listResult = [];

      await tester.pumpWidget(wrapConfigureRoutinesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma rotina configurada'), findsOneWidget);
    });

    testWidgets('shows edit and delete icons', (tester) async {
      final mockRepo = MockRoutineRepository()
        ..listResult = _testRoutines;

      await tester.pumpWidget(wrapConfigureRoutinesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsWidgets);
      expect(find.byIcon(Icons.delete), findsWidgets);
    });

    testWidgets('shows FAB to add new routine', (tester) async {
      final mockRepo = MockRoutineRepository()
        ..listResult = _testRoutines;

      await tester.pumpWidget(wrapConfigureRoutinesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows error state on load failure', (tester) async {
      final mockRepo = MockRoutineRepository()
        ..listError = Exception('Erro de rede');

      await tester.pumpWidget(wrapConfigureRoutinesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Erro ao carregar rotinas'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('supports pull to refresh', (tester) async {
      final mockRepo = MockRoutineRepository()
        ..listResult = _testRoutines;

      await tester.pumpWidget(wrapConfigureRoutinesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('FAB opens add dialog', (tester) async {
      final mockRepo = MockRoutineRepository()
        ..listResult = _testRoutines;

      await tester.pumpWidget(wrapConfigureRoutinesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Nova rotina'), findsOneWidget);
      expect(find.text('Criar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('delete shows confirmation dialog', (tester) async {
      final mockRepo = MockRoutineRepository()
        ..listResult = _testRoutines;

      await tester.pumpWidget(wrapConfigureRoutinesScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Tap delete icon on first routine
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      expect(find.text('Excluir rotina'), findsOneWidget);
      expect(find.text('Tem certeza que deseja excluir esta rotina?'),
          findsOneWidget);
    });
  });
}
