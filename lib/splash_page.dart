import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_constants.dart';

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
    await Future.delayed(const Duration(seconds: 2));
    final current = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    if (current != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 159, 187, 208),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/splash_fish.png", width: 200, height: 200),
            const SizedBox(height: AppSpacing.extraLarge),
            Text(
              "WaterMind",
              style: AppTextStyles.headline1.copyWith(
                color: const Color.fromARGB(255, 19, 105, 176),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
