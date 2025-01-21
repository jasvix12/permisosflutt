import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title:Center( //Usamos center para centrar el titulo
          child:const Text(
            "Permisos Comfacauca",
            style: TextStyle(fontSize: 22),
          ),
        ),
        leading: GestureDetector(
          onTap: () {},
          child: Image.asset('assets/images/comlogo.png'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
        backgroundColor: const Color.fromRGBO(0, 107, 44, 1),
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
      title: Center( // Centrar el título
        child: const Text(
          'Cerrar sesión',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
            fontSize: 18,
          ),
        ),
      ),
      content: SizedBox(  // Usar SizedBox para limitar el tamaño
        width: 300,  // Establecer un ancho específico para el cuadro
        child: Column(
          mainAxisSize: MainAxisSize.min,  // Evitar que se estire el cuadro
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                '¿Estás seguro de que deseas cerrar sesión?',
                textAlign: TextAlign.center,  // Centrar el texto
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,  // Centrar los botones
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
               minimumSize: Size(120, 50), //Ajustamos el tamaño minimo del boton
              ),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 16),  // Espaciado entre botones
            ElevatedButton(
              onPressed: () {
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
                minimumSize: Size(120, 50), // Ajustamos el tamaño minimo del boton
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