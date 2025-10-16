import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'screens/app_main.dart' as app_main;
import 'screens/home_screen.dart' as home_screen;
// import 'screens/register_test.dart' as register_test;
// import 'screens/home_test.dart' as home_test;
// import 'screens/mart_test.dart' as mart_test;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Food Delivery App Integration Tests', () {
    app_main.main();
    home_screen.main();
    // register_test.main();
    // home_test.main();
    // mart_test.main();
    // orders_test.main();
  });
}