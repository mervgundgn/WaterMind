import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts paketi eklendi

class AppColors {
  // Ana Renkler (Primary Colors)
  static const Color primaryBlue = Color(0xFF2196F3); // Deniz Mavisi
  static const Color primaryGreen = Color(0xFF4CAF50); // Canlı Yeşil

  // Vurgu Renkleri (Accent Colors)
  static const Color accentTeal = Color(0xFF00BCD4); // Turkuaz
  static const Color accentYellow = Color(0xFFFFC107); // Güneş Sarısı

  // Gri Tonları (Grayscale)
  static const Color lightGrey = Color(0xFFEEEEEE); // Açık Gri
  static const Color mediumGrey = Color(0xFF9E9E9E); // Orta Gri
  static const Color darkGrey = Color(0xFF424242); // Koyu Gri

  // Durum Renkleri (Status Colors)
  static const Color successGreen = Color(0xFF8BC34A); // Başarı Yeşili
  static const Color warningOrange = Color(0xFFFF9800); // Uyarı Turuncusu
  static const Color errorRed = Color(0xFFF44336); // Hata Kırmızısı

  // Arka Plan Renkleri (Background Colors)
  static const Color backgroundLight =
  Color(0xFFFFFFFF); // Genel Açık Arka Plan
  static const Color backgroundDark =
  Color(0xFFF5F5F5); // Hafif Gri Tonlu Arka Plan
}

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

class AppSpacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
}

class AppDefaultValues {
  static const int defaultShowerConsumptionPerMinute = 12; // Litre
  static const int defaultDrinkingWaterGoal = 2000; // ml
  static const int defaultLaundryConsumption = 60; // Litre
  static const int defaultDishesConsumption = 30; // Litre
  static const int defaultGardenWateringConsumption = 100; // Litre
}

class FirestoreConstants {
  static const String usersCollection = 'users';
  static const String consumptionHistoryCollection = 'consumption_history';
  static const String goalsField = 'goals';
  static const String userIdField = 'user_id';
  static const String categoryField = 'category';
  static const String amountField = 'amount';
  static const String unitField = 'unit';
  static const String timestampField = 'timestamp';
}