import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 Renkler
class AppColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color accentTeal = Color(0xFF009688);
  static const Color accentYellow = Color(0xFFFFEB3B);

  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);

  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);

  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = Color(0xFF121212);
}

/// ✍️ Metin Stilleri
class AppTextStyles {
  static TextStyle headline1 = GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
    color: AppColors.darkGrey,
  );

  static TextStyle headline2 = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 20.0,
    color: AppColors.darkGrey,
  );

  static TextStyle subTitle1 = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 16.0,
    color: AppColors.darkGrey,
  );

  static TextStyle bodyText1 = GoogleFonts.poppins(
    fontWeight: FontWeight.normal,
    fontSize: 14.0,
    color: AppColors.darkGrey,
  );

  static TextStyle bodyText2 = GoogleFonts.poppins(
    fontWeight: FontWeight.normal,
    fontSize: 12.0,
    color: AppColors.mediumGrey,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontWeight: FontWeight.w300,
    fontSize: 10.0,
    color: AppColors.mediumGrey,
  );

  static TextStyle buttonText = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 14.0,
    color: AppColors.backgroundLight,
  );
}

/// 📏 Boşluklar
class AppSpacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
}

/// ⚙️ Varsayılan Değerler
class AppDefaultValues {
  /// Dakikada duş başına varsayılan su tüketimi (litre)
  static const double defaultShowerConsumptionPerMinute = 10.0;

  /// Günlük varsayılan içme suyu hedefi (litre)
  static const double defaultDrinkingWaterGoal = 2.0;

  static double get defaultLaundryConsumptionPerCycle => 0.83;

  static double get defaultDishConsumptionPerMinute => 0.2;

  static double get defaultGardenConsumptionPerMinute => 16;

  static double get defaultDrinkingWaterConsumptionPerGlass => 0.2;

  /// Diğer varsayılan değerleri buraya ekleyebilirsin
}

/// 🔥 Firestore Sabitleri
class FirestoreConstants {
  static const String usersCollection = "users";
  static const String consumptionHistoryCollection = "consumption_history";

  // Alan adları
  static const String goalsField = "goals";
  static const String dailyConsumptionField = "daily_consumption";
}
