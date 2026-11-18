import 'package:flutter_test/flutter_test.dart';
import 'package:projectmetech/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PerpustakaanApp());
    await tester.pumpAndSettle();

    expect(find.text('Perpustakaan Kampus'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
