import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_constants.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Map<String, double> dailyConsumption = {};
  Map<String, double> weeklyConsumption = {};
  Map<String, double> userGoals = {};

  bool showWeekly = false;
  int _currentIndex = 2;
  bool isLoading = true;

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
    loadDummyData();
  }

  void loadDummyData() {
    userGoals = {
      "İçme Suyu": 2000,
      "Duş": 60,
      "Çamaşır": 60,
      "Bulaşık": 30,
      "Bahçe Sulama": 20,
    };

    dailyConsumption = {
      "İçme Suyu": 1200,
      "Duş": 30,
      "Çamaşır": 30,
      "Bulaşık": 20,
      "Bahçe Sulama": 5,
    };

    weeklyConsumption = {
      "İçme Suyu": 6000,
      "Duş": 200,
      "Çamaşır": 180,
      "Bulaşık": 90,
      "Bahçe Sulama": 50,
    };

    setState(() {
      isLoading = false;
    });
  }

  List<BarChartGroupData> buildBarGroups(Map<String, double> data) {
    return categories.asMap().entries.map((entry) {
      int index = entry.key;
      String category = entry.value;
      double value = data[category] ?? 0;

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
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 10;

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
                return Text("${value.toInt()} L",
                    style: AppTextStyles.caption);
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int i = value.toInt();
                if (i < categories.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      categories[i],
                      style: AppTextStyles.bodyText2,
                      textAlign: TextAlign.center,
                    ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.small),
          child: ListTile(
            leading: Image.asset(
              categoryIcons[category] ?? "",
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) {
                return const Icon(Icons.water_drop);
              },
            ),
            title: Text(category, style: AppTextStyles.subTitle1),
            subtitle: Text(
              goal > 0
                  ? "${consumed.toInt()} L / Hedef: ${goal.toInt()} L"
                  : "${consumed.toInt()} L (hedef yok)",
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
            Text(
              "Tüketim Raporları",
              style: AppTextStyles.headline2
                  .copyWith(color: AppColors.backgroundLight),
            ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.medium),
                    child: Text("Günlük", style: AppTextStyles.bodyText1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.medium),
                    child: Text("Haftalık", style: AppTextStyles.bodyText1),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.large),
              SizedBox(height: 300, child: buildBarChart(data)),
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
          Navigator.pushNamed(context, '/add');
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) Navigator.pushNamed(context, '/home');
          if (i == 1) Navigator.pushNamed(context, '/add');
          if (i == 2) Navigator.pushNamed(context, '/reports');
          if (i == 3) Navigator.pushNamed(context, '/settings');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Ana Sayfa"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Tüketim Ekle"),
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
}
