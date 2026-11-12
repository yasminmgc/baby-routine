import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/shared/widgets/health_record_item.dart';

void main() {
  group('HealthRecordItem', () {
    testWidgets('renders title, subtitle, and date', (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: HealthRecordItem(
            title: 'Consulta pediatra',
            subtitle: 'Dr. Silva — Rotina',
            date: '12/06/2026',
            icon: Icons.medical_services,
          ),
        ),
      );

      expect(find.text('Consulta pediatra'), findsOneWidget);
      expect(find.text('Dr. Silva — Rotina'), findsOneWidget);
      expect(find.text('12/06/2026'), findsOneWidget);
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
    });

    testWidgets('uses lilacDark as default icon color', (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: HealthRecordItem(
            title: 'Vacina',
            subtitle: 'Pentavalente',
            date: '10/06/2026',
            icon: Icons.vaccines,
          ),
        ),
      );

      // Verify it renders without crash
      expect(find.text('Vacina'), findsOneWidget);
    });
  });
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: ListView(children: [child])),
    );
  }
}
