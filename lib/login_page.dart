import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:watermind/register_page.dart';
import 'package:watermind/app_constants.dart';
import 'package:watermind/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Başarılı giriş sonrası HomePage'e yönlendir
      if (!mounted) return; // Widget dispose edilmediyse devam et
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Giriş başarılı ✅")),
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
                "Hoş Geldiniz!",
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
                    SizedBox(height: AppSpacing.large),

                    // Login button
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
                        onPressed: login,
                        child: const Text("Giriş Yap"),
                      ),
                    ),
                    SizedBox(height: AppSpacing.medium),

                    // Forgot + Create Account buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (emailController.text.isNotEmpty) {
                              _auth.sendPasswordResetEmail(
                                email: emailController.text.trim(),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Şifre sıfırlama maili gönderildi 📩")),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            textStyle: AppTextStyles.bodyText1,
                          ),
                          child: const Text("Şifremi Unuttum"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterPage()),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            textStyle: AppTextStyles.bodyText1,
                          ),
                          child: const Text("Hesap Oluştur"),
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
