import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmail/app.dart';

void main() {
  testWidgets('TaskMail app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TaskMailApp()),
    );
    expect(find.text('TaskMail'), findsOneWidget);
  });
}
