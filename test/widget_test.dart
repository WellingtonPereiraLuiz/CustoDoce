import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custo_doce/main.dart';

void main() {
  testWidgets('CustoDoce app smoke test', (WidgetTester tester) async {
    // Build the app inside a ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: CustoDoceApp(),
      ),
    );

    // Verify the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
