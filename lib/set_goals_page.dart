import 'package:flutter/material.dart';
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
  }

  String getCategoryDisplayText(String category, double value) {
    switch (category) {
      case "İçme Suyu":
        if (value == 0) return "0 ml";
        return "${value.toInt()} ml (yaklaşık ${(value / 250).round()} bardak)";
      case "Duş":
        if (value == 0) return "0 litre";
        return "${value.toInt()} litre (yaklaşık ${(value / 12).round()} dakika)";
      case "Çamaşır":
        if (value == 0) return "0 makine (0 litre)";
        final litres = (value * AppDefaultValues.defaultLaundryConsumption).toInt();
        return "${value.toInt()} makine (yaklaşık $litres litre)";
      case "Bulaşık":
        if (value == 0) return "0 makine (0 litre)";
        final litres = (value * AppDefaultValues.defaultDishesConsumption).toInt();
        return "${value.toInt()} makine (yaklaşık $litres litre)";
      case "Bahçe Sulama":
        if (value == 0) return "0 litre";
        final minutes = (value / 10).round();
        return "${value.toInt()} litre (yaklaşık $minutes dakika)";
      default:
        return "${value.toInt()} litre";
    }
  }

  void saveGoals() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Hedefler kaydedildi!"), duration: Duration(seconds: 2)),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text("Hedeflerini Belirle", style: AppTextStyles.headline2.copyWith(color: AppColors.backgroundLight)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: ListView(
            children: goalMap.keys.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(categoryIcons[category]!, width: 40, height: 40),
                        const SizedBox(width: AppSpacing.medium),
                        Text(category, style: AppTextStyles.subTitle1.copyWith(color: AppColors.darkGrey)),
                      ],
                    ),
                    Slider(
                      value: goalMap[category]!,
                      min: 0,
                      max: category == "Çamaşır"
                          ? 5
                          : category == "Bulaşık"
                          ? 5
                          : category == "İçme Suyu"
                          ? 5000
                          : 500,
                      divisions: category == "Çamaşır" || category == "Bulaşık"
                          ? 5
                          : category == "İçme Suyu"
                          ? 100
                          : 50,
                      label: category == "Çamaşır" || category == "Bulaşık"
                          ? "${goalMap[category]!.round()} makine"
                          : "${goalMap[category]!.toInt()}",
                      activeColor: AppColors.primaryGreen,
                      inactiveColor: AppColors.lightGrey,
                      onChanged: (value) {
                        setState(() {
                          if (category == "Çamaşır" || category == "Bulaşık") {
                            goalMap[category] = value.roundToDouble();
                          } else {
                            goalMap[category] = value;
                          }
                        });
                      },
                    ),
                    Text(
                      getCategoryDisplayText(category, goalMap[category]!),
                      style: AppTextStyles.bodyText1.copyWith(color: AppColors.primaryBlue),
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
