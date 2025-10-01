import 'package:flutter/material.dart';
import 'package:customer/widgets/app_loading_widget.dart';

/// **EXAMPLES OF HOW TO USE LOADING WIDGETS THROUGHOUT YOUR APP**
/// 
/// This file shows different ways to use the AppLoadingWidget
/// in various parts of your application.

class LoadingWidgetExamples extends StatelessWidget {
  const LoadingWidgetExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading Widget Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **1. BASIC USAGE**
            const Text('1. Basic Usage:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const AppLoadingWidget(),
            const SizedBox(height: 30),
            
            // **2. SEARCH LOADING**
            const Text('2. Search Loading:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const SearchLoadingWidget(),
            const SizedBox(height: 30),
            
            // **3. RESTAURANT LOADING**
            const Text('3. Restaurant Loading:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),                                                                                                          
            const SizedBox(height: 10),
            const RestaurantLoadingWidget(),
            const SizedBox(height: 30),
            
            // **4. CUSTOM LOADING**
            const Text('4. Custom Loading:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const AppLoadingWidget(
              title: "🍕 Loading Pizza Menu...",
              subtitle: "Getting the best deals for you",
              icon: Icons.local_pizza,
              backgroundColor: Colors.red,
              size: 70,
              showDots: true,
              showFunFact: true,
            ),
            const SizedBox(height: 30),
            
            // **5. SIMPLE LOADING**
            const Text('5. Simple Loading:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const GeneralLoadingWidget(message: "🔄 Processing..."),
            const SizedBox(height: 30),
            
            // **6. DATA LOADING**
            const Text('6. Data Loading:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const DataLoadingWidget(),
            const SizedBox(height: 30),
            
            // **7. ORDER LOADING**
            const Text('7. Order Loading:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const OrderLoadingWidget(),
          ],
        ),
      ),
    );
  }
}

/// **USAGE EXAMPLES IN DIFFERENT SCENARIOS:**

class ExampleUsageScenarios {
  
  /// **1. IN A SEARCH SCREEN**
  static Widget buildSearchScreen() {
    return Builder(
      builder: (context) {
        // Simulate loading state
        bool isLoading = true;
        
        if (isLoading) {
          return const SearchLoadingWidget();
        }
        
        return const Text('Search Results');
      },
    );
  }
  
  /// **2. IN A RESTAURANT LIST SCREEN**
  static Widget buildRestaurantListScreen() {
    return Builder(
      builder: (context) {
        // Simulate loading state
        bool isLoading = true;
        
        if (isLoading) {
          return const RestaurantLoadingWidget();
        }
        
        return const Text('Restaurant List');
      },
    );
  }
  
  /// **3. IN A PROFILE SCREEN**
  static Widget buildProfileScreen() {
    return Builder(
      builder: (context) {
        // Simulate loading state
        bool isLoading = true;
        
        if (isLoading) {
          return const DataLoadingWidget(message: "👤 Loading Profile...");
        }
        
        return const Text('Profile Data');
      },
    );
  }
  
  /// **4. IN A CART SCREEN**
  static Widget buildCartScreen() {
    return Builder(
      builder: (context) {
        // Simulate loading state
        bool isLoading = true;
        
        if (isLoading) {
          return const AppLoadingWidget(
            title: "🛒 Loading Cart...",
            subtitle: "Calculating your total",
            icon: Icons.shopping_cart,
            backgroundColor: Colors.green,
            showDots: true,
            showFunFact: false,
          );
        }
        
        return const Text('Cart Items');
      },
    );
  }
  
  /// **5. IN A SETTINGS SCREEN**
  static Widget buildSettingsScreen() {
    return Builder(
      builder: (context) {
        // Simulate loading state
        bool isLoading = true;
        
        if (isLoading) {
          return const GeneralLoadingWidget(message: "⚙️ Loading Settings...");
        }
        
        return const Text('Settings');
      },
    );
  }
  
  /// **6. IN A FULL SCREEN LOADING**
  static Widget buildFullScreenLoading() {
    return Scaffold(
      body: const RestaurantLoadingWidget(),
    );
  }
  
  /// **7. IN A DIALOG/OVERLAY**
  static Widget buildLoadingDialog() {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: const AppLoadingWidget(
          title: "💳 Processing Payment...",
          subtitle: "Please don't close the app",
          icon: Icons.payment,
          backgroundColor: Colors.blue,
          size: 50,
          showDots: true,
          showFunFact: false,
        ),
      ),
    );
  }
}

/// **QUICK REFERENCE:**
/// 
/// ```dart
/// // Basic loading
/// const AppLoadingWidget()
/// 
/// // Search loading
/// const SearchLoadingWidget()
/// 
/// // Restaurant loading with fun facts
/// const RestaurantLoadingWidget()
/// 
/// // Order loading with hand & dish icon
/// const OrderLoadingWidget()
/// 
/// // General loading with custom message
/// const GeneralLoadingWidget(message: "Custom message")
/// 
/// // Data loading
/// const DataLoadingWidget()
/// 
/// // Fully customizable
/// const AppLoadingWidget(
///   title: "Custom Title",
///   subtitle: "Custom Subtitle", 
///   icon: Icons.custom_icon,
///   backgroundColor: Colors.custom,
///   size: 80,
///   showDots: true,
///   showFunFact: true,
/// )
/// ```
