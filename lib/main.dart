import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// firebase_options.dart dosyası, FlutterFire configure ile otomatik oluşur
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter motorunu başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterMind',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Text("WaterMind App"), // Şimdilik basit bir widget
    );
  }
}