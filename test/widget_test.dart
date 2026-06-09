import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('shows onboarding entry point', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MailNestApp()));
    await tester.pumpAndSettle();

    expect(find.text('MailNest'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
