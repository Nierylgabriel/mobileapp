import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mingletomingle/widgets/brand_logo.dart';
import 'package:mingletomingle/data/sample_data.dart';

void main() {
  testWidgets('BrandLogoWidget displays title and tagline', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BrandLogoWidget(showTagline: true),
        ),
      ),
    );

    expect(find.text('Find your connection.'), findsOneWidget);
  });

  test('Sample profiles data is populated and valid', () {
    expect(SampleData.profiles.isNotEmpty, true);
    expect(SampleData.profiles.first.name, 'Sophia Chen');
    expect(SampleData.profiles.first.passions.contains('Design'), true);
  });
}
