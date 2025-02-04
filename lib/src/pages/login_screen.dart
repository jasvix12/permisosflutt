import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth
import 'acept-permisos.dart';

class LoginScreen extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Inicia sesión con Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Si el usuario cancela el inicio de sesión
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión cancelado')),
        );
        return;
      }

      // Obtiene las credenciales de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crea las credenciales de Firebase usando las credenciales de Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Inicia sesión con Firebase usando las credenciales
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Si el inicio de sesión es exitoso, navega a la siguiente pantalla
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AceptPermisosScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al iniciar sesión')),
        );
      }
    } catch (error) {
      // Si ocurre algún error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error durante el inicio de sesión: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(184, 197, 34, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/perfil.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  ),
  icon: const FaIcon(
    FontAwesomeIcons.google, // Icono de Google de FontAwesome
    size: 30.0, // Tamaño del icono
    color: Colors.red, // Color del icono (rojo como Google)
  ),
  label: const Text(
    'Iniciar sesión con Google',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
  onPressed: () {
    signInWithGoogle(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

