import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/features/reports/controllers/report_controller.dart';
import 'package:baby_routine_app/features/reports/models/report_data.dart';
import 'package:baby_routine_app/features/reports/presentation/reports_screen.dart';
import 'package:baby_routine_app/features/reports/repositories/report_repository.dart';
import 'package:baby_routine_app/shared/providers/selected_baby_provider.dart';

class MockReportRepository implements ReportRepository {
  List<SleepReportItem> sleepResult = [];
  Object? sleepError;
  List<FeedingReportItem> feedingResult = [];
  Object? feedingError;
  List<DiapersReportItem> diapersResult = [];
  Object? diapersError;
  List<GrowthReportItem> growthResult = [];
  Object? growthError;
  List<MedicationReportItem> medicationResult = [];
  Object? medicationError;

  @override
  Future<List<SleepReportItem>> getSleepReport(
    String babyId, {
    String? startDate,
    String? endDate,
  }) async {
    if (sleepError != null) throw sleepError!;
    return sleepResult;
  }

  @override
  Future<List<FeedingReportItem>> getFeedingReport(
    String babyId, {
    String? startDate,
    String? endDate,
  }) async {
    if (feedingError != null) throw feedingError!;
    return feedingResult;
  }

  @override
  Future<List<DiapersReportItem>> getDiapersReport(
    String babyId, {
    String? startDate,
    String? endDate,
  }) async {
    if (diapersError != null) throw diapersError!;
    return diapersResult;
  }

  @override
  Future<List<GrowthReportItem>> getGrowthReport(
    String babyId, {
    String? startDate,
    String? endDate,
  }) async {
    if (growthError != null) throw growthError!;
    return growthResult;
  }

  @override
  Future<List<MedicationReportItem>> getMedicationReport(
    String babyId, {
    String? startDate,
    String? endDate,
  }) async {
    if (medicationError != null) throw medicationError!;
    return medicationResult;
  }
}

final _testBaby = Baby(
  id: 'baby-001',
  name: 'Lucas',
  birthDate: DateTime.parse('2025-01-15'),
  gender: 'male',
  currentUserRole: 'owner',
);

final _testSleepData = [
  SleepReportItem(
    date: '2026-06-10',
    totalDurationMin: 480.0,
    eventsCount: 2,
  ),
  SleepReportItem(
    date: '2026-06-11',
    totalDurationMin: 600.0,
    eventsCount: 2,
  ),
];

final _testFeedingData = [
  FeedingReportItem(
    date: '2026-06-10',
    bottle: 4,
    breast: 2,
    solids: 1,
  ),
  FeedingReportItem(
    date: '2026-06-11',
    bottle: 3,
    breast: 3,
    solids: 2,
  ),
];

final _testDiapersData = [
  DiapersReportItem(
    date: '2026-06-10',
    pee: 5,
    poop: 2,
    both: 1,
  ),
  DiapersReportItem(
    date: '2026-06-11',
    pee: 4,
    poop: 1,
    both: 2,
  ),
];

final _testGrowthData = [
  GrowthReportItem(
    id: 'g1',
    measuredAt: DateTime.parse('2026-06-10T10:00:00'),
    weightKg: 4.5,
    heightCm: 55.0,
    headCircumferenceCm: 38.0,
  ),
  GrowthReportItem(
    id: 'g2',
    measuredAt: DateTime.parse('2026-06-11T10:00:00'),
    weightKg: 4.7,
    heightCm: 55.5,
    headCircumferenceCm: 38.2,
  ),
];

final _testMedicationData = [
  MedicationReportItem(
    id: 'm1',
    medicationName: 'Dipirona',
    dose: '5ml',
    reason: 'Febre',
    occurredAt: DateTime.parse('2026-06-10T14:00:00'),
  ),
  MedicationReportItem(
    id: 'm2',
    medicationName: 'Paracetamol',
    dose: '3ml',
    reason: 'Dor',
    notes: 'Após vacina',
    occurredAt: DateTime.parse('2026-06-11T20:00:00'),
  ),
];

Widget wrapReportsScreen({MockReportRepository? mockRepo}) {
  return ProviderScope(
    overrides: [
      if (mockRepo != null)
        reportRepositoryProvider.overrideWithValue(mockRepo),
      selectedBabyProvider.overrideWithValue(_testBaby),
    ],
    child: const MaterialApp(
      home: ReportsScreen(),
    ),
  );
}

void main() {
  group('ReportsScreen', () {
    testWidgets('shows app bar title in pt-BR', (tester) async {
      final mockRepo = MockReportRepository();
      await tester.pumpWidget(wrapReportsScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Relatórios'), findsOneWidget);
    });

    testWidgets('shows all 5 report type chips', (tester) async {
      final mockRepo = MockReportRepository();
      await tester.pumpWidget(wrapReportsScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Sono'), findsOneWidget);
      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.text('Fraldas'), findsOneWidget);
      expect(find.text('Crescimento'), findsOneWidget);
      expect(find.text('Medicação'), findsOneWidget);
    });

    testWidgets('shows date range picker button', (tester) async {
      final mockRepo = MockReportRepository();
      await tester.pumpWidget(wrapReportsScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Selecionar período'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('shows sleep bar chart title', (tester) async {
      final mockRepo = MockReportRepository()
        ..sleepResult = _testSleepData;

      await tester.pumpWidget(wrapReportsScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Duração do sono por dia (horas)'), findsOneWidget);
    });

    testWidgets('shows feeding chart with legend', (tester) async {
      final mockRepo = MockReportRepository()
        ..feedingResult = _testFeedingData;

      // Select feeding first
      await tester.pumpWidget(wrapReportsScreen(mockRepo: mockRepo));
      // Tap feeding chip
      await tester.tap(find.text('Alimentação'));
      await tester.pumpAndSettle();

      expect(find.text('Alimentações por dia (quantidade)'), findsOneWidget);
      expect(find.text('Mamadeira'), findsOneWidget);
      expect(find.text('Peito'), findsOneWidget);
      expect(find.text('Sólidos'), findsOneWidget);
    });

    testWidgets('shows diapers chart with legend', (tester) async {
      final mockRepo = MockReportRepository()
        ..diapersResult = _testDiapersData;

      await tester.pumpWidget(wrapReportsScreen(mockRepo: mockRepo));
      // Tap diapers chip
      await tester.tap(find.text('Fraldas'));
      await tester.pumpAndSettle();

      expect(find.text('Trocas de fralda por dia (quantidade)'), findsOneWidget);
      expect(find.text('Xixi'), findsOneWidget);
      expect(find.text('Cocô'), findsOneWidget);
      expect(find.text('Ambos'), findsOneWidget);
    });

    testWidgets('shows growth line chart title', (tester) async {
      final mockRepo = MockReportRepository()
        ..growthResult = _testGrowthData;

      await tester.pumpWidget(wrapReportsScreen(mockRepo: mockRepo));
      // Tap growth chip
      await tester.tap(find.text('Crescimento'));
      await tester.pumpAndSettle();

      expect(find.text('Curva de Peso (kg)'), findsOneWidget);
    });

    testWidgets('shows medication as list', (tester) async {
      final mockRepo = MockReportRepository()
        ..medicationResult = _testMedicationData;

      await tester.pumpWidget(wrapReportsScreen(mockRepo: mockRepo));
      // Tap medication chip
      await tester.tap(find.text('Medicação'));
      await tester.pumpAndSettle();

      expect(find.text('Dipirona'), findsOneWidget);
      expect(find.text('Paracetamol'), findsOneWidget);
    });

    testWidgets('shows medication details in list', (tester) async {
      final mockRepo = MockReportRepository()
        ..medicationResult = _testMedicationData;

      await tester.pumpWidget(wrapReportsScreen(mockRepo: mockRepo));
      await tester.tap(find.text('Medicação'));
      await tester.pumpAndSettle();

      expect(find.text('Dose: 5ml • Motivo: Febre • 10/06/2026'),
          findsOneWidget);
    });

    testWidgets('shows empty state for sleep', (tester) async {
      final mockRepo = MockReportRepository()
        ..sleepResult = [];

      await tester.pumpWidget(wrapReportsScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum dado disponível'), findsOneWidget);
    });

    testWidgets('shows error state', (tester) async {
      final mockRepo = MockReportRepository()
        ..sleepError = Exception('Erro de rede');

      await tester.pumpWidget(wrapReportsScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Erro ao carregar relatório'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      final mockRepo = MockReportRepository();
      await tester.pumpWidget(wrapReportsScreen(mockRepo: mockRepo));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
