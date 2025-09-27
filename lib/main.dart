import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'firebase_options.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'add_consumption_page.dart';
import 'reports_page.dart';
import 'package:watermind/set_goals_page.dart';
import 'splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      debugShowCheckedModeBanner: false,
      title: 'WaterMind',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/add': (context) => const AddConsumptionPage(),
        '/reports': (context) => const ReportsPage(),
        '/setGoals': (context) => const SetGoalsPage(),
      },
    );
  }
}
