import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:watermind/app_constants.dart';
import 'package:watermind/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _notificationsEnabled = true;

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  Future<void> _changePassword() async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      try {
        await _auth.sendPasswordResetEmail(email: user.email!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Şifre sıfırlama maili gönderildi 📩"),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e")),
        );
      }
    }
  }

  Future<void> _updateGoals() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(user.uid)
          .update({
        FirestoreConstants.goalsField: {
          "drinking": AppDefaultValues.defaultDrinkingWaterGoal,
          "shower": AppDefaultValues.defaultShowerConsumptionPerMinute,
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hedefler güncellendi ✅")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          "Profil ve Ayarlar",
          style: AppTextStyles.headline2.copyWith(
            color: AppColors.backgroundLight,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          if (user != null) ...[
            Text(
              user.email ?? "Kullanıcı",
              style: AppTextStyles.headline2.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            Text(
              "UID: ${user.uid}",
              style: AppTextStyles.bodyText1.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          const Divider(color: AppColors.lightGrey),
          ListTile(
            leading: const Icon(Icons.flag, color: AppColors.primaryBlue),
            title: Text(
              "Hedefleri Güncelle",
              style: AppTextStyles.bodyText1.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            onTap: _updateGoals,
          ),
          const Divider(color: AppColors.lightGrey),
          SwitchListTile(
            activeColor: AppColors.primaryGreen,
            title: Text(
              "Bildirimler",
              style: AppTextStyles.bodyText1.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
            },
          ),
          const Divider(color: AppColors.lightGrey),
          ListTile(
            leading: const Icon(Icons.lock_reset, color: AppColors.primaryBlue),
            title: Text(
              "Şifre Değiştir",
              style: AppTextStyles.bodyText1.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            onTap: _changePassword,
          ),
          const Divider(color: AppColors.lightGrey),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.errorRed),
            title: Text(
              "Çıkış Yap",
              style: AppTextStyles.bodyText1.copyWith(
                color: AppColors.errorRed,
              ),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
