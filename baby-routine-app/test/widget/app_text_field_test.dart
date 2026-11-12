import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/shared/widgets/app_text_field.dart';

void main() {
  group('AppTextField', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: AppTextField(label: 'E-mail'),
        ),
      );

      expect(find.text('E-mail'), findsOneWidget);
    });

    testWidgets('shows hint text when provided', (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: AppTextField(
            label: 'Senha',
            hintText: 'Digite sua senha',
          ),
        ),
      );

      expect(find.text('Digite sua senha'), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: AppTextField(label: 'Senha', obscureText: true),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.obscureText, true);
    });

    testWidgets('shows clear text when obscureText is false', (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: AppTextField(label: 'Nome'),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.obscureText, false);
    });
  });
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );
  }
}
