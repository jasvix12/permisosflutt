import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'pedir-permisos.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

class AceptPermisosScreen extends StatefulWidget {
  @override
  _AceptPermisosScreenState createState() => _AceptPermisosScreenState();
}

class _AceptPermisosScreenState extends State<AceptPermisosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> solicitudesAprobadas = [];
  List<Map<String, dynamic>> nuevasSolicitudes = [];
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLogoutButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchSolicitudes();
  }

  Future<void> _fetchSolicitudes() async {
    final response = await http.get(
      Uri.parse(
          'http://solicitudes.comfacauca.com:7200/api/THPermisos/solicitud/all'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        nuevasSolicitudes = List<Map<String, dynamic>>.from(data);
      });
    } else {
      throw Exception('Failed to load solicitudes');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> cerrarSesion() async {
    try {
      await FirebaseAuth.instance.signOut(); // Cierra la sesión en Firebase
      await _googleSignIn
          .signOut(); // Si estás usando Google Sign-In, cierra la sesión también
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
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/images/comlogo.png',
            width: 40,
            height: 40,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isLogoutButtonPressed = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  _isLogoutButtonPressed = false;
                });
                _showLogoutDialog(context);
              },
              onTapCancel: () {
                setState(() {
                  _isLogoutButtonPressed = false;
                });
              },
              child: Icon(
                Icons.power_settings_new,
                color: _isLogoutButtonPressed ? Colors.red : Colors.white,
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
                        title: Text(
                            "Nueva solicitud: ${solicitud["nombre_solicitante"]}"),
                        subtitle: Text(
                            "Fecha: ${solicitud["dia_solicitud"]}, Hora Inicio: ${solicitud["hora_inicio"]}, Hora Fin: ${solicitud["hora_fin"]}"),
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
                        title: Text(
                            "Permiso aprobado para ${solicitud["nombre_solicitante"]}"),
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

          if (result != null && result is Map<String, String>) {
            setState(() {
              nuevasSolicitudes.add(result);
            });
          } else {
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

  void _showSolicitudDialog(
      BuildContext context, Map<String, dynamic> solicitud) {
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
                solicitudesAprobadas.add(solicitud);
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
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.white)),
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
                child: const Text('Aceptar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}