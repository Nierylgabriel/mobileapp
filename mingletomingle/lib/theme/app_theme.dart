import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── 1. Color Palette (White & Purple Theme) ────────────────────────────────
  static const Color bgMain          = Color(0xFFFFFFFF); // pure white
  static const Color bgSecondary     = Color(0xFFF8F7FC); // soft lavender-white
  static const Color bgCard          = Color(0xFFFFFFFF); // card background
  static const Color bgElevated      = Color(0xFFF3F0FA); // pale lavender chip/elevated

  static const Color primaryPurple   = Color(0xFF7C3AED); // vibrant purple
  static const Color deepPurple      = Color(0xFF5B21B6); // rich violet
  static const Color softPurple      = Color(0xFFA78BFA); // light violet
  static const Color lightPurple     = Color(0xFF8B5CF6); // gradient end
  static const Color purpleGlowColor = Color(0x337C3AED); // soft purple glow

  // Backward-compatibility aliases
  static const Color primaryRed      = primaryPurple;
  static const Color darkRed         = deepPurple;
  static const Color lightRed        = softPurple;
  static const Color redGlow         = purpleGlowColor;
  static const Color primaryPink     = primaryPurple;
  static const Color accentCoral     = Color(0xFFEC4899);
  static const Color accentAmber     = Color(0xFFF59E0B);
  static const Color accentCyan      = Color(0xFF06B6D4);
  static const Color passRed         = Color(0xFFEF4444);
  static const Color likeGreen       = Color(0xFF10B981);

  // ── Text Colors ───────────────────────────────────────────────────────────
  static const Color textPrimary     = Color(0xFF1F1933); // dark charcoal-purple
  static const Color textSecondary   = Color(0xFF777286); // muted gray-purple
  static const Color textMuted       = Color(0xFF9E98AE); // lighter hint text

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color borderDefault   = Color(0xFFE9E3F5); // soft lavender
  static const Color borderLight     = Color(0xFFF3F0FA); // very soft border

  // ── Surfaces & Navigation ─────────────────────────────────────────────────
  static const Color bottomNavBg     = Color(0xFFFFFFFF);
  static const Color bgLight         = bgMain;
  static const Color bgDark          = bgSecondary;
  static const Color cardSurface     = bgCard;

  // ── Gradients ─────────────────────────────────────────────────────────────
  // Gradient: #5B21B6 → #8B5CF6
  static const LinearGradient brandGradient = LinearGradient(
    colors: [deepPurple, lightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantGradient = LinearGradient(
    colors: [primaryPurple, lightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGlowGradient = LinearGradient(
    colors: [Color(0x227C3AED), Color(0x00FFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmGradient = brandGradient;

  static const LinearGradient superlikeGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlay = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x151F1933),
      Color(0x8A1F1933),
      Color(0xD91F1933),
    ],
    stops: [0.0, 0.45, 0.75, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkCardOverlay = cardOverlay;

  // ── Soft Shadows (Premium, No Harsh Shadows) ──────────────────────────────
  static List<BoxShadow> softShadow = [
    const BoxShadow(
      color: Color(0x0C5B21B6),
      blurRadius: 18,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    const BoxShadow(
      color: Color(0x145B21B6),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
    const BoxShadow(
      color: Color(0x081F1933),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> purpleGlowShadow = [
    BoxShadow(
      color: primaryPurple.withAlpha(80),
      blurRadius: 18,
      spreadRadius: 1,
      offset: const Offset(0, 6),
    ),
  ];

  // ── Light Theme Data ──────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgMain,
      primaryColor: primaryPurple,
      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        secondary: deepPurple,
        surface: bgCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        outline: borderDefault,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16, color: textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14, color: textSecondary,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12, color: textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgMain,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderDefault, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSecondary,
        hintStyle: GoogleFonts.poppins(color: textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryPurple,
        thumbColor: primaryPurple,
        inactiveTrackColor: borderDefault,
        overlayColor: primaryPurple.withAlpha(30),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : textMuted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primaryPurple : borderDefault),
      ),
      dividerTheme: const DividerThemeData(color: borderDefault, thickness: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bottomNavBg,
        selectedItemColor: primaryPurple,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      ),
    );
  }

  // Backward-compatibility alias
  static ThemeData get darkTheme => lightTheme;
}
