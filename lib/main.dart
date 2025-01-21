import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Importa flutter_screenutil
import 'dart:async';
import 'src/pages/login_screen.dart'; // Asegúrate de que la ruta sea correcta

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Tamaño base del diseño
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false, // Opcional: quita la etiqueta de debug
          home: SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  String _displayedText = ""; // Texto que se irá mostrando
  final String _fullText = "Comfacauca"; // Texto completo
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Animación del logo
    _logoController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    );
    _logoController.forward(); // Iniciar la animación del logo

    // Animación letra por letra del texto
    Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });

    // Navegar a la nueva pantalla después del splash
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo que crece
            ScaleTransition(
              scale: _logoAnimation,
              child: Image.asset(
                'assets/images/comlogo.png', // Ruta a tu logo
                width: 100.w, // Escalado automático
                height: 100.h, // Escalado automático
              ),
            ),
            // Espacio entre el logo y el texto
            SizedBox(height: 30.h), // Espaciado ajustable
            // Texto que aparece letra por letra
            Text(
              _displayedText,
              style: TextStyle(
                fontSize: 24.sp, // Escalado automático
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
                color: const Color.fromARGB(255, 0, 53, 106), // Azul oscuro
              ),
            ),
          ],
        ),
      ),
    );
  }
}
