import 'package:flutter/material.dart';

/// 🛒 Jippy Mart Theme System
/// 
/// A comprehensive theme system for the mart section with:
/// - Brand colors (#6AC335 green + #F38000 orange)
/// - Complete color palette with shades & tints
/// - Consistent styling for all UI components
/// - Dark mode support
class MartTheme {
  // ========================================
  // 🎨 BRAND COLORS
  // ========================================
  
  /// Primary Brand Green - Nature, freshness, trust
  static const Color brandGreen = Color(0xFF6AC335);
  
  /// Primary Brand Orange - Energy, call-to-action, warmth
  static const Color brandOrange = Color(0xFFF38000);
  
  /// JippyMart Button Color - Teal green for special buttons
  static const Color jippyMartButton = Color(0xFF007F73);
  
  // ========================================
  // 🌿 GREEN PALETTE (Brand Primary)
  // ========================================
  
  /// Very light green - backgrounds, subtle highlights
  static const Color greenVeryLight = Color(0xFFE8F8DB);
  
  /// Light green tint - hover states, subtle highlights
  static const Color greenLight = Color(0xFFC9EDAB);
  
  /// Medium green tint - secondary accents, info cards
  static const Color greenMedium = Color(0xFFA5E173);
  
  /// Base green - headings, icons, highlights
  static const Color greenBase = Color(0xFF6AC335);
  
  /// Dark green shade - hover, active states
  static const Color greenDark = Color(0xFF4FA828);
  
  /// Darkest green - contrast text, strong CTA outlines
  static const Color greenDarkest = Color(0xFF2F6F16);
  
  // ========================================
  // 🧡 ORANGE PALETTE (Brand Secondary)
  // ========================================
  
  /// Very light orange - button hover background, subtle highlights
  static const Color orangeVeryLight = Color(0xFFFFE7D1);
  
  /// Light orange - badges, highlights
  static const Color orangeLight = Color(0xFFFFC999);
  
  /// Medium orange tint - hover color for orange buttons
  static const Color orangeMedium = Color(0xFFFF9B40);
  
  /// Base orange - CTA buttons, links
  static const Color orangeBase = Color(0xFFF38000);
  
  /// Dark orange shade - active state, alerts
  static const Color orangeDark = Color(0xFFC45F00);
  
  /// Darkest orange - contrast text/icons on light bg
  static const Color orangeDarkest = Color(0xFF7A3600);
  
  // ========================================
  // 🔘 NEUTRAL GRAY PALETTE
  // ========================================
  
  /// Page background sections
  static const Color grayVeryLight = Color(0xFFF9FAFB);
  
  /// Card borders, dividers
  static const Color grayLight = Color(0xFFE5E7EB);
  
  /// Muted text, placeholders
  static const Color grayMedium = Color(0xFF9CA3AF);
  
  /// Normal text (body)
  static const Color grayDark = Color(0xFF374151);
  
  /// Strong headings
  static const Color grayDarkest = Color(0xFF111827);
  
  // ========================================
  // 🎯 SUPPORT COLORS
  // ========================================
  
  /// Info highlights, links
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFF93C5FD);
  static const Color blueDark = Color(0xFF1D4ED8);
  
  /// Error, delete buttons
  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFCA5A5);
  static const Color redDark = Color(0xFFDC2626);
  
  /// Warning badges
  static const Color yellow = Color(0xFFFACC15);
  static const Color yellowLight = Color(0xFFFDE047);
  static const Color yellowDark = Color(0xFFEAB308);
  
  /// Success states
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF6EE7B7);
  static const Color successDark = Color(0xFF059669);
  
  // ========================================
  // 🎨 GRADIENT DEFINITIONS
  // ========================================
  
  /// Primary brand gradient (Green to Orange)
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandGreen, brandOrange],
  );
  
  /// Green gradient variations
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [greenBase, greenDark],
  );
  
  static const LinearGradient greenLightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [greenVeryLight, greenLight],
  );
  
  /// Orange gradient variations
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orangeBase, orangeDark],
  );
  
  static const LinearGradient orangeLightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orangeVeryLight, orangeLight],
  );
  
  /// Rainbow gradient for special elements
  static const LinearGradient rainbowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      brandGreen,
      blue,
      orangeBase,
      red,
    ],
  );
  
  // ========================================
  // 🎭 THEME DATA
  // ========================================
  
  /// Main theme for the mart section
  static ThemeData get theme {
    return ThemeData(
      // Primary color scheme
      primaryColor: brandGreen,
      primarySwatch: _createMaterialColor(brandGreen),
      
      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: brandGreen,
        secondary: brandOrange,
        surface: Colors.white,
        background: grayVeryLight,
        error: red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: grayDarkest,
        onBackground: grayDarkest,
        onError: Colors.white,
      ),
      
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandGreen,
          side: const BorderSide(color: brandGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grayLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: grayMedium),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: grayDarkest,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: grayDarkest,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: grayDarkest,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: grayDarkest,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: grayDarkest,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: grayDarkest,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: grayDarkest,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: grayDarkest,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: grayDarkest,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: grayDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: grayDark,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: grayMedium,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: grayDark,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: grayDark,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: grayMedium,
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: brandGreen,
        size: 24,
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: grayLight,
        thickness: 1,
        space: 1,
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: greenVeryLight,
        selectedColor: brandGreen,
        disabledColor: grayLight,
        labelStyle: const TextStyle(color: grayDark),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
  
  // ========================================
  // 🎨 UTILITY METHODS
  // ========================================
  
  /// Create a MaterialColor from a Color
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Get color with alpha (0-255)
  static Color withAlpha(Color color, int alpha) {
    return color.withAlpha(alpha);
  }
  
  // ========================================
  // 🎯 COMMON STYLES
  // ========================================
  
  /// Common box shadow for cards
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Common box shadow for elevated elements
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];
  
  /// Common border radius for cards
  static const double cardRadius = 16.0;
  
  /// Common border radius for buttons
  static const double buttonRadius = 12.0;
  
  /// Common border radius for inputs
  static const double inputRadius = 12.0;
  
  /// Common padding for cards
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  
  /// Common padding for buttons
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 12);
}

// ========================================
// 🎨 MART EMOJI CONSTANTS
// ========================================

class MartEmojis {
  static const String cart = '🛒';
  static const String milk = '🥛';
  static const String bread = '🍞';
  static const String egg = '🥚';
  static const String cheese = '🧀';
  static const String apple = '🍎';
  static const String carrot = '🥕';
  static const String bottle = '🧴';
  static const String banana = '🍌';
  static const String baguette = '🥖';
  static const String potato = '🥔';
  static const String onion = '🧅';
  static const String tomato = '🍅';
  static const String cucumber = '🥒';
  static const String lettuce = '🥬';
  static const String nuts = '🥜';
  static const String honey = '🍯';
  static const String bacon = '🥓';
  static const String meat = '🍖';
  static const String fish = '🐟';
  static const String orange = '🍊';
  static const String strawberry = '🍓';
  static const String grapes = '🍇';
  static const String mango = '🥭';
  static const String peach = '🍑';
  static const String cherry = '🍒';
  static const String coconut = '🥥';
  static const String pineapple = '🍍';
  static const String kiwi = '🥝';
  static const String melon = '🍈';
  
  /// Get random mart emoji
  static String getRandom() {
    final emojis = [
      cart, milk, bread, egg, cheese, apple, carrot, bottle, banana, baguette,
      potato, onion, tomato, cucumber, lettuce, nuts, honey, bacon, meat, fish,
      orange, strawberry, grapes, mango, peach, cherry, coconut, pineapple, kiwi, melon,
    ];
    return emojis[DateTime.now().millisecondsSinceEpoch % emojis.length];
  }
  
  /// Get emoji by category
  static String getByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'dairy':
      case 'milk':
        return milk;
      case 'bread':
      case 'bakery':
        return bread;
      case 'eggs':
      case 'poultry':
        return egg;
      case 'cheese':
        return cheese;
      case 'fruits':
      case 'apple':
        return apple;
      case 'vegetables':
      case 'carrot':
        return carrot;
      case 'cleaning':
      case 'supplies':
        return bottle;
      case 'organic':
      case 'banana':
        return banana;
      default:
        return cart;
    }
  }
}