import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/babies/presentation/create_baby_screen.dart';
import 'package:baby_routine_app/features/babies/repositories/baby_repository.dart';
import 'package:baby_routine_app/features/babies/controllers/baby_controller.dart';

/// Minimal mock that throws on unexpected calls.
class _FakeRepo implements BabyRepository {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  Widget wrapWithProviders(Widget child) {
    return ProviderScope(
      overrides: [
        babyRepositoryProvider.overrideWithValue(_FakeRepo() as BabyRepository),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('CreateBabyScreen', () {
    testWidgets('renders all form fields', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const CreateBabyScreen()));
      await tester.pumpAndSettle();

      // Name field
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Nome do bebê'), findsOneWidget);

      // Birth date
      expect(find.text('Data de nascimento'), findsOneWidget);

      // Gender
      expect(find.text('Sexo'), findsOneWidget);

      // Weight
      expect(find.text('Peso (kg)'), findsOneWidget);

      // Height
      expect(find.text('Altura (cm)'), findsOneWidget);

      // Allergies
      expect(find.text('Alergias'), findsOneWidget);

      // Buttons
      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('shows app bar title in pt-BR', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const CreateBabyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar bebê'), findsOneWidget);
    });

    testWidgets('shows date picker icon on birth date field', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const CreateBabyScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('shows validation error when name is empty', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const CreateBabyScreen()));
      await tester.pumpAndSettle();

      // Tap cadastrar with empty name
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('Este campo é obrigatório'), findsOneWidget);
    });

    testWidgets('gender dropdown shows pt-BR options', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const CreateBabyScreen()));
      await tester.pumpAndSettle();

      // Tap the dropdown
      await tester.tap(find.text('Selecione o sexo'));
      await tester.pumpAndSettle();

      expect(find.text('Masculino'), findsOneWidget);
      expect(find.text('Feminino'), findsOneWidget);
    });
  });
}
