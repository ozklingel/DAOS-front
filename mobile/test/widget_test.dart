import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daos/app.dart';

void main() {
  testWidgets('DAOS app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DaosApp()),
    );
    expect(find.text('DAOS'), findsOneWidget);
  });
}
