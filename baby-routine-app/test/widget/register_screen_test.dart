import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/auth/presentation/register_screen.dart';
import 'package:baby_routine_app/features/auth/repositories/auth_repository.dart';
import 'package:baby_routine_app/features/auth/controllers/auth_controller.dart';

void main() {
  /// Wraps a widget in the required provider context for ConsumerStatefulWidget tests.
  Widget wrapWithProviders(Widget child, {AuthRepository? mockRepo}) {
    return ProviderScope(
      overrides: [
        if (mockRepo != null)
          authRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('RegisterScreen', () {
    testWidgets('renders name, email, and password fields', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const RegisterScreen()));

      // Title
      expect(find.text('Criar conta'), findsOneWidget);

      // Name field
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Seu nome completo'), findsOneWidget);

      // Email field
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Seu e-mail'), findsOneWidget);

      // Password field
      expect(find.text('Senha'), findsOneWidget);
      expect(
        find.text('Mínimo 8 caracteres, 1 maiúscula, 1 número'),
        findsOneWidget,
      );

      // Register button
      expect(find.text('Cadastrar'), findsOneWidget);

      // Login link
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Já tem uma conta? '), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty fields',
        (tester) async {
      await tester.pumpWidget(wrapWithProviders(const RegisterScreen()));

      // Tap register button with empty fields
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      // Validation error messages (pt-BR)
      expect(find.text('Este campo é obrigatório'), findsOneWidget);
      expect(find.text('E-mail é obrigatório'), findsOneWidget);
      expect(find.text('Senha é obrigatória'), findsOneWidget);
    });

    testWidgets('shows error when password lacks uppercase letter',
        (tester) async {
      await tester.pumpWidget(wrapWithProviders(const RegisterScreen()));

      // Fill name and email
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'), 'Test User');
      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'),
          'test@example.com');

      // Password with no uppercase
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Senha'), 'abcdefg1');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('A senha deve conter pelo menos uma letra maiúscula'),
        findsOneWidget,
      );
    });

    testWidgets('shows error when password lacks number', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const RegisterScreen()));

      // Fill name and email
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'), 'Test User');
      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'),
          'test@example.com');

      // Password with no number
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Senha'), 'Abcdefgh');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('A senha deve conter pelo menos um número'),
        findsOneWidget,
      );
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const RegisterScreen()));

      // Starts with password hidden
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap to show
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('has back button to navigate to login', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const RegisterScreen()));

      // Back arrow button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('all user-facing text is in pt-BR', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const RegisterScreen()));

      // Verify key texts are in Portuguese
      expect(find.text('Criar conta'), findsOneWidget);
      expect(find.text('Preencha os dados para começar'), findsOneWidget);
      expect(find.text('Cadastrar'), findsOneWidget);
    });
  });
}
