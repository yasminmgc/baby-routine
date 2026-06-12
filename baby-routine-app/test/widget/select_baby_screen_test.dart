import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/babies/presentation/select_baby_screen.dart';
import 'package:baby_routine_app/features/babies/repositories/baby_repository.dart';
import 'package:baby_routine_app/features/babies/controllers/baby_controller.dart';
import 'package:baby_routine_app/features/babies/models/baby.dart';

class MockBabyRepository implements BabyRepository {
  List<Baby>? babiesResult;
  Object? errorToThrow;

  @override
  Future<List<Baby>> list() async {
    if (errorToThrow != null) throw errorToThrow!;
    return babiesResult ?? [];
  }

  @override
  Future<Baby> create(
      {required String name,
      required DateTime birthDate,
      String? gender,
      double? initialWeightKg,
      double? initialHeightCm,
      String? allergies}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Baby> getById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Baby> update(String id,
      {String? name,
      DateTime? birthDate,
      String? gender,
      double? initialWeightKg,
      double? initialHeightCm,
      String? allergies}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> addCaregiver(String babyId, String email) async {
    throw UnimplementedError();
  }

  @override
  Future<void> removeCaregiver(String babyId, String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Caregiver>> listCaregivers(String babyId) async {
    throw UnimplementedError();
  }
}

void main() {
  Widget wrapWithProviders(Widget child, {MockBabyRepository? mockRepo}) {
    return ProviderScope(
      overrides: [
        if (mockRepo != null)
          babyRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('SelectBabyScreen', () {
    testWidgets('shows empty state when no babies', (tester) async {
      final mockRepo = MockBabyRepository()..babiesResult = [];
      await tester.pumpWidget(
          wrapWithProviders(const SelectBabyScreen(), mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum bebê cadastrado'), findsOneWidget);
      expect(
        find.text('Toque no botão + para adicionar seu primeiro bebê'),
        findsOneWidget,
      );
    });

    testWidgets('lists babies with name and role', (tester) async {
      final mockRepo = MockBabyRepository()
        ..babiesResult = [
          Baby(
            id: '1',
            name: 'Lucas',
            birthDate: DateTime.parse('2025-01-15'),
            gender: 'male',
            currentUserRole: 'owner',
          ),
          Baby(
            id: '2',
            name: 'Ana',
            birthDate: DateTime.parse('2025-03-20'),
            gender: 'female',
            currentUserRole: 'caregiver',
          ),
        ];

      await tester.pumpWidget(
          wrapWithProviders(const SelectBabyScreen(), mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Lucas'), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Responsável'), findsWidgets); // owner badge
      expect(find.text('Cuidador(a)'), findsWidgets); // caregiver badge
    });

    testWidgets('shows FAB button', (tester) async {
      final mockRepo = MockBabyRepository()..babiesResult = [];
      await tester.pumpWidget(
          wrapWithProviders(const SelectBabyScreen(), mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // FAB is present
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows gender icon based on baby gender', (tester) async {
      final mockRepo = MockBabyRepository()
        ..babiesResult = [
          Baby(
            id: '1',
            name: 'Lucas',
            birthDate: DateTime.parse('2025-01-15'),
            gender: 'male',
            currentUserRole: 'owner',
          ),
        ];

      await tester.pumpWidget(
          wrapWithProviders(const SelectBabyScreen(), mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.boy), findsOneWidget);
    });

    testWidgets('shows app bar title in pt-BR', (tester) async {
      final mockRepo = MockBabyRepository()..babiesResult = [];
      await tester.pumpWidget(
          wrapWithProviders(const SelectBabyScreen(), mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Meus bebês'), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      final mockRepo = MockBabyRepository()
        ..errorToThrow = Exception('Erro de conexão');

      await tester.pumpWidget(
          wrapWithProviders(const SelectBabyScreen(), mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Exception: Erro de conexão'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });
  });
}
