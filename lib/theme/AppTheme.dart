import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color primaryColorLight = Color(0xFF42A5F5);
  static const Color primaryColorDark = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFF00C853);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color successColor = Color(0xFF388E3C);
  static const Color infoColor = Color(0xFF0288D1);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Background colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF5F5F5);
  static const Color backgroundTertiary = Color(0xFFEEEEEE);
  
  // Card colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);
  
  // Status colors
  static const Color statusActive = Color(0xFF4CAF50);
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusCancelled = Color(0xFFE53935);
  static const Color statusCompleted = Color(0xFF3F51B5);
  
  // Specialty colors
  static const Map<String, Color> specialtyColors = {
    'Cardiologist': Color(0xFFE57373),
    'Dermatologist': Color(0xFF81C784),
    'Pediatrician': Color(0xFF64B5F6),
    'Orthopedic Surgeon': Color(0xFFFFD54F),
    'Neurologist': Color(0xFFBA68C8),
    'Generalist': Color(0xFF4DB6AC),
    'Psychiatrist': Color(0xFF9575CD),
    'Ophthalmologist': Color(0xFF4FC3F7),
    'Gynecologist': Color(0xFFF06292),
    'Urologist': Color(0xFF7986CB),
  };
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryColorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, Color(0xFF69F0AE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.25,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.15,
  );
  
  static const TextStyle subtitleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.15,
  );
  
  static const TextStyle subtitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: 0.15,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    letterSpacing: 0.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    letterSpacing: 0.25,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    letterSpacing: 0.4,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 1.25,
  );
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border Radius
  static const double borderRadiusS = 4.0;
  static const double borderRadiusM = 8.0;
  static const double borderRadiusL = 12.0;
  static const double borderRadiusXL = 16.0;
  static const double borderRadiusXXL = 24.0;
  static const double borderRadiusCircular = 100.0;
  
  // Shadows
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: cardShadow.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: cardShadow.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get shadowLarge => [
    BoxShadow(
      color: cardShadow.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
  
  // Get ThemeData
  static ThemeData getThemeData() {
    return ThemeData(
      primaryColor: primaryColor,
      primaryColorLight: primaryColorLight,
      primaryColorDark: primaryColorDark,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: buttonText,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusM),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: buttonText.copyWith(color: primaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusM),
          ),
          side: const BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: buttonText.copyWith(color: primaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingM,
            vertical: spacingS,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: bodyMedium.copyWith(color: textSecondary),
        hintStyle: bodyMedium.copyWith(color: textDisabled),
        errorStyle: bodySmall.copyWith(color: errorColor),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundPrimary,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundTertiary,
        disabledColor: backgroundTertiary.withOpacity(0.5),
        selectedColor: primaryColorLight,
        secondarySelectedColor: accentColor,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingS,
        ),
        labelStyle: bodySmall,
        secondaryLabelStyle: bodySmall.copyWith(color: Colors.white),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusCircular),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: backgroundTertiary,
        thickness: 1,
        space: spacingM,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: bodyMedium.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Helper methods for common UI components
  
  // Status chip based on appointment status
  static Widget getStatusChip(String status) {
    Color chipColor;
    IconData chipIcon;
    
    switch (status.toLowerCase()) {
      case 'active':
      case 'confirmed':
        chipColor = statusActive;
        chipIcon = Icons.check_circle;
        break;
      case 'pending':
      case 'waiting':
        chipColor = statusPending;
        chipIcon = Icons.access_time;
        break;
      case 'cancelled':
        chipColor = statusCancelled;
        chipIcon = Icons.cancel;
        break;
      case 'completed':
        chipColor = statusCompleted;
        chipIcon = Icons.task_alt;
        break;
      default:
        chipColor = infoColor;
        chipIcon = Icons.info;
    }
    
    return Chip(
      label: Text(
        status,
        style: bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: chipColor,
      avatar: Icon(
        chipIcon,
        color: Colors.white,
        size: 16,
      ),
      padding: const EdgeInsets.all(spacingXS),
    );
  }
  
  // Card with consistent styling
  static Widget buildCard({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.all(spacingM),
    Color? color,
    List<BoxShadow>? shadow,
  }) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? cardBackground,
        borderRadius: BorderRadius.circular(borderRadiusM),
        boxShadow: shadow ?? shadowSmall,
      ),
      child: child,
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadiusM),
        child: card,
      );
    }
    
    return card;
  }
  
  // Section header with optional action button
  static Widget buildSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: spacingS,
        top: spacingM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: subtitleLarge,
          ),
          if (actionLabel != null && onActionPressed != null)
            TextButton(
              onPressed: onActionPressed,
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }
  
  // Info row with label and value
  static Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
  
  // Action button with icon and label
  static Widget buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadiusM),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: spacingS,
          horizontal: spacingM,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(spacingM),
              decoration: BoxDecoration(
                color: (color ?? primaryColor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color ?? primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: spacingS),
            Text(
              label,
              style: bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // Empty state placeholder
  static Widget buildEmptyState({
    required String message,
    IconData icon = Icons.info_outline,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: spacingM),
            Text(
              message,
              style: bodyMedium.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: spacingL),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
