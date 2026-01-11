import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:millime/enrol/accordion_document_screen/terms_conditions_screen_v2.dart';
import 'package:millime/enrol/accordion_document_screen/provider/terms_conditions_provider.dart';
import 'package:millime/widgets/custum_button.dart';
import 'package:millime/core/utils/size_utils.dart';

void main() {
  group('TermsConditionsScreenV2 Tests', () {
    late TermsConditionsProvider provider;

    setUp(() {
      provider = TermsConditionsProvider();
      // Initialize SizeUtils for responsive extensions
      SizeUtils.setScreenSize(
        const BoxConstraints(maxWidth: 375, maxHeight: 2000), // Larger height for scrolling
        Orientation.portrait,
      );
    });

    testWidgets('Displays title and subtitle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TermsConditionsProvider>(
            create: (_) => provider,
            child: TermsConditionsScreenV2(),
          ),
        ),
      );

      // Wait for loading
      await tester.pumpAndSettle();

      // Check title
      expect(find.text('Conditions d\'utilisation'), findsOneWidget);

      // Check subtitle
      expect(find.text('Veuillez lire et accepter les conditions suivantes'), findsOneWidget);
    });

    testWidgets('Loads documents from JSON and displays cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TermsConditionsProvider>(
            create: (_) => provider,
            child: TermsConditionsScreenV2(),
          ),
        ),
      );

      // Wait for loading
      await tester.pumpAndSettle();

      // Should have 2 document cards (FAQ is disabled)
      expect(find.text('Conditions générales d\'utilisation'), findsOneWidget);
      expect(find.text('Politique de confidentialité'), findsOneWidget);
      expect(find.text('FAQ – MillimePay'), findsNothing); // Disabled
    });

    testWidgets('Displays correct icons for documents', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TermsConditionsProvider>(
            create: (_) => provider,
            child: TermsConditionsScreenV2(),
          ),
        ),
      );

      // Wait for loading
      await tester.pump(); // Initial build
      await tester.pump(const Duration(seconds: 1)); // Wait for async loading

      // Check for description icon (first document)
      expect(find.byIcon(Icons.description), findsOneWidget);

      // Check for shield icon (second document)
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('Checkbox validation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TermsConditionsProvider>(
            create: (_) => provider,
            child: TermsConditionsScreenV2(),
          ),
        ),
      );

      // Wait for loading
      await tester.pump(); // Initial build
      await tester.pump(const Duration(seconds: 1)); // Wait for async loading

      // Initially, button should be disabled
      final button = find.byType(CustomButton);
      expect(tester.widget<CustomButton>(button).onPressed, isNull);

      // Set first document as accepted
      provider.setDocumentAccepted(0, true);
      await tester.pump();

      // Button still disabled (need both)
      expect(tester.widget<CustomButton>(button).onPressed, isNull);

      // Set second document as accepted
      provider.setDocumentAccepted(1, true);
      await tester.pump();

      // Now button should be enabled
      expect(tester.widget<CustomButton>(button).onPressed, isNotNull);

      // Tap button to show snackbar
      await tester.tap(button);
      await tester.pump();
      expect(find.text('Conditions acceptées!'), findsOneWidget);
    });

    testWidgets('Contact coordinates card is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TermsConditionsProvider>(
            create: (_) => provider,
            child: TermsConditionsScreenV2(),
          ),
        ),
      );

      // Wait for loading
      await tester.pump(); // Initial build
      await tester.pump(const Duration(seconds: 1)); // Wait for async loading

      expect(find.text('Coordonnées de contact'), findsOneWidget);
      expect(find.text('Pour la récupération de compte'), findsOneWidget);
    });

    testWidgets('Security info banner is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TermsConditionsProvider>(
            create: (_) => provider,
            child: TermsConditionsScreenV2(),
          ),
        ),
      );

      // Wait for loading
      await tester.pumpAndSettle();

      expect(find.text('Vos données sont protégées'), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    testWidgets('Articles can be expanded and collapsed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TermsConditionsProvider>(
            create: (_) => provider,
            child: TermsConditionsScreenV2(),
          ),
        ),
      );

      // Wait for loading
      await tester.pumpAndSettle();

      // Find first article
      final firstArticle = find.text('Article premier: Définitions');
      expect(firstArticle, findsOneWidget);

      // Initially collapsed, tap to expand
      await tester.tap(firstArticle);
      await tester.pump();

      // Should show summary
      expect(find.textContaining('Compte de paiement: Le compte de paiement'), findsOneWidget);

      // Tap again to collapse
      await tester.tap(firstArticle);
      await tester.pump();

      // Summary should be hidden
      expect(find.textContaining('Compte de paiement: Le compte de paiement'), findsNothing);
    });
  });
}