import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_constant.dart';

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
  Timer? _timer;
  bool showSaveHighlight = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _amountController.dispose();
    super.dispose();
  }

  double _getConsumptionRatePerMinute(String category) {
    switch (category) {
      case "Duş":
        return AppDefaultValues.defaultShowerConsumptionPerMinute;
      case "Çamaşır_Yıkama":
        return AppDefaultValues.defaultLaundryConsumptionPerMinute;
      case "Bulaşık_Yıkama":
        return AppDefaultValues.defaultDishConsumptionPerMinute;
      case "Bahçe_Sulama":
        return AppDefaultValues.defaultGardenConsumptionPerMinute;
      case "İçme_Suyu":
      default:
        return AppDefaultValues.defaultDrinkingWaterConsumptionPerGlass;
    }
  }

  void _startTimer({bool reset = true}) {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen önce bir kategori seçin")),
      );
      return;
    }

    if (reset) {
      _stopwatch.reset();
      timerSeconds = 0;
      _amountController.text = "0.00";
    }

    _stopwatch.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        timerSeconds = _stopwatch.elapsed.inSeconds;
        double minutes = timerSeconds / 60;
        double calculatedLiters =
            minutes * _getConsumptionRatePerMinute(selectedCategory!);
        _amountController.text = calculatedLiters.toStringAsFixed(2);
      });
    });
    setState(() {
      isTimerRunning = true;
      showSaveHighlight = false;
    });
  }

  void _pauseTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {
      isTimerRunning = false;
    });
  }

  void _resumeTimer() {
    _startTimer(reset: false);
  }

  String _formatTime(int seconds) {
    final hrs = (seconds ~/ 3600).toString().padLeft(2, '0');
    final mins = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$hrs:$mins:$secs";
  }

  double _getWaterLevelFraction() {
    double amount = double.tryParse(_amountController.text) ?? 0;
    double fraction = 1 - (amount / 20);
    return fraction.clamp(0.1, 1.0);
  }

  Future<void> _saveConsumption() async {
    if (selectedCategory == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen kategori ve miktar girin.")),
      );
      return;
    }

    final String category = selectedCategory!;
    final String amount = _amountController.text;
    final String elapsedTime = _formatTime(timerSeconds);

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.consumptionHistoryCollection)
          .add({
        "category": category,
        "amount": double.tryParse(amount) ?? 0,
        "time_spent": timerSeconds,
        "timestamp": Timestamp.now(),
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.lightBlue[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              "🎉 Tüketim Kaydedildi!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueAccent,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text("Kategori: $category",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text("Toplam Su Tüketimi: $amount litre",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text("Geçen Süre: $elapsedTime",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Divider(thickness: 1, color: Colors.blueGrey),
              const SizedBox(height: 8),
              const Text("Tüketiminiz başarıyla kaydedildi!",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Tamam 👍",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );

      _timer?.cancel();
      setState(() {
        selectedCategory = null;
        _amountController.clear();
        timerSeconds = 0;
        _stopwatch.reset();
        isTimerRunning = false;
        showSaveHighlight = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double waterLevelFraction = _getWaterLevelFraction();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Tüketim Ekle",
          style: AppTextStyles.headline2
              .copyWith(color: AppColors.backgroundLight),
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: waterLevelFraction,
                widthFactor: 1.0,
                child: Image.asset(
                  "assets/images/water_level_medium.gif",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Kategori",
                    style: AppTextStyles.subTitle1
                        .copyWith(color: AppColors.backgroundDark)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.mediumGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: "İçme_Suyu",
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/cat_drinking_water.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text("İçme Suyu"),
                          ],
                        )),
                    DropdownMenuItem(
                        value: "Duş",
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/cat_shower.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text("Duş"),
                          ],
                        )),
                    DropdownMenuItem(
                        value: "Çamaşır_Yıkama",
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/cat_laundry.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text("Çamaşır"),
                          ],
                        )),
                    DropdownMenuItem(
                        value: "Bulaşık_Yıkama",
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/cat_dishes.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text("Bulaşık"),
                          ],
                        )),
                    DropdownMenuItem(
                        value: "Bahçe_Sulama",
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/cat_garden_watering.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text("Bahçe Sulama"),
                          ],
                        )),
                  ],
                  onChanged: (val) => setState(() => selectedCategory = val),
                ),
                const SizedBox(height: 16),
                Text("Miktar (litre)",
                    style: AppTextStyles.subTitle1
                        .copyWith(color: AppColors.backgroundDark)),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.mediumGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Su Tüketimi Boyunca Geçen Süre",
                        style: AppTextStyles.headline2.copyWith(
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(timerSeconds),
                        style: AppTextStyles.headline2.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isTimerRunning ? _pauseTimer : _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          elevation: 8,
                          shadowColor: Colors.black54,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                        ),
                        child: Text(
                          isTimerRunning ? "Bitir" : "Başlat",
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_stopwatch.isRunning || timerSeconds > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: isTimerRunning ? _pauseTimer : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentTeal,
                                elevation: 6,
                                shadowColor: Colors.black38,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                "Beklet",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: !isTimerRunning ? _resumeTimer : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentTeal,
                                elevation: 6,
                                shadowColor: Colors.black38,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                "Devam Et",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveConsumption,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: showSaveHighlight
                          ? Colors.orange
                          : AppColors.primaryBlue,
                      shadowColor: const Color.fromARGB(137, 81, 0, 0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text("Tüketimi Kaydet",
                        style: AppTextStyles.buttonText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
