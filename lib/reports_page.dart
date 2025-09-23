import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_constants.dart';
import 'add_consumption_page.dart';
import 'home_page.dart';
import 'settings_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, double> dailyConsumption = {};
  Map<String, double> weeklyConsumption = {};
  Map<String, double> userGoals = {};

  bool isLoading = true;
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

  @override
  void initState() {
    super.initState();
    fetchGoalsAndConsumption();
  }

  Future<void> fetchGoalsAndConsumption() async {
    String userId = "currentUserId";

    // Kullanıcı hedefleri
    final userDoc = await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(userId)
        .get();

    if (userDoc.exists &&
        userDoc.data()![FirestoreConstants.goalsField] != null) {
      final goals = Map<String, dynamic>.from(
          userDoc.data()![FirestoreConstants.goalsField]);
      userGoals = goals.map((key, value) =>
          MapEntry(key, (value as num).toDouble()));
    } else {
      userGoals = {
        "İçme Suyu": AppDefaultValues.defaultDrinkingWaterGoal.toDouble(),
        "Duş": AppDefaultValues.defaultShowerConsumptionPerMinute.toDouble(),
        "Çamaşır": AppDefaultValues.defaultLaundryConsumption.toDouble(),
        "Bulaşık": AppDefaultValues.defaultDishesConsumption.toDouble(),
        "Bahçe Sulama": AppDefaultValues.defaultGardenWateringConsumption.toDouble(),
      };
    }

    // Tüketimler
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));

    dailyConsumption = {};
    weeklyConsumption = {};

    final snapshot = await _firestore
        .collection(FirestoreConstants.consumptionHistoryCollection)
        .where(FirestoreConstants.userIdField, isEqualTo: userId)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String category = data[FirestoreConstants.categoryField];
      double amount = (data[FirestoreConstants.amountField] as num).toDouble();
      DateTime timestamp =
      (data[FirestoreConstants.timestampField] as Timestamp).toDate();

      if (timestamp.isAfter(todayStart)) {
        dailyConsumption[category] =
            (dailyConsumption[category] ?? 0) + amount;
      }
      if (timestamp.isAfter(weekStart)) {
        weeklyConsumption[category] =
            (weeklyConsumption[category] ?? 0) + amount;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  List<BarChartGroupData> buildBarGroups(Map<String, double> data) {
    return categories.asMap().entries.map((entry) {
      int index = entry.key;
      String category = entry.value;
      double value = data[category] ?? 0;
      double goal = userGoals[category] ?? 0;

      double maxY = (value > goal ? value : goal) * 1.2;

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
    }).toList();
  }

  Widget buildBarChart(Map<String, double> data) {
    double maxY = 0;
    for (var category in categories) {
      double consumed = data[category] ?? 0;
      double goal = userGoals[category] ?? 0;
      if (consumed > maxY) maxY = consumed;
      if (goal > maxY) maxY = goal;
    }
    maxY *= 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barGroups: buildBarGroups(data),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text("${value.toInt()} L", style: AppTextStyles.caption);
                }),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int i = value.toInt();
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
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }

  Widget buildSummaryCards(Map<String, double> data) {
    return Column(
      children: categories.map((category) {
        double consumed = data[category] ?? 0;
        double goal = userGoals[category] ?? 0;

        return Card(
          color: AppColors.backgroundLight,
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.small),
          child: ListTile(
            leading: Image.asset(categoryIcons[category] ?? "",
                width: 32, height: 32, errorBuilder: (_, __, ___) {
                  return const Icon(Icons.water_drop);
                }),
            title: Text(category, style: AppTextStyles.subTitle1),
            subtitle: Text(
              "${consumed.toInt()} L / Hedef: ${goal.toInt()} L",
              style: AppTextStyles.bodyText2,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = showWeekly ? weeklyConsumption : dailyConsumption;

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ToggleButtons(
                isSelected: [!showWeekly, showWeekly],
                onPressed: (index) {
                  setState(() => showWeekly = index == 1);
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: AppColors.primaryBlue,
                color: AppColors.mediumGrey,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                    child: Text("Günlük", style: AppTextStyles.bodyText1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                    child: Text("Haftalık", style: AppTextStyles.bodyText1),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.large),
              SizedBox(
                height: 300,
                child: buildBarChart(data),
              ),
              const SizedBox(height: AppSpacing.large),
              buildSummaryCards(data),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddConsumptionPage()),
          ).then((_) {
            fetchGoalsAndConsumption();
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          switch (i) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Ana Sayfa"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "İstatistik"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ayarlar"),
        ],
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.mediumGrey,
        backgroundColor: AppColors.backgroundLight,
      ),
    );
  }
}
