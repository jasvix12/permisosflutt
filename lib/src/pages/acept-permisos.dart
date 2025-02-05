import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'pedir-permisos.dart';
import 'login_screen.dart';

class AceptPermisosScreen extends StatefulWidget {
  @override
  _AceptPermisosScreenState createState() => _AceptPermisosScreenState();
}

class _AceptPermisosScreenState extends State<AceptPermisosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> solicitudesAprobadas = [];
  List<Map<String, String>> nuevasSolicitudes = [];
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLogoutButtonPressed = false; // Estado para rastrear si el botón está presionado

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> cerrarSesion() async {
    try {
      await FirebaseAuth.instance.signOut(); // Cierra la sesión en Firebase
      await _googleSignIn.signOut(); // Si estás usando Google Sign-In, cierra la sesión también
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Permisos Comfacauca",
          style: TextStyle(fontSize: 18), // Reducir el tamaño de la fuente
        ),
        centerTitle: true, // Centrar el título
        leading: Container(
          padding: const EdgeInsets.all(8), // Reducir el padding del leading
          child: Image.asset(
            'assets/images/comlogo.png',
            width: 40, // Reducir el tamaño de la imagen
            height: 40,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Ajusta el valor para mover el ícono
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isLogoutButtonPressed = true; // Botón presionado
                });
              },
              onTapUp: (_) {
                setState(() {
                  _isLogoutButtonPressed = false; // Botón liberado
                });
                _showLogoutDialog(context); // Mostrar el diálogo de cierre de sesión
              },
              onTapCancel: () {
                setState(() {
                  _isLogoutButtonPressed = false; // Botón no presionado
                });
              },
              child: Icon(
                Icons.power_settings_new,
                color: _isLogoutButtonPressed ? Colors.red : Colors.white, // Cambia el color del ícono
              ),
            ),
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 4, 168, 72),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de solicitudes
          ListView(
            padding: const EdgeInsets.all(16),
            children: nuevasSolicitudes.isNotEmpty
                ? nuevasSolicitudes.map((solicitud) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.add_box, color: Colors.green),
                        title: Text("Nueva solicitud: ${solicitud["motivo"]}"),
                        subtitle: Text(
                            "Fecha: ${solicitud["fecha"]}, Hora Salida: ${solicitud["horaSalida"]}, Hora Llegada: ${solicitud["horaLlegada"]}"),
                        onTap: () {
                          _showSolicitudDialog(context, solicitud);
                        },
                      ),
                    );
                  }).toList()
                : [
                    const Center(
                      child: Text(
                        "No hay nuevas solicitudes",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ],
          ),
          // Pestaña de solicitudes aprobadas
          ListView(
            padding: const EdgeInsets.all(16),
            children: solicitudesAprobadas.isEmpty
                ? [
                    const Center(
                      child: Text(
                        "No hay solicitudes aprobadas",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ]
                : solicitudesAprobadas.map((solicitud) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.check, color: Colors.green),
                        title: Text(solicitud),
                      ),
                    );
                  }).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PedirPermisosScreen(),
            ),
          );

          // Imprimir para depurar
          print("Solicitudes antes de agregar: $nuevasSolicitudes");
          print("Nueva solicitud recibida: $result");

          if (result != null && result is Map<String, String>) {
            setState(() {
              nuevasSolicitudes.add(result);
            });
          } else {
            // Si no se recibe el tipo esperado
            print("No se recibió el tipo esperado o los datos son nulos.");
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 65, 243, 71),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.green.withOpacity(0.7),
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: "Solicitudes"),
            Tab(icon: Icon(Icons.check), text: "Aprobadas"),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
    );
  }

  void _showSolicitudDialog(BuildContext context, Map<String, String> solicitud) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva solicitud de permiso"),
        content: const Text("¿Quieres aceptar esta solicitud de permiso?"),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                nuevasSolicitudes.remove(solicitud);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              "Rechazar",
              style: TextStyle(color: Color.fromARGB(255, 219, 6, 6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                solicitudesAprobadas.add(
                    "Permiso aprobado para ${solicitud["motivo"]}");
                nuevasSolicitudes.remove(solicitud);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              "Aceptar",
              style: TextStyle(color: Color.fromARGB(255, 24, 117, 19)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Colors.white,
        title: Center(
          child: const Text(
            'Cerrar sesión',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
              fontSize: 18,
            ),
          ),
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  '¿Estás seguro de que deseas cerrar sesión?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 244, 19, 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: Size(120, 50),
                ),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  await cerrarSesion(); // Llama la función para cerrar sesión
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 51, 192, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: Size(120, 50),
                ),
                child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}