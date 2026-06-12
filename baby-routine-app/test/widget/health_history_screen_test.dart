import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/features/health/controllers/health_controller.dart';
import 'package:baby_routine_app/features/health/models/health_record.dart';
import 'package:baby_routine_app/features/health/presentation/health_history_screen.dart';
import 'package:baby_routine_app/features/health/repositories/health_repository.dart';
import 'package:baby_routine_app/shared/providers/selected_baby_provider.dart';

class MockHealthRepository implements HealthRepository {
  List<HealthRecord> listResult = [];
  Object? listError;

  @override
  Future<List<HealthRecord>> list(String babyId, {String? type}) async {
    if (listError != null) throw listError!;
    return listResult;
  }
}

final _testBaby = Baby(
  id: 'baby-001',
  name: 'Lucas',
  birthDate: DateTime.parse('2025-01-15'),
  gender: 'male',
  currentUserRole: 'owner',
);

final _testRecords = [
  HealthRecord(
    id: 'h1',
    babyId: 'baby-001',
    userId: 'user-1',
    recordType: 'appointment',
    title: 'Consulta pediatra',
    description: 'Dr. Silva — Rotina',
    occurredAt: DateTime.parse('2026-06-10T10:00:00'),
    createdAt: DateTime.now(),
  ),
  HealthRecord(
    id: 'h2',
    babyId: 'baby-001',
    userId: 'user-1',
    recordType: 'vaccination',
    title: 'Pentavalente',
    description: '2ª dose',
    occurredAt: DateTime.parse('2026-06-05T14:00:00'),
    createdAt: DateTime.now(),
  ),
  HealthRecord(
    id: 'h3',
    babyId: 'baby-001',
    userId: 'user-1',
    recordType: 'medication',
    title: 'Dipirona',
    description: 'Febre — 5ml',
    occurredAt: DateTime.parse('2026-06-08T08:00:00'),
    createdAt: DateTime.now(),
  ),
  HealthRecord(
    id: 'h4',
    babyId: 'baby-001',
    userId: 'user-1',
    recordType: 'exam',
    title: 'Hemograma',
    description: 'Jejum 8h',
    occurredAt: DateTime.parse('2026-06-03T07:00:00'),
    createdAt: DateTime.now(),
  ),
];

Widget wrapHealthHistoryScreen({MockHealthRepository? mockRepo}) {
  return ProviderScope(
    overrides: [
      if (mockRepo != null)
        healthRepositoryProvider.overrideWithValue(mockRepo),
      selectedBabyProvider.overrideWithValue(_testBaby),
    ],
    child: const MaterialApp(
      home: HealthHistoryScreen(),
    ),
  );
}

void main() {
  group('HealthHistoryScreen', () {
    testWidgets('shows app bar title in pt-BR', (tester) async {
      final mockRepo = MockHealthRepository();
      await tester.pumpWidget(wrapHealthHistoryScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Histórico de Saúde'), findsOneWidget);
    });

    testWidgets('shows filter chips', (tester) async {
      final mockRepo = MockHealthRepository();
      await tester.pumpWidget(wrapHealthHistoryScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Consulta'), findsOneWidget);
      expect(find.text('Vacina'), findsOneWidget);
      expect(find.text('Medicamento'), findsOneWidget);
      expect(find.text('Exame'), findsOneWidget);
    });

    testWidgets('shows health records', (tester) async {
      final mockRepo = MockHealthRepository()
        ..listResult = _testRecords;

      await tester.pumpWidget(wrapHealthHistoryScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Consulta pediatra'), findsOneWidget);
      expect(find.text('Pentavalente'), findsOneWidget);
      expect(find.text('Dipirona'), findsOneWidget);
      expect(find.text('Hemograma'), findsOneWidget);
    });

    testWidgets('shows record dates', (tester) async {
      final mockRepo = MockHealthRepository()
        ..listResult = _testRecords;

      await tester.pumpWidget(wrapHealthHistoryScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('10/06/2026'), findsOneWidget);
      expect(find.text('05/06/2026'), findsOneWidget);
    });

    testWidgets('shows translated type names', (tester) async {
      final mockRepo = MockHealthRepository()
        ..listResult = _testRecords;

      await tester.pumpWidget(wrapHealthHistoryScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Consulta'), findsWidgets);
      expect(find.text('Vacina'), findsWidgets);
      expect(find.text('Medicamento'), findsWidgets);
      expect(find.text('Exame'), findsWidgets);
    });

    testWidgets('shows empty state when no records', (tester) async {
      final mockRepo = MockHealthRepository()
        ..listResult = [];

      await tester.pumpWidget(wrapHealthHistoryScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum registro encontrado'), findsOneWidget);
    });

    testWidgets('shows error state on load failure', (tester) async {
      final mockRepo = MockHealthRepository()
        ..listError = Exception('Erro de rede');

      await tester.pumpWidget(wrapHealthHistoryScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Erro ao carregar histórico de saúde'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      final mockRepo = MockHealthRepository();
      await tester.pumpWidget(wrapHealthHistoryScreen(mockRepo: mockRepo));
      // State is initially loading before data arrives
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('supports pull to refresh', (tester) async {
      final mockRepo = MockHealthRepository()
        ..listResult = _testRecords;

      await tester.pumpWidget(wrapHealthHistoryScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('uses correct icons for record types', (tester) async {
      final mockRepo = MockHealthRepository()
        ..listResult = _testRecords;

      await tester.pumpWidget(wrapHealthHistoryScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.medical_services), findsOneWidget);
      expect(find.byIcon(Icons.vaccines), findsOneWidget);
      expect(find.byIcon(Icons.medication), findsOneWidget);
      expect(find.byIcon(Icons.biotech), findsOneWidget);
    });
  });
}
