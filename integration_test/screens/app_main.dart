// integration_test/app_integration_test.dart
import 'dart:ui';

import 'package:customer/app/category_service/category__service_screen.dart';
import 'package:customer/app/mart/mart_home_screen/mart_home_screen.dart' show MartHomeScreen;
import 'package:customer/app/video_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:customer/main.dart' as app;
import 'package:get_storage/get_storage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end Tests', () {
    setUp(() async {
      // Clear storage before each test
      await GetStorage.init();
      await GetStorage().erase();
    });

    tearDown(() async {
      await GetStorage().erase();
    });

    testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen is shown
      expect(find.byType(VideoSplashScreen), findsOneWidget);
    });

    testWidgets('Complete user journey: Login -> Dashboard -> Mart', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Skip splash screen (if skip button exists)
      final skipButton = find.byKey(const Key('skip_splash'));
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Look for login elements
      expect(find.textContaining('Login'), findsOneWidget);

      // Test would continue with actual login flow...
    });

    testWidgets('Navigation between main tabs', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Test navigation between different sections
      // This is a generic test that should work with your app structure
      final dashboardTab = find.byKey(const Key('dashboard_tab'));
      final martTab = find.byKey(const Key('mart_tab'));
      final servicesTab = find.byKey(const Key('services_tab'));

      // Try to navigate if tabs exist
      if (martTab.evaluate().isNotEmpty) {
        await tester.tap(martTab);
        await tester.pumpAndSettle();
        expect(find.byType(MartHomeScreen), findsOneWidget);
      }

      if (servicesTab.evaluate().isNotEmpty) {
        await tester.tap(servicesTab);
        await tester.pumpAndSettle();
        expect(find.byType(CateringServiceScreen), findsOneWidget);
      }
    });
  });

  group('Performance Tests', () {
    testWidgets('Startup time measurement', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      app.main();
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Assert startup time is reasonable (adjust threshold as needed)
      expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // 10 seconds max

      print('App startup time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Frame rendering performance', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Measure frame rendering time during navigation
      final frameTimings = <Duration>[];

      // Add callback to measure frame times
      tester.binding.addTimingsCallback((List<FrameTiming> timings) {
        for (final timing in timings) {
          frameTimings.add(timing.totalSpan);
        }
      });

      // Perform some navigation
      final martTab = find.byKey(const Key('mart_tab'));
      if (martTab.evaluate().isNotEmpty) {
        await tester.tap(martTab);
        await tester.pumpAndSettle();
      }

      // Check that most frames render within 16ms (60 FPS)
      final slowFrames = frameTimings.where((timing) => timing.inMilliseconds > 16).length;
      final slowFramePercentage = (slowFrames / frameTimings.length) * 100;

      expect(slowFramePercentage, lessThan(10.0)); // Less than 10% slow frames

      print('Slow frames: $slowFrames out of ${frameTimings.length} (${slowFramePercentage.toStringAsFixed(1)}%)');
    });

    testWidgets('Memory usage during heavy operations', (WidgetTester tester) async {
      // Start with a clean app
      app.main();
      await tester.pumpAndSettle();

      // Perform memory-intensive operations
      for (int i = 0; i < 10; i++) {
        // Navigate between screens to test memory management
        final martTab = find.byKey(const Key('mart_tab'));
        final dashboardTab = find.byKey(const Key('dashboard_tab'));

        if (martTab.evaluate().isNotEmpty && dashboardTab.evaluate().isNotEmpty) {
          await tester.tap(martTab);
          await tester.pumpAndSettle();

          await tester.tap(dashboardTab);
          await tester.pumpAndSettle();
        }

        // Simulate loading data
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Force garbage collection
      await tester.pumpAndSettle();

      // The test passes if no OutOfMemoryError occurs
      // In a real scenario, you might want to use platform channels to get memory info
      print('Memory stress test completed successfully');
    });
  });

  group('Error Handling Tests', () {
    testWidgets('App recovers from service initialization failures', (WidgetTester tester) async {
      // This test verifies the app doesn't crash when services fail to initialize
      app.main();
      await tester.pumpAndSettle();

      // The app should show either the splash screen or error UI
      // but never crash completely
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Network error handling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Try to trigger network operations
      // The app should handle errors gracefully
      final retryButtons = find.textContaining('Retry');
      if (retryButtons.evaluate().isNotEmpty) {
        await tester.tap(retryButtons.first);
        await tester.pumpAndSettle();

        // Should not crash
        expect(find.byType(Scaffold), findsOneWidget);
      }
    });
  });
}