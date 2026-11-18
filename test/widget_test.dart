import 'package:flutter_test/flutter_test.dart';

import 'package:baggifly/main.dart';

void main() {
  test('Baggage calculation logic unit test', () {
    // Economy (allowance 20kg), weight 25kg, rate RM 10
    final result = calculateBaggageFee(
      weight: 25,
      ticketClass: 'Economy',
      ratePerKg: 10,
    );
    expect(result.excessWeight, 5.0);
    expect(result.excessCharge, 50.0);
    expect(result.serviceTax, 4.0); // 8% of 50
    expect(result.total, 54.0);
  });

  testWidgets('Baggifly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify app title and buttons
    expect(find.text(AppInfo.appName), findsWidgets);
    expect(find.text('Calculate'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });
}
