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

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');

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
              Image.asset("assets/icons/app_logo_main.png", height: 120),
              SizedBox(height: AppSpacing.large),
              Text(
                "Hoş Geldiniz!",
                style: AppTextStyles.headline1.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: AppSpacing.large),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () async {
                            if (emailController.text.isNotEmpty) {
                              try {
                                await _auth.sendPasswordResetEmail(
                                  email: emailController.text.trim(),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Şifre sıfırlama maili gönderildi 📩"),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Hata: $e"),
                                  ),
                                );
                              }
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
                            Navigator.pushNamed(context, '/register');
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
