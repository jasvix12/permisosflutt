import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Importa el paquete para Google Sign-In
import 'acept-permisos.dart'; // Asegúrate de importar la pantalla de permisos

class LoginScreen extends StatelessWidget {
  // Instancia de GoogleSignIn
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Inicia sesión con Google
      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      if (user != null) {
        // Si el usuario ha iniciado sesión con éxito, navega a la siguiente pantalla
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AceptPermisosScreen(),
          ),
        );
      } else {
        // Si el usuario cancela el inicio de sesión, muestra un mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión cancelado')),
        );
      }
    } catch (error) {
      // Si ocurre algún error, muestra un mensaje
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
            // Icono de perfil en la parte superior
            Image.asset(
              'assets/images/perfil.png', // Ruta del ícono de perfil
              width: 100, // Ajusta el tamaño según lo que necesites
              height: 100,
            ),
            const SizedBox(height: 20), // Espaciado entre el ícono y el botón
            // Botón de Google
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Fondo blanco del botón
                foregroundColor: Colors.black, // Texto negro
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Espaciado del botón
              ),
              icon: Image.asset(
                'assets/images/google.png', // Ruta del logo de Google
                width: 20,
                height: 20,
              ),
              label: const Text(
                'Iniciar sesión con Google',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Llamada al método para iniciar sesión con Google
                signInWithGoogle(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
