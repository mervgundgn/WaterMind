import 'package:flutter/material.dart';

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
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle subTitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
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

  static double get defaultDishesConsumptionPerMinute => 0.2;

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
