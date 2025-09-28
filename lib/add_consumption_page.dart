import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, double> userGoals = {};
  List<Map<String, dynamic>> addedConsumptions = [];

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
    _fetchUserGoals();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserGoals() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final goalsRaw = snapshot.data()?['dailyGoals'] ?? {};
    setState(() {
      userGoals = {
        for (var k in goalsRaw.keys) k: (goalsRaw[k] as num).toDouble()
      };
    });
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
      setState(() {
        timerSeconds = _stopwatch.elapsed.inSeconds;
        final autoAmount = timerSeconds * 0.2;
        _amountController.text = autoAmount.toStringAsFixed(1);
      });
    });

    setState(() => isTimerRunning = true);
  }

  void _pauseTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() => isTimerRunning = false);
  }

  String _feedbackMessage() {
    if (selectedCategory == null) return "";
    double target = userGoals[selectedCategory!] ?? 0;
    double currentAmount = double.tryParse(_amountController.text) ?? 0;

    if (currentAmount >= target) {
      return "Hedefe ulaştın! Harika! 👏";
    } else if (currentAmount >= target * 0.5) {
      return "Yarı yoldasın, devam et!";
    } else {
      return "Henüz hedefin altında, dikkat et 💧";
    }
  }

  Color _feedbackColor() {
    if (selectedCategory == null) return AppColors.mediumGrey;
    double target = userGoals[selectedCategory!] ?? 0;
    double currentAmount = double.tryParse(_amountController.text) ?? 0;

    if (currentAmount >= target) {
      return AppColors.primaryGreen;
    } else if (currentAmount >= target * 0.5) {
      return AppColors.accentYellow;
    } else {
      return AppColors.warningOrange;
    }
  }

  Future<void> _saveConsumption() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (selectedCategory == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen kategori ve miktar girin.")),
      );
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    final userDoc =
        _firestore.collection(FirestoreConstants.usersCollection).doc(user.uid);

    try {
      await _firestore
          .collection(FirestoreConstants.consumptionHistoryCollection)
          .add({
        "userId": user.uid,
        "category": selectedCategory!,
        "amount": amount,
        "time_spent": timerSeconds,
        "timestamp": Timestamp.now(),
      });

      final snapshot = await userDoc.get();
      double currentDailyConsumption = 0;

      if (snapshot.exists && snapshot.data()?['dailyConsumption'] != null) {
        currentDailyConsumption =
            (snapshot.data()?['dailyConsumption'] as num).toDouble();
      }

      currentDailyConsumption += amount;

      await userDoc.set({
        "dailyConsumption": currentDailyConsumption,
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tüketim kaydedildi ✅")),
      );

      setState(() {
        addedConsumptions.add({
          "category": selectedCategory!,
          "amount": amount,
        });
        selectedCategory = null;
        _amountController.clear();
        timerSeconds = 0;
        _stopwatch.reset();
        isTimerRunning = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kaydederken hata oluştu: $e")),
      );
    }
  }

  void _deleteConsumption(int index) {
    setState(() {
      addedConsumptions.removeAt(index);
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
                          const SizedBox(width: 12),
                          if (userGoals[category] != null)
                            Text(
                              "(Hedef: ${userGoals[category]?.toInt()} L)",
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.primaryBlue),
                            ),
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
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.large),

            // Timer + butonlar
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
                        label: Text(isTimerRunning ? "Durdur" : "Başlat"),
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
                  const SizedBox(height: AppSpacing.medium),
                  if (selectedCategory != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      decoration: BoxDecoration(
                        color: _feedbackColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _feedbackMessage(),
                        style: AppTextStyles.subTitle1
                            .copyWith(color: AppColors.darkGrey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.large),

            // 📌 Listeyi buraya aldım, butonlardan hemen sonra geliyor
            Expanded(
              child: addedConsumptions.isEmpty
                  ? const Center(
                      child: Text("Henüz kayıt yok"),
                    )
                  : ListView.builder(
                      itemCount: addedConsumptions.length,
                      itemBuilder: (context, index) {
                        final item = addedConsumptions[index];
                        final amount =
                            (item['amount'] is num) ? item['amount'] : 0.0;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          child: ListTile(
                            leading: const Icon(Icons.water_drop,
                                color: AppColors.primaryBlue),
                            title: Text("${item['category']}"),
                            subtitle: Text("${amount.toString()} L"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: AppColors.warningOrange),
                              onPressed: () => _deleteConsumption(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
