import 'package:flutter/material.dart';
import 'app_constant.dart'; // Ensure this file defines AppConstants
import 'package:google_fonts/google_fonts.dart'; // Google Fonts paketi eklendi

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 159, 187, 208),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/splash_fish.png",
                width: 200, height: 200), // Splash ekran resmi
            const SizedBox(height: AppSpacing.extraLarge),

            Text(
              "WaterMind",
              style: AppTextStyles.headline1.copyWith(
                fontFamily:
                    GoogleFonts.lobster().fontFamily, // Google Fonts kullanımı
                color: const Color.fromARGB(255, 19, 105, 176),
              ),
            )
          ],
        )));
  }
}
