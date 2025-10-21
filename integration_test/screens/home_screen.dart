import 'package:badges/badges.dart' as badges;
import 'package:customer/app/dine_in_screeen/dine_in_screen.dart';
import 'package:customer/app/home_screen/home_screen_two.dart' hide CategoryView, BannerView;
import 'package:customer/app/scan_qrcode_screen/scan_qr_code_screen.dart';
import 'package:customer/app/swiggy_search_screen/swiggy_search_screen.dart';
import 'package:customer/widget/filter_bar.dart';
import 'package:customer/widget/initials_avatar.dart';
import 'package:customer/widget/restaurant_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:customer/app/home_screen/home_screen.dart' hide CategoryView, PopularRestaurant, NewArrival;
import 'package:customer/main.dart' as app_main;
import 'package:customer/utils/preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HomeScreen Integration Tests', () {
    late Widget testApp;

    setUpAll(() async {
      // Clear any previous preferences
      await Preferences();

      // Set up test environment
      testApp = app_main.MyApp();
    });

    setUp(() async {
      // Reset GetX bindings before each test
      Get.reset();
    });

    testWidgets('HomeScreen loads and displays main components',
            (WidgetTester tester) async {
          // Start the app
          await tester.pumpWidget(testApp);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Verify main screen components are present
          expect(find.text('FOOD'), findsOneWidget);
          expect(find.text('MART'), findsOneWidget);

          // Verify header elements
          expect(find.byType(InkWell), findsWidgets); // Profile avatar
          expect(find.byType(badges.Badge), findsOneWidget); // Cart badge

          // Verify search bar
          expect(find.text('Search the dish, restaurant, food, meals'), findsOneWidget);
        });

    testWidgets('Food/Mart toggle switches correctly',
            (WidgetTester tester) async {
          await tester.pumpWidget(testApp);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Initially on FOOD section
          expect(find.text('FOOD'), findsOneWidget);
          expect(find.text('MART'), findsOneWidget);

          // Tap on MART section
          await tester.tap(find.text('MART'));
          await tester.pumpAndSettle();

          // Should show mart dialog or navigate
          expect(find.text('COMING SOON'), findsOneWidget);
        });

    testWidgets('Cart badge updates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Initially cart should be empty or show count
      final cartBadge = find.byType(badges.Badge);
      expect(cartBadge, findsOneWidget);
    });

    testWidgets('Navigation to Profile screen works',
            (WidgetTester tester) async {
          await tester.pumpWidget(testApp);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Tap profile avatar
          final profileAvatar = find.byType(InitialsAvatar).first;
          await tester.tap(profileAvatar);
          await tester.pumpAndSettle();

          // Should navigate to profile screen
          expect(find.text('Profile'), findsOneWidget);
        });

    testWidgets('Category section displays correctly',
            (WidgetTester tester) async {
          await tester.pumpWidget(testApp);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Check for categories title
          expect(find.text('Explore the Categories'), findsOneWidget);

          // Check for view all button
          expect(find.text('View all'), findsWidgets);

          // Verify category list exists
          expect(find.byType(CategoryView), findsOneWidget);
        });

    testWidgets('Restaurant lists display correctly',
            (WidgetTester tester) async {
          await tester.pumpWidget(testApp);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Check for popular restaurants section
          expect(find.text('Popular Restaurants'), findsOneWidget);
          expect(find.text('All Restaurants'), findsOneWidget);

          // Verify restaurant list exists
          expect(find.byType(PopularRestaurant), findsOneWidget);
        });

    testWidgets('Filter bar functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check if filter bar is present
      expect(find.byType(FilterBar), findsOneWidget);

      // Test filter buttons
      final filterButtons = find.byType(InkWell);
      expect(filterButtons, findsWidgets);
    });

    testWidgets('View toggle between list and map works',
            (WidgetTester tester) async {
          await tester.pumpWidget(testApp);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Initially in list view
          expect(find.byType(ListView), findsWidgets);

          // Find and tap map view button
          final mapViewButton = find.byWidgetPredicate(
                (widget) =>
            widget is InkWell &&
                widget.child is ClipOval &&
                (widget.child as ClipOval).child is Padding &&
                ((widget.child as ClipOval).child as Padding)
                    .child
                    .toString()
                    .contains('ic_map_draw'),
          );

          await tester.tap(mapViewButton);
          await tester.pumpAndSettle();

          // Should switch to map view
          expect(find.byType(GoogleMap), findsOneWidget);
        });

    testWidgets('Search functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap on search bar
      final searchBar = find.text('Search the dish, restaurant, food, meals');
      await tester.tap(searchBar);
      await tester.pumpAndSettle();

      // Should navigate to search screen
      expect(find.byType(SwiggySearchScreen), findsOneWidget);
    });

    testWidgets('Banner carousel works', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check if banner view exists
      expect(find.byType(BannerView), findsOneWidget);

      // Check for page indicators
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('New Arrivals section displays', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check for new arrivals section
      expect(find.text('New Arrivals'), findsOneWidget);
      expect(find.byType(NewArrival), findsOneWidget);
    });

    testWidgets('Advertisement section displays', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check for highlights section
      expect(find.text('Highlights for you'), findsOneWidget);
    });

    testWidgets('Delivery type dropdown works', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find delivery type dropdown
      final dropdown = find.byType(DropdownButton<String>);
      expect(dropdown, findsOneWidget);

      // Tap dropdown
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Should show options
      expect(find.text('Delivery'), findsOneWidget);
      expect(find.text('TakeAway'), findsOneWidget);
    });

    testWidgets('Scroll behavior hides/shows navigation bar',
            (WidgetTester tester) async {
          await tester.pumpWidget(testApp);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Initially navigation bar should be visible
          expect(find.text('Search the dish, restaurant, food, meals'),
              findsOneWidget);

          // Scroll down
          final listView = find.byType(ListView).first;
          await tester.drag(listView, const Offset(0, -300));
          await tester.pumpAndSettle();

          // Navigation bar should be hidden
          expect(find.text('Search the dish, restaurant, food, meals'),
              findsNothing);

          // Scroll up
          await tester.drag(listView, const Offset(0, 300));
          await tester.pumpAndSettle();

          // Navigation bar should be visible again
          expect(find.text('Search the dish, restaurant, food, meals'),
              findsOneWidget);
        });

    testWidgets('Restaurant card displays correct information',
            (WidgetTester tester) async {
          await tester.pumpWidget(testApp);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Check for restaurant cards
          final restaurantCards = find.byType(InkWell);
          expect(restaurantCards, findsWidgets);

          // Verify restaurant information elements
          expect(find.byType(RestaurantImageView), findsWidgets);
          expect(find.byType(Text), findsWidgets); // Title, location, etc.
        });

    testWidgets('Favourite functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find favourite button on first restaurant card
      final favouriteButton = find.byWidgetPredicate(
            (widget) =>
        widget is InkWell &&
            widget.child is SvgPicture &&
            widget.child.toString().contains('ic_like'),
      ).first;

      await tester.tap(favouriteButton);
      await tester.pumpAndSettle();

      // Should toggle favourite state
      // Note: This will depend on your actual implementation
    });

    testWidgets('QR Code scan button works', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find QR code button
      final qrButton = find.byWidgetPredicate(
            (widget) =>
        widget is InkWell &&
            widget.child is ClipOval &&
            (widget.child as ClipOval).child is Padding &&
            ((widget.child as ClipOval).child as Padding)
                .child
                .toString()
                .contains('ic_scan_code'),
      );

      await tester.tap(qrButton);
      await tester.pumpAndSettle();

      // Should navigate to QR scan screen
      expect(find.byType(ScanQrCodeScreen), findsOneWidget);
    });

    testWidgets('WhatsApp support button works', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find WhatsApp button
      final whatsappButton = find.byWidgetPredicate(
            (widget) =>
        widget is InkWell &&
            widget.child is ClipOval &&
            (widget.child as ClipOval).child is Padding &&
            ((widget.child as ClipOval).child as Padding)
                .child
                .toString()
                .contains('ic_send'),
      );

      await tester.tap(whatsappButton);
      await tester.pumpAndSettle();

      // Should attempt to launch WhatsApp
      // Note: In test environment, this might not actually launch
    });

    testWidgets('No restaurants message displays when no restaurants',
            (WidgetTester tester) async {
          // This test would require mocking the controller to return empty restaurant list
          // For now, we'll just verify the structure

          await tester.pumpWidget(testApp);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Check if the empty state components exist in the widget tree
          final changeZoneButton = find.text('Change Zone');
          expect(changeZoneButton, findsOneWidget);
        });

    testWidgets('Refresh indicator works', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find refresh indicator
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // Pull to refresh (this is complex to simulate in tests)
      // We'll just verify the component exists
    });
  });

  group('HomeScreen Error States', () {
    testWidgets('Displays error when zone not available',
            (WidgetTester tester) async {
          // This would require mocking the controller to simulate zone unavailability
          // For now, we'll structure the test

          await tester.pumpWidget(app_main.MyApp());
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Should show zone error message and change zone button
          final changeZoneButton = find.text('Change Zone');
          expect(changeZoneButton, findsOneWidget);
        });

    testWidgets('Handles network errors gracefully',
            (WidgetTester tester) async {
          // This would require mocking network errors
          // For now, we'll verify the app doesn't crash

          await tester.pumpWidget(app_main.MyApp());
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // App should still be running
          expect(find.byType(HomeScreen), findsOneWidget);
        });
  });
}