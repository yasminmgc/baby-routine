import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:baby_routine_app/features/home/presentation/home_screen.dart';
import 'package:baby_routine_app/features/home/controllers/checklist_controller.dart';
import 'package:baby_routine_app/features/home/repositories/checklist_repository.dart';
import 'package:baby_routine_app/features/home/models/checklist_item.dart';
import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/shared/providers/selected_baby_provider.dart';
import 'package:baby_routine_app/core/constants/app_colors.dart';

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
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => child,
            ),
            GoRoute(
              path: '/feeding',
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Feeding'))),
            ),
            GoRoute(
              path: '/sleep',
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Sleep'))),
            ),
            GoRoute(
              path: '/diaper',
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Diaper'))),
            ),
            GoRoute(
              path: '/bath',
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Bath'))),
            ),
            GoRoute(
              path: '/appointment',
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Appointment'))),
            ),
            GoRoute(
              path: '/vaccination',
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Vaccination'))),
            ),
            GoRoute(
              path: '/medication',
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Medication'))),
            ),
            GoRoute(
              path: '/routines',
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Routines'))),
            ),
            GoRoute(
              path: '/health',
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Health'))),
            ),
            GoRoute(
              path: '/reports',
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Reports'))),
            ),
            GoRoute(
              path: '/notes',
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Notes'))),
            ),
            GoRoute(
              path: '/caregivers',
              builder: (_, __) =>
                  const Scaffold(body: Center(child: Text('Caregivers'))),
            ),
          ],
        ),
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('displays baby name in AppBar', (tester) async {
      final mockRepo = MockChecklistRepository();
      await tester.pumpWidget(wrapWithProviders(
        const HomeScreen(),
        mockRepo: mockRepo,
        babyName: 'Lucas',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Olá, Lucas'), findsOneWidget);
    });

    testWidgets('displays baby name for different baby', (tester) async {
      final mockRepo = MockChecklistRepository();
      await tester.pumpWidget(wrapWithProviders(
        const HomeScreen(),
        mockRepo: mockRepo,
        babyName: 'Ana Júlia',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Olá, Ana Júlia'), findsOneWidget);
    });

    testWidgets('shows all 7 quick action buttons', (tester) async {
      final mockRepo = MockChecklistRepository();
      await tester.pumpWidget(wrapWithProviders(
        const HomeScreen(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Mamadeira'), findsOneWidget);
      expect(find.text('Sono'), findsOneWidget);
      expect(find.text('Fralda'), findsOneWidget);
      expect(find.text('Banho'), findsOneWidget);
      expect(find.text('Vacina'), findsOneWidget);
      expect(find.text('Consulta'), findsOneWidget);
      expect(find.text('Medicação'), findsOneWidget);
    });

    testWidgets('quick action icons are present', (tester) async {
      final mockRepo = MockChecklistRepository();
      await tester.pumpWidget(wrapWithProviders(
        const HomeScreen(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.breakfast_dining), findsOneWidget);
      expect(find.byIcon(Icons.bedtime), findsOneWidget);
      expect(find.byIcon(Icons.baby_changing_station), findsOneWidget);
      expect(find.byIcon(Icons.bathtub), findsOneWidget);
      expect(find.byIcon(Icons.vaccines), findsOneWidget);
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
      expect(find.byIcon(Icons.medication), findsOneWidget);
    });

    testWidgets('navigation labels are shown', (tester) async {
      final mockRepo = MockChecklistRepository();
      await tester.pumpWidget(wrapWithProviders(
        const HomeScreen(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Rotinas'), findsWidgets);
      expect(find.text('Histórico'), findsOneWidget);
      expect(find.text('Relatórios'), findsWidgets); // in nav bar AND bottom nav
      expect(find.text('Anotações'), findsOneWidget);
      expect(find.text('Cuidadores'), findsWidgets);
    });

    testWidgets('navigation icons are present', (tester) async {
      final mockRepo = MockChecklistRepository();
      await tester.pumpWidget(wrapWithProviders(
        const HomeScreen(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.repeat), findsWidgets);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsWidgets);
      expect(find.byIcon(Icons.note_alt), findsOneWidget);
      expect(find.byIcon(Icons.people), findsWidgets);
    });

    testWidgets('bottom navigation has Início selected', (tester) async {
      final mockRepo = MockChecklistRepository();
      await tester.pumpWidget(wrapWithProviders(
        const HomeScreen(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      // "Início" label should be present in bottom nav
      expect(find.text('Início'), findsOneWidget);
    });

    testWidgets('uses lilacDark for AppBar', (tester) async {
      final mockRepo = MockChecklistRepository();
      await tester.pumpWidget(wrapWithProviders(
        const HomeScreen(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.lilacDark);
      expect(appBar.foregroundColor, AppColors.white);
    });

    testWidgets('checklist widget is embedded', (tester) async {
      final mockRepo = MockChecklistRepository()
        ..result = ChecklistResponse(
          date: '2026-06-12',
          items: const [
            ChecklistItem(
              type: 'routine',
              routineId: 'r1',
              activityType: 'feeding',
              scheduledTime: '08:00',
              status: 'pending',
            ),
          ],
        );

      await tester.pumpWidget(wrapWithProviders(
        const HomeScreen(),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      // The checklist item should be visible within the home screen
      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
    });
  });
}
