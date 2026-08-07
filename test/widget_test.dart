import 'package:flutter_test/flutter_test.dart';
import 'package:gota_mobile/main.dart';

void main() {
  testWidgets(
    'Gota inicia correctamente',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const GotaApp(),
      );

      expect(
        find.text('Gota'),
        findsWidgets,
      );
    },
  );
}