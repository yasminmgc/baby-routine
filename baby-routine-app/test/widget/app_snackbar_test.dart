import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/shared/widgets/app_snackbar.dart';
import 'package:baby_routine_app/core/constants/app_colors.dart';

void main() {
  group('AppSnackbar', () {
    testWidgets('showError displays a snackbar with error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('Test'))),
        ),
      );

      final context = tester.element(find.byType(Text));
      AppSnackbar.showError(context, 'Ocorreu um erro');

      await tester.pump();

      expect(find.text('Ocorreu um erro'), findsOneWidget);
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, AppColors.error);
    });

    testWidgets('showSuccess displays a snackbar with success message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('Test'))),
        ),
      );

      final context = tester.element(find.byType(Text));
      AppSnackbar.showSuccess(context, 'Operação concluída');

      await tester.pump();

      expect(find.text('Operação concluída'), findsOneWidget);
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, AppColors.success);
    });
  });
}
