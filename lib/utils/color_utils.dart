import 'package:flutter/material.dart';

class ColorUtils {
  static Color withOpacity(Color color, double opacity) {
    return Color.fromRGBO(
      (color.red * 255).round(),
      (color.green * 255).round(),
      (color.blue * 255).round(),
      opacity,
    );
  }
} 