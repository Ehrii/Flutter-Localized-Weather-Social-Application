import 'package:flutter/material.dart';

class ColorPalette {
  static const Color greyblue= Color(0xFFD2E7F8);
  static const Color lightblue = Color(0xFF80C3E4);
  static const Color blue = Color(0xFF5eb0f8);
  static const Color mediumdarkblue = Color(0xFFa2c2e3);
  static const Color darkblue = Color(0xFF14345d);
// #a2c2e3

  static Color getShadedColor(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}