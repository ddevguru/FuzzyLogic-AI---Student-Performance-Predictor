import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swarm_intelligence_lab/main.dart';

void main() {
  testWidgets('Swarm Intelligence Lab smoke test', (WidgetTester tester) async {
    // Provide adequate viewport size for responsive layout
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const SwarmIntelligenceLabApp());
    await tester.pump();

    // Verify Brand title is present
    expect(find.textContaining('Swarm'), findsWidgets);
    expect(find.text('Small Agents. Collective Intelligence. Better Solutions.'), findsOneWidget);
  });
}
