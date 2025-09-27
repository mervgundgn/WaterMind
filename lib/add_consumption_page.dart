import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_constants.dart';

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
    _stopwatch = Stopwatch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _amountController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final hrs = (seconds ~/ 3600).toString().padLeft(2, '0');
    final mins = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$hrs:$mins:$secs";
  }

  void _startTimer() {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen önce bir kategori seçin")),
      );
      return;
    }
    _stopwatch.reset();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => timerSeconds = _stopwatch.elapsed.inSeconds);
    });
    setState(() => isTimerRunning = true);
  }

  void _pauseTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() => isTimerRunning = false);
  }

  Future<void> _saveConsumption() async {
    if (selectedCategory == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen kategori ve miktar girin.")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection(FirestoreConstants.consumptionHistoryCollection)
        .add({
      "category": selectedCategory!,
      "amount": double.tryParse(_amountController.text) ?? 0,
      "time_spent": timerSeconds,
      "timestamp": Timestamp.now(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tüketim kaydedildi ✅")),
    );

    setState(() {
      selectedCategory = null;
      _amountController.clear();
      timerSeconds = 0;
      _stopwatch.reset();
      isTimerRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Tüketim Ekle",
            style: AppTextStyles.headline2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori seçimi
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration.collapsed(hintText: ""),
                  items: categoryIcons.keys.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Image.asset(categoryIcons[category]!,
                              width: 30, height: 30),
                          const SizedBox(width: 12),
                          Text(category, style: AppTextStyles.bodyText1),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedCategory = val),
                  hint: const Text("Kategori Seçin"),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.large),

            // Miktar girme
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Miktar (litre)",
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.large),

            // Timer göstergesi
            Center(
              child: Column(
                children: [
                  Text(
                    _formatTime(timerSeconds),
                    style: AppTextStyles.headline1
                        .copyWith(color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isTimerRunning ? _pauseTimer : _startTimer,
                        icon: Icon(
                            isTimerRunning ? Icons.pause : Icons.play_arrow),
                        label:
                        Text(isTimerRunning ? "Durdur" : "Başlat"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _saveConsumption,
                        icon: const Icon(Icons.save),
                        label: const Text("Kaydet"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
