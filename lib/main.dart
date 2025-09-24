import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // Firebase CLI ile oluşturduğun dosya
import 'login_page.dart'; // LoginPage dosyan
import 'register_page.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Flutter ve Firebase’in hazır olması için gerekli
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // firebase_options.dart’den gelen ayarlar
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WaterMind App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          const AuthWrapper(), // Kullanıcının login durumuna göre sayfa göster
    );
  }
}

// Kullanıcı giriş yapmış mı kontrol eden widget
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream:
          FirebaseAuth.instance.authStateChanges(), // Kullanıcı durumunu dinler
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage(); // Giriş yapılmışsa ana sayfa
        }
        return const LoginPage(); // Giriş yoksa login sayfası
      },
    );
  }
}

// Basit bir HomePage örneği
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Hoşgeldiniz!'),
      ),
    );
  }
}
