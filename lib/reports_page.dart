import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_constants.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool showWeekly = false;
  int _currentIndex = 1;

  final List<String> categories = [
    "İçme Suyu",
    "Duş",
    "Çamaşır",
    "Bulaşık",
    "Bahçe Sulama",
  ];

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
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) return const Center(child: Text("Kullanıcı bulunamadı"));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Row(
          children: [
            Image.asset("assets/icons/nav_reports.png",
                width: 24, height: 24, color: Colors.white),
            const SizedBox(width: 8),
            Text("Tüketim Raporları",
                style: AppTextStyles.headline2
                    .copyWith(color: AppColors.backgroundLight)),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection(FirestoreConstants.usersCollection)
            .doc(user.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text("Kullanıcı verisi bulunamadı"));
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;

          final userGoalsRaw = userData['dailyGoals'] ?? {};
          final Map<String, double> userGoals = {};

          for (var category in categories) {
            double rawGoal = (userGoalsRaw[category] ?? 0).toDouble();
            double convertedGoal = rawGoal;

            // Çamaşır ve Bulaşık hedeflerini Litre'ye çevir:
            if (category == "Çamaşır") {
              convertedGoal = rawGoal * 60; // 1 Makine = 60 Litre
            } else if (category == "Bulaşık") {
              convertedGoal = rawGoal * 30; // 1 Makine = 30 Litre
            }

            userGoals[category] = convertedGoal;
          }

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection(FirestoreConstants.consumptionHistoryCollection)
                .where("userId", isEqualTo: user.uid)
                .snapshots(),
            builder: (context, consumptionSnapshot) {
              if (consumptionSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              Map<String, double> dailyConsumption = {
                for (var cat in categories) cat: 0
              };
              Map<String, double> weeklyConsumption = {
                for (var cat in categories) cat: 0
              };

              final now = DateTime.now();
              final startOfDay = DateTime(now.year, now.month, now.day);
              final startOfWeek =
                  startOfDay.subtract(Duration(days: now.weekday - 1));

              for (var doc in consumptionSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final category = data['category'] as String?;
                final amount = (data['amount'] as num?)?.toDouble() ?? 0;
                final timestamp = (data['timestamp'] as Timestamp).toDate();

                if (category != null) {
                  if (timestamp.toUtc().isAfter(startOfDay.toUtc()))
                    dailyConsumption[category] =
                        (dailyConsumption[category] ?? 0) + amount;

                  if (timestamp.toUtc().isAfter(startOfWeek.toUtc()))
                    weeklyConsumption[category] =
                        (weeklyConsumption[category] ?? 0) + amount;
                }
              }

              final data = showWeekly ? weeklyConsumption : dailyConsumption;

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ToggleButtons(
                        isSelected: [!showWeekly, showWeekly],
                        onPressed: (index) =>
                            setState(() => showWeekly = index == 1),
                        borderRadius: BorderRadius.circular(8),
                        selectedColor: AppColors.primaryBlue,
                        color: AppColors.mediumGrey,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.medium),
                            child:
                                Text("Günlük", style: AppTextStyles.bodyText1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.medium),
                            child: Text("Haftalık",
                                style: AppTextStyles.bodyText1),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.large),
                      SizedBox(
                          height: 300, child: buildBarChart(data, userGoals)),
                      const SizedBox(height: AppSpacing.large),
                      buildSummaryCards(data, userGoals),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/add'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          if (i == 1) Navigator.pushReplacementNamed(context, '/reports');
          if (i == 2) Navigator.pushReplacementNamed(context, '/settings');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Ana Sayfa"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "İstatistik"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ayarlar"),
        ],
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.mediumGrey,
        backgroundColor: AppColors.backgroundLight,
      ),
    );
  }

  Widget buildBarChart(Map<String, double> data, Map<String, double> goals,
      {bool isDaily = true}) {
    double maxY;

    if (isDaily) {
      // Günlük grafik 0-300 arası
      maxY = 300;
    } else {
      // Haftalık grafik otomatik max
      maxY = 0;
      for (final category in categories) {
        final consumed = data[category] ?? 0;
        final goal = goals[category] ?? 0;
        if (consumed > maxY) maxY = consumed;
        if (goal > maxY) maxY = goal;
      }
      maxY = (maxY == 0 ? 10 : maxY * 1.2);
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barGroups: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final value = data[category] ?? 0;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: AppColors.primaryBlue,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) =>
                  Text("${value.toInt()} L", style: AppTextStyles.caption),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < categories.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(categories[i],
                        style: AppTextStyles.bodyText2,
                        textAlign: TextAlign.center),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }


  Widget buildSummaryCards(
      Map<String, double> data, Map<String, double> goals) {
    return Column(
      children: categories.map((category) {
        final consumed = data[category] ?? 0;
        final goal = goals[category] ?? 0;

        //Tüm değerleri virgülden sonra 1 basamak hassasiyetle Litre olarak göster
        final consumedText = consumed.toStringAsFixed(1);
        final goalText = goal.toStringAsFixed(1);
        const unit = "L";

        return Card(
          color: AppColors.backgroundLight,
          elevation: 2.0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.small),
          child: ListTile(
            leading: Image.asset(
              categoryIcons[category] ?? "",
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) => const Icon(Icons.water_drop),
            ),
            title: Text(category, style: AppTextStyles.subTitle1),
            subtitle: Text(
              goal > 0
                  ? "${consumedText} ${unit} / Hedef: ${goalText} ${unit}"
                  : "${consumedText} ${unit} (hedef yok)",
              style: AppTextStyles.bodyText2,
            ),
          ),
        );
      }).toList(),
    );
  }
}
