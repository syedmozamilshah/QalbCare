import 'package:flutter/material.dart';
import 'package:qalbcare/utils/constants.dart';

/// Islamic-inspired theme for the app
class IslamicTheme {
  /// Get the main theme data for the app
  static ThemeData get lightTheme {
    return ThemeData(
      // Base colors
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryGold,
        surface: AppColors.cardBackground,
        // background: AppColors.background,
        error: AppColors.accentRed,
        onPrimary: Colors.white,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        // onBackground: AppColors.textPrimary,
        onError: Colors.white,
        brightness: Brightness.light,
      ),

      // Text theme with Islamic-inspired typography
      textTheme: const TextTheme(
        // Display styles
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),

        // Headline styles
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        // Body styles
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          height: 1.5,
        ),

        // Label styles
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(IslamicUI.borderRadiusMedium),
          ),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: IslamicUI.elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IslamicUI.borderRadiusMedium),
        ),
        margin: const EdgeInsets.all(IslamicUI.spacingMedium),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: IslamicUI.elevationSmall,
          padding: const EdgeInsets.symmetric(
            horizontal: IslamicUI.spacingLarge,
            vertical: IslamicUI.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(IslamicUI.borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: IslamicUI.spacingLarge,
            vertical: IslamicUI.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(IslamicUI.borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(
            horizontal: IslamicUI.spacingMedium,
            vertical: IslamicUI.spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(IslamicUI.borderRadiusSmall),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: IslamicUI.spacingMedium,
          vertical: IslamicUI.spacingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IslamicUI.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.textSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IslamicUI.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.textSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IslamicUI.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IslamicUI.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.accentRed),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.cardBackground,
        elevation: IslamicUI.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IslamicUI.borderRadiusLarge),
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardBackground,
        elevation: IslamicUI.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(IslamicUI.borderRadiusLarge),
          ),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: IslamicUI.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IslamicUI.borderRadiusLarge),
        ),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textSecondary.withOpacity(.32);
            }
            return AppColors.primaryGreen;
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IslamicUI.borderRadiusSmall / 2),
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textSecondary.withOpacity(.32);
            }
            return AppColors.primaryGreen;
          },
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textSecondary.withOpacity(.32);
            }
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryGreen;
            }
            return Colors.white;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textSecondary.withOpacity(.12);
            }
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryGreen.withOpacity(.5);
            }
            return AppColors.textSecondary.withOpacity(.5);
          },
        ),
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryGreen,
        inactiveTrackColor: AppColors.primaryGreen.withOpacity(.3),
        thumbColor: AppColors.primaryGreen,
        overlayColor: AppColors.primaryGreen.withOpacity(.3),
        valueIndicatorColor: AppColors.primaryGreen,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryGreen,
        circularTrackColor: Colors.white,
        linearTrackColor: Colors.white,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.textSecondary,
        thickness: 1,
        space: IslamicUI.spacingMedium,
      ),

      // Tab bar theme
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.primaryGreen,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryGreen,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
        ),
        elevation: IslamicUI.elevationMedium,
      ),
    );
  }
}
