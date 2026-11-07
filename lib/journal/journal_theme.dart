import 'package:flutter/material.dart';
import 'package:hail_parks_guide/models/place_model.dart';

/// The "field journal" design: limestone paper, basalt ink and the red ochre
/// of Hail's rock art. Sharp corners and ruled lines instead of cards.
class J {
  // Colors
  static const Color paper = Color(0xFFF2EDE4);
  static const Color paperDeep = Color(0xFFE7DFD2);
  static const Color ink = Color(0xFF1D1A17);
  static const Color inkSoft = Color(0xFF615950);
  static const Color rule = Color(0xFFCDC3B4);
  static const Color ochre = Color(0xFFB0432A);
  static const Color onInk = Color(0xFFF2EDE4);
  static const Color onInkSoft = Color(0xFFB9AFA3);

  /// One color per kind of place, used for small marks and map pins.
  static Color category(PlaceCategory c) => switch (c) {
        PlaceCategory.park => const Color(0xFF55693A),
        PlaceCategory.nature => const Color(0xFF8A5A2B),
        PlaceCategory.heritage => ochre,
        PlaceCategory.restaurant => const Color(0xFF34536B),
        PlaceCategory.cafe => const Color(0xFF6B4A5E),
      };

  // Type: Reem Kufi for headings, Tajawal for reading.
  static const String kufi = 'ReemKufi';
  static const String body = 'Tajawal';

  static TextStyle kufiStyle(double size, {double weight = 700, Color color = ink}) =>
      TextStyle(
        fontFamily: kufi,
        fontSize: size,
        height: 1.25,
        color: color,
        fontVariations: [FontVariation('wght', weight)],
      );

  static final TextStyle display = kufiStyle(44);
  static final TextStyle title = kufiStyle(28);
  static final TextStyle heading = kufiStyle(21);
  static final TextStyle entry = kufiStyle(18, weight: 600);
  static final TextStyle number = kufiStyle(15, weight: 500, color: ochre);

  static const TextStyle label = TextStyle(
    fontFamily: body,
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: ochre,
  );
  static const TextStyle text = TextStyle(
    fontFamily: body,
    fontSize: 15,
    height: 1.75,
    color: ink,
  );
  static const TextStyle meta = TextStyle(
    fontFamily: body,
    fontSize: 13,
    height: 1.5,
    color: inkSoft,
  );

  static const double gutter = 20;

  /// Arabic-Indic digits, zero-padded to two: 3 → ٠٣.
  static String index(int n) => digits(n.toString().padLeft(2, '0'));

  static String digits(String s) => s.replaceAllMapped(
      RegExp(r'\d'), (m) => '٠١٢٣٤٥٦٧٨٩'[int.parse(m[0]!)]);
}

ThemeData buildJournalTheme() {
  const sharp = RoundedRectangleBorder(borderRadius: BorderRadius.zero);
  return ThemeData(
    fontFamily: J.body,
    scaffoldBackgroundColor: J.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: J.ochre,
      primary: J.ink,
      secondary: J.ochre,
      surface: J.paper,
      onSurface: J.ink,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: J.paperDeep,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: J.ochre,
      selectionColor: Color(0x55B0432A),
      selectionHandleColor: J.ochre,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: J.ink,
        foregroundColor: J.onInk,
        elevation: 0,
        shape: sharp,
        minimumSize: const Size.fromHeight(54),
        textStyle: const TextStyle(fontFamily: J.body, fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: J.ink,
        shape: sharp,
        side: const BorderSide(color: J.ink, width: 1.4),
        minimumSize: const Size.fromHeight(54),
        textStyle: const TextStyle(fontFamily: J.body, fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: J.ink,
        shape: sharp,
        textStyle: const TextStyle(fontFamily: J.body, fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: J.ink,
      contentTextStyle: TextStyle(fontFamily: J.body, color: J.onInk, fontSize: 14),
      actionTextColor: Color(0xFFE98A6E),
      behavior: SnackBarBehavior.floating,
      shape: sharp,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: J.paper, shape: sharp),
    dividerTheme: const DividerThemeData(color: J.rule, thickness: 1, space: 1),
  );
}
