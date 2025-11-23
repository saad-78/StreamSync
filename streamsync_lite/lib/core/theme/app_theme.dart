import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Premium Color Palette (Inspired by Linear, Stripe, Vercel)
  static const _primaryColor = Color(0xFF0A0A0A);
  static const _surfaceColor = Color(0xFFFFFFFF);
  static const _backgroundColor = Color(0xFFFAFAFA);
  static const _accentColor = Color(0xFF6366F1); // Indigo
  static const _errorColor = Color(0xFFEF4444);
  static const _successColor = Color(0xFF10B981);
  
  // Neutrals
  static const _gray50 = Color(0xFFFAFAFA);
  static const _gray100 = Color(0xFFF5F5F5);
  static const _gray200 = Color(0xFFE5E5E5);
  static const _gray300 = Color(0xFFD4D4D4);
  static const _gray400 = Color(0xFFA3A3A3);
  static const _gray500 = Color(0xFF737373);
  static const _gray600 = Color(0xFF525252);
  static const _gray700 = Color(0xFF404040);
  static const _gray800 = Color(0xFF262626);
  static const _gray900 = Color(0xFF171717);

  // Spacing System (8px base)
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: const ColorScheme.light(
      primary: _accentColor,
      onPrimary: Colors.white,
      secondary: _gray700,
      surface: _surfaceColor,
      background: _backgroundColor,
      error: _errorColor,
    ),
    
    scaffoldBackgroundColor: _backgroundColor,
    
    // Typography (Inter font)
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _gray900,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _gray900,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: _gray900,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: _gray900,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _gray900,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _gray900,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _gray700,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _gray600,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _gray900,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _gray600,
        letterSpacing: 0.5,
      ),
    ),
    
    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _surfaceColor,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: _gray900),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _gray900,
        letterSpacing: -0.2,
      ),
    ),
    
    // Card
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: BorderSide(color: _gray200, width: 1),
      ),
      color: _surfaceColor,
    ),
    
    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: space6,
          vertical: space4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    ),
    
    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: space4,
        vertical: space4,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: _gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: _gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: _accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: _errorColor),
      ),
    ),
    
    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: _surfaceColor,
      selectedItemColor: _accentColor,
      unselectedItemColor: _gray400,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    dividerTheme: const DividerThemeData(
      color: _gray200,
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    colorScheme: const ColorScheme.dark(
      primary: _accentColor,
      onPrimary: Colors.white,
      secondary: _gray300,
      surface: Color(0xFF1A1A1A),
      background: _primaryColor,
      error: _errorColor,
    ),
    
    scaffoldBackgroundColor: _primaryColor,
    
    // Similar structure for dark theme...
    // (abbreviated for space)
  );
}
