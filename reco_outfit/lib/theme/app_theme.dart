import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_utils.dart';

/// Enhanced theme system with responsive design and dark mode support
class AppTheme {
  // Light Color palette
  static const Color primaryColor = Color(0xFF6750A4);
  static const Color secondaryColor = Color(0xFF7C4DFF);
  static const Color tertiaryColor = Color(0xFF9C27B0);
  static const Color surfaceColor = Colors.white;
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color onPrimaryColor = Colors.white;
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
  static const Color onBackgroundColor = Color(0xFF1C1B1F);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // Dark Color palette
  static const Color darkPrimaryColor = Color(0xFFD0BCFF);
  static const Color darkSecondaryColor = Color(0xFFCDBDFF);
  static const Color darkTertiaryColor = Color(0xFFEFB8FF);
  static const Color darkSurfaceColor = Color(0xFF141218);
  static const Color darkBackgroundColor = Color(0xFF101014);
  static const Color darkOnPrimaryColor = Color(0xFF381E72);
  static const Color darkOnSurfaceColor = Color(0xFFE6E1E5);
  static const Color darkOnBackgroundColor = Color(0xFFE6E1E5);
  static const Color darkErrorColor = Color(0xFFFFB4AB);

  // Get light theme
  static ThemeData get lightTheme => _createLightTheme();
  
  // Get dark theme
  static ThemeData get darkTheme => _createDarkTheme();

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
  );

  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
  );

  // Create light theme
  static ThemeData _createLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: onPrimaryColor,
        onSecondary: onPrimaryColor,
        onSurface: onSurfaceColor,
        onBackground: onBackgroundColor,
        error: errorColor,
      ),
      
      // Apply common theme properties
      textTheme: _createTextTheme(false),
      appBarTheme: _createAppBarTheme(false),
      cardTheme: _createCardTheme(false),
      chipTheme: _createChipTheme(false),
      inputDecorationTheme: _createInputDecorationTheme(false),
      elevatedButtonTheme: _createElevatedButtonTheme(false),
      outlinedButtonTheme: _createOutlinedButtonTheme(false),
      textButtonTheme: _createTextButtonTheme(false),
      bottomNavigationBarTheme: _createBottomNavigationBarTheme(false),
      floatingActionButtonTheme: _createFloatingActionButtonTheme(false),
      snackBarTheme: _createSnackBarTheme(false),
      progressIndicatorTheme: _createProgressIndicatorTheme(false),
      dividerTheme: _createDividerTheme(false),
      iconTheme: _createIconTheme(false),
      listTileTheme: _createListTileTheme(false),
      dialogTheme: _createDialogTheme(false),
      sliderTheme: _createSliderTheme(false),
    );
  }

  // Create dark theme
  static ThemeData _createDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: darkPrimaryColor,
        secondary: darkSecondaryColor,
        tertiary: darkTertiaryColor,
        surface: darkSurfaceColor,
        background: darkBackgroundColor,
        onPrimary: darkOnPrimaryColor,
        onSecondary: darkOnPrimaryColor,
        onSurface: darkOnSurfaceColor,
        onBackground: darkOnBackgroundColor,
        error: darkErrorColor,
      ),
      
      // Apply common theme properties
      textTheme: _createTextTheme(true),
      appBarTheme: _createAppBarTheme(true),
      cardTheme: _createCardTheme(true),
      chipTheme: _createChipTheme(true),
      inputDecorationTheme: _createInputDecorationTheme(true),
      elevatedButtonTheme: _createElevatedButtonTheme(true),
      outlinedButtonTheme: _createOutlinedButtonTheme(true),
      textButtonTheme: _createTextButtonTheme(true),
      bottomNavigationBarTheme: _createBottomNavigationBarTheme(true),
      floatingActionButtonTheme: _createFloatingActionButtonTheme(true),
      snackBarTheme: _createSnackBarTheme(true),
      progressIndicatorTheme: _createProgressIndicatorTheme(true),
      dividerTheme: _createDividerTheme(true),
      iconTheme: _createIconTheme(true),
      listTileTheme: _createListTileTheme(true),
      dialogTheme: _createDialogTheme(true),
      sliderTheme: _createSliderTheme(true),
    );
  }

  // Create responsive theme (backward compatibility)
  static ThemeData createTheme(BuildContext context) {
    return lightTheme;
  }

  static TextTheme _createTextTheme(bool isDark) {
    final Color textColor = isDark ? darkOnSurfaceColor : onSurfaceColor;
    
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: isDark ? darkOnSurfaceColor.withOpacity(0.8) : const Color(0xFF49454F),
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
    );
  }

  static AppBarTheme _createAppBarTheme(bool isDark) {
    return AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? darkOnSurfaceColor : Colors.white,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? darkOnSurfaceColor : Colors.white,
      ),
      iconTheme: IconThemeData(
        color: isDark ? darkOnSurfaceColor : Colors.white,
        size: 24,
      ),
      toolbarHeight: 56,
    );
  }

  static CardThemeData _createCardTheme(bool isDark) {
    return CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      color: isDark ? darkSurfaceColor : surfaceColor,
      shadowColor: Colors.black.withOpacity(0.1),
    );
  }

  static ChipThemeData _createChipTheme(bool isDark) {
    return ChipThemeData(
      backgroundColor: isDark ? darkSurfaceColor.withOpacity(0.3) : const Color(0xFFF3F2F7),
      selectedColor: (isDark ? darkPrimaryColor : primaryColor).withOpacity(0.12),
      deleteIconColor: isDark ? darkPrimaryColor : primaryColor,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: isDark ? darkOnSurfaceColor : onSurfaceColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  static InputDecorationTheme _createInputDecorationTheme(bool isDark) {
    final borderColor = isDark ? Colors.grey[600]! : Colors.grey[300]!;
    final fillColor = isDark ? darkSurfaceColor : Colors.grey[50]!;
    
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? darkPrimaryColor : primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? darkErrorColor : errorColor, width: 1),
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: isDark ? Colors.grey[400] : Colors.grey[500],
      ),
    );
  }

  static ElevatedButtonThemeData _createElevatedButtonTheme(bool isDark) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? darkPrimaryColor : primaryColor,
        foregroundColor: isDark ? darkOnPrimaryColor : onPrimaryColor,
        elevation: 4,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        minimumSize: const Size(120, 48),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _createOutlinedButtonTheme(bool isDark) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? darkPrimaryColor : primaryColor,
        side: BorderSide(color: isDark ? darkPrimaryColor : primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        minimumSize: const Size(120, 48),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextButtonThemeData _createTextButtonTheme(bool isDark) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: isDark ? darkPrimaryColor : primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static BottomNavigationBarThemeData _createBottomNavigationBarTheme(bool isDark) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 4,
      backgroundColor: isDark ? darkSurfaceColor : surfaceColor,
      selectedItemColor: isDark ? darkPrimaryColor : primaryColor,
      unselectedItemColor: isDark ? Colors.grey[400] : const Color(0xFF79747E),
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.normal,
      ),
      selectedIconTheme: const IconThemeData(size: 24),
      unselectedIconTheme: const IconThemeData(size: 22),
    );
  }

  static FloatingActionButtonThemeData _createFloatingActionButtonTheme(bool isDark) {
    return FloatingActionButtonThemeData(
      backgroundColor: isDark ? darkPrimaryColor : primaryColor,
      foregroundColor: isDark ? darkOnPrimaryColor : onPrimaryColor,
      elevation: 4,
      shape: const CircleBorder(),
      iconSize: 24,
    );
  }

  static SnackBarThemeData _createSnackBarTheme(bool isDark) {
    return SnackBarThemeData(
      backgroundColor: isDark ? darkSurfaceColor : onSurfaceColor,
      contentTextStyle: GoogleFonts.inter(
        color: isDark ? darkOnSurfaceColor : surfaceColor,
        fontSize: 14,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static ProgressIndicatorThemeData _createProgressIndicatorTheme(bool isDark) {
    return ProgressIndicatorThemeData(
      color: isDark ? darkPrimaryColor : primaryColor,
      linearTrackColor: isDark ? Colors.grey[700] : const Color(0xFFE7E0EC),
      circularTrackColor: isDark ? Colors.grey[700] : const Color(0xFFE7E0EC),
    );
  }

  static DividerThemeData _createDividerTheme(bool isDark) {
    return DividerThemeData(
      color: isDark ? Colors.grey[700] : Colors.grey[200],
      thickness: 1,
      space: 1,
    );
  }

  static IconThemeData _createIconTheme(bool isDark) {
    return IconThemeData(
      size: 24,
      color: isDark ? darkOnSurfaceColor : onSurfaceColor,
    );
  }

  static ListTileThemeData _createListTileTheme(bool isDark) {
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static DialogThemeData _createDialogTheme(bool isDark) {
    return DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? darkOnSurfaceColor : onSurfaceColor,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: isDark ? darkOnSurfaceColor : onSurfaceColor,
      ),
    );
  }

  static SliderThemeData _createSliderTheme(bool isDark) {
    final primary = isDark ? darkPrimaryColor : primaryColor;
    final onPrimary = isDark ? darkOnPrimaryColor : onPrimaryColor;
    
    return SliderThemeData(
      activeTrackColor: primary,
      inactiveTrackColor: primary.withOpacity(0.3),
      thumbColor: primary,
      overlayColor: primary.withOpacity(0.1),
      valueIndicatorColor: primary,
      valueIndicatorTextStyle: GoogleFonts.inter(
        fontSize: 12,
        color: onPrimary,
      ),
    );
  }

  // Custom colors for specific use cases
  static const Map<String, Color> customColors = {
    'spring': Color(0xFF4CAF50),
    'summer': Color(0xFFFF9800),
    'autumn': Color(0xFF795548),
    'winter': Color(0xFF2196F3),
    'allSeason': Color(0xFF9C27B0),
  };

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
}
