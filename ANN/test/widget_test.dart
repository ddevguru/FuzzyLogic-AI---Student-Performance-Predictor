import 'package:flutter_test/flutter_test.dart';
import 'package:ann_intelligence_lab/main.dart';

void main() {
  testWidgets('App renders main navigation title', (WidgetTester tester) async {
    await tester.pumpWidget(const AnnIntelligenceLabApp());
    expect(find.text('ANN Intelligence Lab'), findsWidgets);
  });
}
