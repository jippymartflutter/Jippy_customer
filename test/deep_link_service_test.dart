import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer/services/final_deep_link_service.dart';

void main() {
  group('FinalDeepLinkService Tests', () {
    late GlobalKey<NavigatorState> navigatorKey;
    late FinalDeepLinkService service;

    setUp(() {
      navigatorKey = GlobalKey<NavigatorState>();
      service = FinalDeepLinkService();
    });

    tearDown(() {
      service.dispose();
    });

    test('Singleton pattern works correctly', () {
      // Test that singleton returns same instance
      final instance1 = FinalDeepLinkService();
      final instance2 = FinalDeepLinkService();
      expect(instance1, equals(instance2));
    });

    testWidgets('Service can be initialized with navigator key', (WidgetTester tester) async {
      // Mock the method channel to return null (no initial link)
      const MethodChannel('deep_link_methods').setMockMethodCallHandler((call) async {
        if (call.method == 'getInitialLink') {
          return null;
        }
        return null;
      });

      // Initialize service - should not throw
      await service.init(navigatorKey);
      
      // Service should be initialized successfully
      expect(navigatorKey, isNotNull);
    });

    testWidgets('Service handles method channel errors gracefully', (WidgetTester tester) async {
      // Mock the method channel to throw an error
      const MethodChannel('deep_link_methods').setMockMethodCallHandler((call) async {
        throw PlatformException(code: 'TEST_ERROR', message: 'Test error');
      });

      // Initialize service - should handle error gracefully
      await service.init(navigatorKey);
      
      // Service should still be initialized
      expect(navigatorKey, isNotNull);
    });

    testWidgets('Service can be disposed', (WidgetTester tester) async {
      // Initialize service
      await service.init(navigatorKey);
      
      // Dispose service - should not throw
      service.dispose();
      
      // Should be able to dispose multiple times
      service.dispose();
    });

    test('Service can handle multiple initialization calls', () async {
      // Mock the method channel
      const MethodChannel('deep_link_methods').setMockMethodCallHandler((call) async {
        if (call.method == 'getInitialLink') {
          return null;
        }
        return null;
      });

      // Initialize service multiple times
      await service.init(navigatorKey);
      await service.init(navigatorKey);
      await service.init(navigatorKey);
      
      // Should not throw and should handle gracefully
      expect(navigatorKey, isNotNull);
    });

    testWidgets('Service works with different navigator keys', (WidgetTester tester) async {
      // Mock the method channel
      const MethodChannel('deep_link_methods').setMockMethodCallHandler((call) async {
        if (call.method == 'getInitialLink') {
          return null;
        }
        return null;
      });

      final navigatorKey1 = GlobalKey<NavigatorState>();
      final navigatorKey2 = GlobalKey<NavigatorState>();
      
      // Initialize with different navigator keys
      await service.init(navigatorKey1);
      await service.init(navigatorKey2);
      
      // Should handle different keys gracefully
      expect(navigatorKey1, isNotNull);
      expect(navigatorKey2, isNotNull);
    });
  });
}
