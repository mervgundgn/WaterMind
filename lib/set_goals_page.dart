import 'package:flutter/material.dart';
import 'app_constants.dart';
import 'home_page.dart';


class SetGoalsPage extends StatefulWidget {
  const SetGoalsPage({Key? key}) : super(key: key);

  @override
  _SetGoalsPageState createState() => _SetGoalsPageState();
}

class _SetGoalsPageState extends State<SetGoalsPage> {
  late Map<String, double> goalMap;

  // Kategoriye karşılık gelen ikon pathleri
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
    // Varsayılan değerler AppDefaultValues üzerinden
    goalMap = {
      "İçme Suyu": AppDefaultValues.defaultDrinkingWaterGoal.toDouble(),
      "Duş": AppDefaultValues.defaultShowerConsumptionPerMinute.toDouble(),
      "Çamaşır": AppDefaultValues.defaultLaundryConsumption.toDouble(),
      "Bulaşık": AppDefaultValues.defaultDishesConsumption.toDouble(),
      "Bahçe Sulama": AppDefaultValues.defaultGardenWateringConsumption.toDouble(),
    };
  }

  // Pratik değer metni hesaplama fonksiyonu
  String getCategoryDisplayText(String category, double value) {
    switch (category) {
      case "İçme Suyu":
        return "${value.toInt()} ml (yaklaşık ${(value / 250).round()} bardak)";
      case "Duş":
        return "${value.toInt()} litre (yaklaşık ${(value / 12).round()} dakika)";
      case "Çamaşır":
        int machines = (value / 60).round();
        machines = machines == 0 ? 1 : machines;
        return "${value.toInt()} litre (yaklaşık $machines makine)";
      case "Bulaşık":
        int machines = (value / 30).round();
        machines = machines == 0 ? 1 : machines;
        return "${value.toInt()} litre (yaklaşık $machines makine)";
      case "Bahçe Sulama":
        int minutes = (value / 10).round();
        minutes = minutes == 0 ? 1 : minutes;
        return "${value.toInt()} litre (yaklaşık $minutes dakika)";
      default:
        return "${value.toInt()} litre";
    }
  }

  void saveGoals() {
    print(goalMap); // test amaçlı console'a yazdır

    // TODO: Firebase Firestore'a kaydetme işlemi
    // FirebaseFirestore.instance.collection(FirestoreConstants.usersCollection)
    //     .doc(userId)
    //     .set({FirestoreConstants.goalsField: goalMap}, SetOptions(merge: true));

    // SnackBar göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Hedefler kaydedildi!"),
        duration: Duration(seconds: 3), // SnackBar 3 saniye görünür
      ),
    );

    // 3 saniye bekleyip anasayfaya yönlendir
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          "Hedeflerini Belirle",
          style: AppTextStyles.headline2.copyWith(color: AppColors.backgroundLight),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hedeflerini Belirle",
              style: AppTextStyles.headline1.copyWith(color: AppColors.darkGrey),
            ),
            const SizedBox(height: AppSpacing.large),
            Expanded(
              child: ListView(
                children: goalMap.keys.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              categoryIcons[category]!,
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(width: AppSpacing.medium),
                            Text(
                              category,
                              style: AppTextStyles.subTitle1.copyWith(color: AppColors.darkGrey),
                            ),
                          ],
                        ),
                        Slider(
                          value: goalMap[category]!,
                          min: 0,
                          max: category == "İçme Suyu" ? 5000 : 500,
                          divisions: category == "İçme Suyu" ? 100 : 50,
                          activeColor: AppColors.primaryGreen,
                          inactiveColor: AppColors.lightGrey,
                          onChanged: (value) {
                            setState(() {
                              goalMap[category] = value;
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
            Center(
              child: ElevatedButton(
                onPressed: saveGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  textStyle: AppTextStyles.buttonText,
                ),
                child: const Text("Hedefleri Kaydet"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
