import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/app.dart';

void main() {
  testWidgets('DAOS app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TaskMailApp()),
    );
    expect(find.text('DAOS'), findsOneWidget);
  });
}
