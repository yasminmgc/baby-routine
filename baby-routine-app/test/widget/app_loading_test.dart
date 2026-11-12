import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/shared/widgets/app_loading.dart';

void main() {
  group('AppLoading', () {
    testWidgets('renders CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const _TestApp(child: AppLoading()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders message when provided', (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: AppLoading(message: 'Carregando dados...'),
        ),
      );

      expect(find.text('Carregando dados...'), findsOneWidget);
    });

    testWidgets('does not render message when not provided', (tester) async {
      await tester.pumpWidget(
        const _TestApp(child: AppLoading()),
      );

      // Only the progress indicator, no extra text widget
      expect(find.byType(Text), findsNothing);
    });
  });
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }
}
