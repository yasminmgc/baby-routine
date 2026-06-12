import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/babies/presentation/edit_baby_screen.dart';
import 'package:baby_routine_app/features/babies/models/baby.dart';
import 'package:baby_routine_app/features/babies/repositories/baby_repository.dart';
import 'package:baby_routine_app/features/babies/controllers/baby_controller.dart';
import 'package:baby_routine_app/shared/providers/selected_baby_provider.dart';

class _FakeRepo implements BabyRepository {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  Widget wrapWithProviders(Widget child, {Baby? selectedBaby}) {
    return ProviderScope(
      overrides: [
        babyRepositoryProvider.overrideWithValue(_FakeRepo() as BabyRepository),
        if (selectedBaby != null)
          selectedBabyProvider.overrideWithValue(selectedBaby),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  final testBaby = Baby(
    id: 'baby-1',
    name: 'Lucas',
    birthDate: DateTime.parse('2025-01-15'),
    gender: 'male',
    initialWeightKg: 3.5,
    initialHeightCm: 50.0,
    allergies: 'lactose',
    currentUserRole: 'owner',
  );

  group('EditBabyScreen', () {
    testWidgets('renders pre-filled form fields', (tester) async {
      await tester.pumpWidget(
          wrapWithProviders(const EditBabyScreen(), selectedBaby: testBaby));
      await tester.pumpAndSettle();

      // Name field pre-filled
      final nameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Nome'),
      );
      expect(nameField.controller?.text, 'Lucas');

      // Allergies pre-filled
      final allergiesField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Alergias'),
      );
      expect(allergiesField.controller?.text, 'lactose');

      // Weight pre-filled
      final weightField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Peso (kg)'),
      );
      expect(weightField.controller?.text, '3.5');

      // Height pre-filled
      final heightField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Altura (cm)'),
      );
      expect(heightField.controller?.text, '50.0');

      // Buttons
      expect(find.text('Salvar alterações'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('shows delete button for owner role', (tester) async {
      await tester.pumpWidget(
          wrapWithProviders(const EditBabyScreen(), selectedBaby: testBaby));
      await tester.pumpAndSettle();

      expect(find.text('Excluir bebê'), findsOneWidget);
    });

    testWidgets('hides delete button for caregiver role', (tester) async {
      final caregiverBaby = testBaby.copyWith(currentUserRole: 'caregiver');

      await tester.pumpWidget(wrapWithProviders(const EditBabyScreen(),
          selectedBaby: caregiverBaby));
      await tester.pumpAndSettle();

      expect(find.text('Excluir bebê'), findsNothing);
    });

    testWidgets('shows app bar title in pt-BR', (tester) async {
      await tester.pumpWidget(
          wrapWithProviders(const EditBabyScreen(), selectedBaby: testBaby));
      await tester.pumpAndSettle();

      expect(find.text('Editar bebê'), findsOneWidget);
    });

    testWidgets('shows delete confirmation dialog', (tester) async {
      await tester.pumpWidget(
          wrapWithProviders(const EditBabyScreen(), selectedBaby: testBaby));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.text('Excluir bebê'));
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text('Excluir bebê'), findsWidgets);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(
        find.text(
            'Tem certeza que deseja excluir este bebê? Esta ação não pode ser desfeita.'),
        findsOneWidget,
      );
    });
  });
}
