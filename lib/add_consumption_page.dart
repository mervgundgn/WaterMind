import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_constant.dart'; // Renkler, textstyle, varsayılan değerler

class AddConsumptionPage extends StatefulWidget {
  const AddConsumptionPage({super.key});

  @override
  State<AddConsumptionPage> createState() => _AddConsumptionPageState();
}

class _AddConsumptionPageState extends State<AddConsumptionPage> {
  String? selectedCategory;
  final TextEditingController _amountController = TextEditingController();

  bool isTimerRunning = false;
  int timerSeconds = 0;
  late final Stopwatch _stopwatch;
  Timer? _timer; // Her saniye litreyi güncellemek için

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  // Kategoriye göre dakika başına litreyi döndür
  double _getConsumptionRatePerMinute(String category) {
    switch (category) {
      case "shower":
        return AppDefaultValues.defaultShowerConsumptionPerMinute;
      case "laundry":
        return AppDefaultValues.defaultLaundryConsumptionPerCycle;
      case "dishes":
        return AppDefaultValues.defaultDishesConsumptionPerMinute;
      case "garden":
        return AppDefaultValues.defaultGardenConsumptionPerMinute;
      case "drinking_water":
      default:
        return AppDefaultValues.defaultDrinkingWaterConsumptionPerGlass;
    }
  }

  // Timer başlat/durdur
  void _toggleTimer() {
    setState(() {
      if (isTimerRunning) {
        _stopwatch.stop();
        _timer?.cancel(); // Timer'ı durdur
      } else {
        _stopwatch.reset();
        _stopwatch.start();

        // Her saniye litreyi güncelle
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (selectedCategory != null) {
            setState(() {
              timerSeconds = _stopwatch.elapsed.inSeconds;
              double minutes = timerSeconds / 60;
              double calculatedLiters =
                  minutes * _getConsumptionRatePerMinute(selectedCategory!);
              _amountController.text = calculatedLiters.toStringAsFixed(2);
            });
          }
        });
      }
      isTimerRunning = !isTimerRunning;
    });
  }

  // Firestore'a veri kaydetme
  Future<void> _saveConsumption() async {
    if (selectedCategory == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen kategori ve miktar girin.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.consumptionHistoryCollection)
          .add({
        "category": selectedCategory,
        "amount": double.tryParse(_amountController.text) ?? 0,
        "time_spent": timerSeconds,
        "timestamp": Timestamp.now(),
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.lightBlue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Text("🎉 Başarılı!"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "Tüketimin başarıyla kaydedildi!",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text("💧 Her damla önemlidir!", textAlign: TextAlign.center),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Tamam 👍",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );

      // Reset
      _timer?.cancel();
      setState(() {
        selectedCategory = null;
        _amountController.clear();
        timerSeconds = 0;
        _stopwatch.reset();
        isTimerRunning = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
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
          "Tüketim Ekle",
          style: AppTextStyles.headline2.copyWith(
            color: AppColors.backgroundLight,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Dropdown ---
            Text("Kategori",
                style: AppTextStyles.subTitle1
                    .copyWith(color: AppColors.backgroundDark)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.mediumGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                DropdownMenuItem(
                    value: "drinking_water",
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/cat_drinking_water.png',
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 8),
                        Text("İçme Suyu"),
                      ],
                    )),
                DropdownMenuItem(
                    value: "shower",
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/cat_shower.png',
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 8),
                        Text("Duş"),
                      ],
                    )),
                DropdownMenuItem(
                    value: "laundry",
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/cat_laundry.png',
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 8),
                        Text("Çamaşır"),
                      ],
                    )),
                DropdownMenuItem(
                    value: "dishes",
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/cat_dishes.png',
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 8),
                        Text("Bulaşık"),
                      ],
                    )),
                DropdownMenuItem(
                    value: "garden",
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/cat_garden_watering.png',
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 8),
                        Text("Bahçe Sulama"),
                      ],
                    )),
              ],
              onChanged: (val) => setState(() => selectedCategory = val),
            ),

            const SizedBox(height: 16),

            // --- Miktar inputu ---
            Text("Miktar (litre)",
                style: AppTextStyles.subTitle1
                    .copyWith(color: AppColors.backgroundDark)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.mediumGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- Timer ---
            Center(
              child: Column(
                children: [
                  Text(
                    "Sayaç: $timerSeconds sn",
                    style: AppTextStyles.headline1
                        .copyWith(color: AppColors.darkGrey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    onPressed: _toggleTimer,
                    child: Text(
                      isTimerRunning ? "Durdur" : "Başlat",
                      style: AppTextStyles.buttonText,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // --- Kaydet Butonu ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveConsumption,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text("Tüketimi Kaydet", style: AppTextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
