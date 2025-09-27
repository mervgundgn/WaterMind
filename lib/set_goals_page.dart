import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_constants.dart';
import 'home_page.dart';

class SetGoalsPage extends StatefulWidget {
  const SetGoalsPage({super.key});
  @override
  State<SetGoalsPage> createState() => _SetGoalsPageState();
}

class _SetGoalsPageState extends State<SetGoalsPage> {
  late Map<String, double> goalMap;

  final Map<String, String> categoryIcons = {
    "İçme Suyu": "assets/icons/cat_drinking_water.png",
    "Duş": "assets/icons/cat_shower.png",
    "Çamaşır": "assets/icons/cat_laundry.png",
    "Bulaşık": "assets/icons/cat_dishes.png",
    "Bahçe Sulama": "assets/icons/cat_garden_watering.png",
  };

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    goalMap = {
      "İçme Suyu": 0,
      "Duş": 0,
      "Çamaşır": 0,
      "Bulaşık": 0,
      "Bahçe Sulama": 0,
    };
    _loadGoalsFromFirestore();
  }

  Future<void> _loadGoalsFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['dailyGoals'] != null) {
          final goals = Map<String, dynamic>.from(data['dailyGoals']);
          setState(() {
            goalMap.forEach((key, value) {
              if (goals[key] != null) {
                goalMap[key] = (goals[key] as num).toDouble();
              }
            });
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hedefler yüklenirken hata oluştu: $e")),
      );
    }
  }

  String getCategoryDisplayText(String category, double value) {
    switch (category) {
      case "İçme Suyu":
        return "${value.toStringAsFixed(1)} L (yaklaşık ${(value * 4).round()} bardak)";
      case "Duş":
        if (value == 0) return "0 litre";
        return "${value.toInt()} litre (yaklaşık ${(value / 12).round()} dakika)";
      case "Çamaşır":
        if (value == 0) return "0 makine (0 litre)";
        final litres = (value * 60).toInt(); // 1 makine = 60 litre
        return "${value.toInt()} makine (yaklaşık $litres litre)";
      case "Bulaşık":
        if (value == 0) return "0 makine (0 litre)";
        final litres = (value * 30).toInt(); // 1 makine = 30 litre
        return "${value.toInt()} makine (yaklaşık $litres litre)";
      case "Bahçe Sulama":
        if (value == 0) return "0 litre";
        final minutes = (value / 10).round();
        return "${value.toInt()} litre (yaklaşık $minutes dakika)";
      default:
        return "${value.toInt()} litre";
    }
  }

  Future<void> saveGoals() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc =
        _firestore.collection(FirestoreConstants.usersCollection).doc(user.uid);

    try {
      await userDoc.set({
        "dailyGoals": {
          "İçme Suyu": goalMap["İçme Suyu"],
          "Duş": goalMap["Duş"],
          "Çamaşır": goalMap["Çamaşır"],
          "Bulaşık": goalMap["Bulaşık"],
          "Bahçe Sulama": goalMap["Bahçe Sulama"],
        },
        "goalsSet": true,
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Hedefler kaydedildi!"),
            duration: Duration(seconds: 2)),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hedefler kaydedilirken hata oluştu: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          "Hedeflerini Belirle",
          style: AppTextStyles.headline2
              .copyWith(color: AppColors.backgroundLight),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: ListView(
            children: goalMap.keys.map((category) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(categoryIcons[category]!,
                            width: 40, height: 40),
                        const SizedBox(width: AppSpacing.medium),
                        Text(category,
                            style: AppTextStyles.subTitle1
                                .copyWith(color: AppColors.darkGrey)),
                      ],
                    ),
                    Slider(
                      value: goalMap[category]!,
                      min: 0,
                      max: category == "Çamaşır" || category == "Bulaşık"
                          ? 5
                          : category == "İçme Suyu"
                              ? 5 // artık litre
                              : 500,
                      divisions: category == "Çamaşır" || category == "Bulaşık"
                          ? 5
                          : category == "İçme Suyu"
                              ? 50 // 0.1 litre artış
                              : 50,
                      label: category == "Çamaşır" || category == "Bulaşık"
                          ? "${goalMap[category]!.round()} makine"
                          : "${goalMap[category]!.toStringAsFixed(1)} L",
                      activeColor: AppColors.primaryGreen,
                      inactiveColor: AppColors.lightGrey,
                      onChanged: (value) {
                        setState(() {
                          goalMap[category] =
                              category == "Çamaşır" || category == "Bulaşık"
                                  ? value.roundToDouble()
                                  : value;
                        });
                      },
                    ),
                    Text(
                      getCategoryDisplayText(category, goalMap[category]!),
                      style: AppTextStyles.bodyText1
                          .copyWith(color: AppColors.primaryBlue),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium + MediaQuery.of(context).padding.bottom,
        ),
        child: ElevatedButton(
          onPressed: saveGoals,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            textStyle: AppTextStyles.buttonText,
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text("Hedefleri Kaydet"),
        ),
      ),
    );
  }
}
