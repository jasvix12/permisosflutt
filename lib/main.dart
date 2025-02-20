import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Importamos Firebase
import 'src/pages/splash-screen.dart'; // Importamos el archivo splash_screen.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Asegura que todo esté inicializado antes de correr la app
  await Firebase.initializeApp();  // Inicializamos Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Opcional: quita la etiqueta de debug
      home: SplashScreen(),  // Página de carga inicial
    );
  }
}

