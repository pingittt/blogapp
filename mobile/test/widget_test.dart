import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('Blog app renders home tabs', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pump();

    expect(find.text('For You'), findsOneWidget);
    expect(find.text('Semua Post'), findsOneWidget);
  });
}
