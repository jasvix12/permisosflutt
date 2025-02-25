import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Importamos Firebase
import 'src/pages/splash-screen.dart'; // Importamos el archivo splash_screen.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

