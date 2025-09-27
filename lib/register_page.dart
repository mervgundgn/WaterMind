import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:watermind/app_constants.dart';
import 'package:watermind/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> register() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // ✅ Firestore’a kullanıcı dokümanı ekle
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "email": user.email,
          "dailyConsumption": 0,
          "dailyTarget": 150,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      // ✅ Başarılı AlertDialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Başarılı 🎉"),
          content: const Text("Hesap başarıyla oluşturuldu!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // AlertDialog kapat
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text("Tamam"),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ App Logo
              Image.asset(
                "assets/icons/app_logo_main.png",
                height: 120,
              ),
              SizedBox(height: AppSpacing.large),

              // ✅ Başlık
              Text(
                "Hesap Oluştur",
                style: AppTextStyles.headline1.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: AppSpacing.large),

              // ✅ Form container
              Container(
                padding: EdgeInsets.all(AppSpacing.large),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Email input
                    TextField(
                      controller: emailController,
                      style: AppTextStyles.bodyText1
                          .copyWith(color: AppColors.darkGrey),
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: AppTextStyles.bodyText1,
                        filled: true,
                        fillColor: AppColors.backgroundDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.medium),

                    // Password input
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: AppTextStyles.bodyText1
                          .copyWith(color: AppColors.darkGrey),
                      decoration: InputDecoration(
                        hintText: "Şifre",
                        hintStyle: AppTextStyles.bodyText1,
                        filled: true,
                        fillColor: AppColors.backgroundDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.medium),

                    // Confirm Password input
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: AppTextStyles.bodyText1
                          .copyWith(color: AppColors.darkGrey),
                      decoration: InputDecoration(
                        hintText: "Şifre (Tekrar)",
                        hintStyle: AppTextStyles.bodyText1,
                        filled: true,
                        fillColor: AppColors.backgroundDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.large),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: AppTextStyles.buttonText,
                        ),
                        onPressed: register,
                        child: const Text("Kayıt Ol"),
                      ),
                    ),
                    SizedBox(height: AppSpacing.medium),

                    // Back to Login button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            textStyle: AppTextStyles.bodyText1,
                          ),
                          child: const Text("Zaten hesabım var"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
