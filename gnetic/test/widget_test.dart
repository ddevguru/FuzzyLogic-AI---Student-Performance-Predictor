import 'package:flutter_test/flutter_test.dart';
import 'package:gnetic/main.dart';
import 'package:gnetic/services/settings_service.dart';
import 'package:gnetic/services/simulation_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsService()),
          ChangeNotifierProvider(create: (_) => SimulationService()),
        ],
        child: const GeneticLabApp(),
      ),
    );

    expect(find.text('Genetic Optimization Lab'), findsWidgets);
  });
}
