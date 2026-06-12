import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/babies/presentation/caregivers_screen.dart';
import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/features/babies/repositories/baby_repository.dart';
import 'package:baby_routine_app/features/babies/controllers/baby_controller.dart';
import 'package:baby_routine_app/shared/providers/selected_baby_provider.dart';

class MockBabyRepository implements BabyRepository {
  List<Caregiver>? caregiversResult;
  Object? errorToThrow;

  @override
  Future<List<Caregiver>> listCaregivers(String babyId) async {
    if (errorToThrow != null) throw errorToThrow!;
    return caregiversResult ?? [];
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  final ownerBaby = Baby(
    id: 'baby-1',
    name: 'Lucas',
    birthDate: DateTime.parse('2025-01-15'),
    currentUserRole: 'owner',
  );

  final caregiverBaby = Baby(
    id: 'baby-1',
    name: 'Lucas',
    birthDate: DateTime.parse('2025-01-15'),
    currentUserRole: 'caregiver',
  );

  Widget wrapWithProviders(Widget child,
      {MockBabyRepository? mockRepo, Baby? selectedBaby}) {
    return ProviderScope(
      overrides: [
        if (mockRepo != null)
          babyRepositoryProvider.overrideWithValue(mockRepo),
        if (selectedBaby != null)
          selectedBabyProvider.overrideWithValue(selectedBaby),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('CaregiversScreen', () {
    testWidgets('lists caregivers with names and roles', (tester) async {
      final mockRepo = MockBabyRepository()
        ..caregiversResult = [
          Caregiver(
            id: 'usr-1',
            name: 'Maria Silva',
            email: 'maria@example.com',
            role: 'owner',
          ),
          Caregiver(
            id: 'usr-2',
            name: 'João Souza',
            email: 'joao@example.com',
            role: 'caregiver',
          ),
        ];

      await tester.pumpWidget(wrapWithProviders(
        const CaregiversScreen(),
        mockRepo: mockRepo,
        selectedBaby: ownerBaby,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Maria Silva'), findsOneWidget);
      expect(find.text('João Souza'), findsOneWidget);
      expect(find.text('Responsável'), findsOneWidget);
      expect(find.text('Cuidador(a)'), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      final mockRepo = MockBabyRepository()..caregiversResult = [];

      await tester.pumpWidget(wrapWithProviders(
        const CaregiversScreen(),
        mockRepo: mockRepo,
        selectedBaby: ownerBaby,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum cuidador'), findsOneWidget);
    });

    testWidgets('shows app bar title in pt-BR', (tester) async {
      final mockRepo = MockBabyRepository()..caregiversResult = [];

      await tester.pumpWidget(wrapWithProviders(
        const CaregiversScreen(),
        mockRepo: mockRepo,
        selectedBaby: ownerBaby,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Cuidadores'), findsOneWidget);
    });

    testWidgets('owner can see add caregiver FAB', (tester) async {
      final mockRepo = MockBabyRepository()..caregiversResult = [];

      await tester.pumpWidget(wrapWithProviders(
        const CaregiversScreen(),
        mockRepo: mockRepo,
        selectedBaby: ownerBaby,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('caregiver cannot see add FAB', (tester) async {
      final mockRepo = MockBabyRepository()..caregiversResult = [];

      await tester.pumpWidget(wrapWithProviders(
        const CaregiversScreen(),
        mockRepo: mockRepo,
        selectedBaby: caregiverBaby,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_add), findsNothing);
    });

    testWidgets('owner sees remove button for non-owner caregivers',
        (tester) async {
      final mockRepo = MockBabyRepository()
        ..caregiversResult = [
          Caregiver(
            id: 'usr-1',
            name: 'Maria',
            email: 'maria@example.com',
            role: 'owner',
          ),
          Caregiver(
            id: 'usr-2',
            name: 'João',
            email: 'joao@example.com',
            role: 'caregiver',
          ),
        ];

      await tester.pumpWidget(wrapWithProviders(
        const CaregiversScreen(),
        mockRepo: mockRepo,
        selectedBaby: ownerBaby,
      ));
      await tester.pumpAndSettle();

      // Remove button should appear for the non-owner caregiver
      expect(find.byIcon(Icons.remove_circle), findsOneWidget);
    });

    testWidgets('shows add caregiver dialog on FAB tap', (tester) async {
      final mockRepo = MockBabyRepository()..caregiversResult = [];

      await tester.pumpWidget(wrapWithProviders(
        const CaregiversScreen(),
        mockRepo: mockRepo,
        selectedBaby: ownerBaby,
      ));
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.byIcon(Icons.person_add));
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text('Adicionar cuidador'), findsOneWidget);
      expect(find.text('E-mail do cuidador'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });
  });
}
