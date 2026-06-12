import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/features/auth/presentation/splash_screen.dart';
import 'package:baby_routine_app/core/constants/app_colors.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('shows app logo and name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // App name is displayed
      expect(find.text('Baby Routine'), findsOneWidget);
      // Tagline is displayed
      expect(
        find.text('Acompanhe a rotina do seu bebê'),
        findsOneWidget,
      );
      // App icon (child_care) is displayed
      expect(find.byIcon(Icons.child_care), findsOneWidget);
      // Loading indicator shown while checking token
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders with lilac background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.lilac);
    });
  });
}
