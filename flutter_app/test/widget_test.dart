import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('FuzzyLogicApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FuzzyLogicApp());
    expect(find.byType(FuzzyLogicApp), findsOneWidget);
  });
}
