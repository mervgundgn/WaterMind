import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fishController;
  int _currentIndex = 0;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fishController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _fishController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
          body: Center(child: Text("Kullanıcı giriş yapmamış")));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Su Akışı"),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primaryBlue),
            onPressed: () => Navigator.pushNamed(context, "/settings"),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final docData = snapshot.data?.data() as Map<String, dynamic>?;

// Firestore'dan kategorilere göre günlük hedefleri al
          final userGoalsRaw = docData?["dailyGoals"] ?? {};
          double dailyTarget = 0;
          userGoalsRaw.forEach((key, value) {
            dailyTarget += (value as num).toDouble();
          });

// Günlük tüketim miktarı
          final dailyConsumption = (docData?["dailyConsumption"] ?? 0) as num;

          if (!_fishController.isAnimating)
            _fishController.repeat(reverse: true);

          double waterLevel = ((dailyTarget - dailyConsumption) / dailyTarget)
              .clamp(0.0, 1.0)
              .toDouble();
// Tüketim hedefi aşıldıkça waterLevel azalacak, hedefin altında kaldıkça artacak

          String waterImage = "assets/images/water_level_low.gif";
          if (waterLevel > 0.66) {
            waterImage = "assets/images/water_level_high.gif";
          } else if (waterLevel > 0.33) {
            waterImage = "assets/images/water_level_medium.gif";
          }

          String fishImage = "assets/images/home_fish_normal.png";
          String fishMessage =
              "Kontrollü şekilde su tüketimine devam edebilirsin! 🚰 ";
          Color bubbleColor = AppColors.accentTeal;

          if (waterLevel > 0.8) {
            fishImage = "assets/images/home_fish_happy.png";
            fishMessage =
                "Harika, bugün su israfı yapmadın 👏 Hedeflerin doğrultusunda ilerliyorsun.";
            bubbleColor = AppColors.accentTeal;
          } else if (waterLevel < 0.3) {
            fishImage = "assets/images/home_fish_sad_thinking.png";
            fishMessage =
                "Bugün biraz daha su tasarrufuna dikkat etmelisin! Hedef günlük tüketimini aştın 💧";
            bubbleColor = AppColors.warningOrange;
          }

          return Column(
            children: [
              const SizedBox(height: 16),
              Text("Günlük Tüketim",
                  style: AppTextStyles.headline2
                      .copyWith(color: AppColors.primaryBlue)),
              const SizedBox(height: 4),
              Text("$dailyConsumption litre / $dailyTarget litre",
                  style: AppTextStyles.bodyText1
                      .copyWith(color: AppColors.darkGrey)),
              const SizedBox(height: AppSpacing.large),
              Expanded(
                flex: 6,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    Image.asset("assets/images/home_lake_background.png",
                        width: double.infinity, fit: BoxFit.cover),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(waterImage,
                          width: double.infinity, fit: BoxFit.cover),
                    ),
                    AnimatedBuilder(
                      animation: _fishController,
                      builder: (context, child) {
                        return Positioned(
                          bottom: 100 + 20 * _fishController.value,
                          child:
                              Image.asset(fishImage, width: 120, height: 120),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.medium, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/ui_speech_bubble.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Text(
                      fishMessage,
                      style: AppTextStyles.subTitle1
                          .copyWith(color: AppColors.darkGrey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 1) Navigator.pushNamed(context, "/add");
          if (i == 2) Navigator.pushNamed(context, "/reports");
          if (i == 3) Navigator.pushNamed(context, "/settings");
        },
        items: [
          BottomNavigationBarItem(
            icon:
                Image.asset("assets/icons/nav_home.png", width: 24, height: 24),
            label: "Ana Sayfa",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/ui_checkmark.png",
                width: 29, height: 29),
            label: "Tüketim Ekle",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/nav_reports.png",
                width: 24, height: 24),
            label: "İstatistik",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/nav_settings.png",
                width: 24, height: 24),
            label: "Ayarlar",
          ),
        ],
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.mediumGrey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
