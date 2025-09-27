import 'package:flutter/material.dart';

class AppColors {



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
}

class FirestoreConstants {
}
