import 'package:flutter/material.dart';

/// Global text styles used throughout the app
class CustomTextStyles {
  static const TextStyle configTitle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static const TextStyle configTitle2 = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle configTitle3 = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle configBody = TextStyle(
    color: Color.fromARGB(200, 255, 255, 255),
    fontSize: 16,
    height: 1.5,
  );

  static const TextStyle configBody1 = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle configBody2 = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    height: 1.3,
  );

  static const TextStyle configBody3 = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle configButonText = TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle introPageTitle = TextStyle(
    color: Colors.white,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static const TextStyle smallLabel = TextStyle(
    color: Colors.white70,
    fontSize: 12,
    letterSpacing: 0.5,
  );

  static const TextStyle dashboardText = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle calsLabel = TextStyle(
    color: Colors.white70,
    fontSize: 15,
    height: 1.2,
  );

  static const TextStyle calsText = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle percentText = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle percentText2 = TextStyle(
    color: Colors.orangeAccent,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle calsText2 = TextStyle(
    color: Colors.white70,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle calsText3 = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle barText = TextStyle(
    color: Colors.white70,
    fontSize: 12,
  );

  static const TextStyle barText2 = TextStyle(
    color: Colors.white,
    fontSize: 12,
    height: 1.3,
  );

  static const TextStyle searchTitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle searchtext = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}

/// Global app colors
class AppColors {
  static const Color background = Colors.black;
  static const Color card = Color(0xFF181818);
  static const Color accent = Colors.greenAccent;
  static const Color secondaryAccent = Color(0xFF3FA56A);
  static const Color lightGrey = Color(0xFF8E8E8E);
  static const Color buttonBlue = Color(0xFF87CEEB);
  static const Color buttonPink = Color(0xFFFFD1DC);
}

/// Button style example (for consistent rounded buttons)
final ButtonStyle customButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: AppColors.accent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(25),
  ),
  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
);

ThemeData myTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.secondaryAccent,
      secondary: AppColors.accent,
      background: AppColors.background,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.card,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondaryAccent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(color: Colors.white70),
    ),
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: AppColors.secondaryAccent,
      thumbColor: AppColors.secondaryAccent,
      overlayColor: AppColors.secondaryAccent.withOpacity(0.2),
    ),
  );
}
