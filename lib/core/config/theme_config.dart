import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConfig {
  // Brand Colors
  static const Color primaryColor = Color(0xFFFF6B35); // Vibrant Orange
  static const Color secondaryColor = Color(0xFFF7931E); // Golden Orange
  static const Color accentColor = Color(0xFF4ECDC4); // Turquoise
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimaryColor = Color(0xFF1A1A1A);
  static const Color textSecondaryColor = Color(0xFF6B6B6B);
  static const Color textHintColor = Color(0xFFB0B0B0);
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color infoColor = Color(0xFF29B6F6);
  
  // Feature Colors
  static const Color vegColor = Color(0xFF4CAF50);
  static const Color nonVegColor = Color(0xFFE53935);
  static const Color halalColor = Color(0xFF9C27B0);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircular = 100.0;
  
  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  
  // Icon Sizes
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  
  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeadline = 28.0;
  static const double fontSizeDisplay = 32.0;
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: Colors.grey.shade200,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
        onBackground: textPrimaryColor,
        onError: Colors.white,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: surfaceColor,
        foregroundColor: textPrimaryColor,
        iconTheme: const IconThemeData(color: textPrimaryColor),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: fontSizeXXL,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
      ),
      
      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: fontSizeDisplay,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: fontSizeHeadline,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: fontSizeTitle,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: fontSizeXXL,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: fontSizeL,
          color: textPrimaryColor,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: fontSizeM,
          color: textPrimaryColor,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: fontSizeS,
          color: textSecondaryColor,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: fontSizeL,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingL,
            vertical: paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: fontSizeL,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingL,
            vertical: paddingM,
          ),
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: fontSizeL,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingM,
            vertical: paddingS,
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: fontSizeM,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: paddingM,
          vertical: paddingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: fontSizeM,
          color: textHintColor,
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: fontSizeM,
          color: textSecondaryColor,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        color: cardColor,
        margin: const EdgeInsets.all(paddingS),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: fontSizeS,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: fontSizeS,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: elevationM,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: primaryColor.withOpacity(0.2),
        labelStyle: GoogleFonts.poppins(
          fontSize: fontSizeS,
          color: textPrimaryColor,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingM,
          vertical: paddingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCircular),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: fontSizeXXL,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: fontSizeM,
          color: textSecondaryColor,
        ),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: elevationM,
      ),
    );
  }
  
  // Dark Theme
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
    );
  }
}
