import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

Color primaryColor = Color(0xffff3a5a);
Color secondryColor = Colors.grey;
Color darkPrimaryColor = Color(0x22ff3a5a);
Color textColor = Colors.white;
Color textBlue = HexColor("#4267b2");

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
