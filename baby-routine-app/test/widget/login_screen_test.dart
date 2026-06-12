import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/auth/presentation/login_screen.dart';
import 'package:baby_routine_app/features/auth/controllers/auth_controller.dart';
import 'package:baby_routine_app/features/auth/repositories/auth_repository.dart';

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

  group('LoginScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const LoginScreen()));

      // App title
      expect(find.text('Baby Routine'), findsOneWidget);

      // Email field
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Seu e-mail'), findsOneWidget);

      // Password field
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Sua senha'), findsOneWidget);

      // Login button
      expect(find.text('Entrar'), findsOneWidget);

      // Register link
      expect(find.text('Cadastre-se'), findsOneWidget);
      expect(find.text('Não tem uma conta? '), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty fields',
        (tester) async {
      await tester.pumpWidget(wrapWithProviders(const LoginScreen()));

      // Tap login button with empty fields
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Validation error messages should appear (pt-BR)
      expect(find.text('E-mail é obrigatório'), findsOneWidget);
      expect(find.text('Senha é obrigatória'), findsOneWidget);
    });

    testWidgets('shows password validation error for short password',
        (tester) async {
      await tester.pumpWidget(wrapWithProviders(const LoginScreen()));

      // Fill email
      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'),
          'user@example.com');

      // Fill short password
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Senha'), '123');

      // Submit
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Should show password validation error
      expect(
        find.text('A senha deve ter pelo menos 8 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const LoginScreen()));

      // Find the visibility toggle (starts as visibility_off since obscure=true)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap to show password
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('has register link text in pt-BR', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const LoginScreen()));

      // All user-facing text in pt-BR
      expect(find.text('Faça login para continuar'), findsOneWidget);
    });
  });
}
