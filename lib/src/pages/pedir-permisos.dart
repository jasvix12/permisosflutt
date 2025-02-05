import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PedirPermisosScreen extends StatefulWidget {
  @override
  _PedirPermisosScreenState createState() => _PedirPermisosScreenState();
}

class _PedirPermisosScreenState extends State<PedirPermisosScreen> {
  late String _selectedDate;
  String _horaSalida = "5:21 PM";
  String _horaLlegada = "5:21 PM";
  String _motivoSeleccionado = "";
  String? _seccionSeleccionada;
  String? _autorizadorSeleccionado;
  List<dynamic> _secciones = [];

  // Estado para controlar si cada botón está presionado
  Map<String, bool> _isButtonPressed = {
    "Personal": false,
    "Salud": false,
    "Estudio": false,
    "Laboral": false,
    "Enviar": false,
  };

  void initState() {
    super.initState();
    _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fetchSecciones();
  }

  Future<void> _fetchSecciones() async {
    final url = Uri.parse('http://services.comfacauca.com:7100/api/THPermisos/seccion');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _secciones = json.decode(response.body);
        });
      } else {
        throw Exception('Error al cargar las secciones');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isSalida) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final String formattedTime = picked.format(context);
        if (isSalida) {
          _horaSalida = formattedTime;
        } else {
          _horaLlegada = formattedTime;
        }
      });
    }
  }

  void _selectMotivo(String motivo) {
    setState(() {
      _motivoSeleccionado = motivo;
      if (motivo != "Laboral") {
        _seccionSeleccionada = null;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Motivo seleccionado: $motivo")),
    );
  }

  bool get _isFormValid {
    return _motivoSeleccionado.isNotEmpty &&
        _horaSalida.isNotEmpty &&
        _horaLlegada.isNotEmpty &&
        _selectedDate.isNotEmpty &&
        (_motivoSeleccionado != "Laboral" || _seccionSeleccionada != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 168, 72),
        title: const Center(
          child: Text(
            "Solicitud de Permiso",
            style: TextStyle(fontSize: 22),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFixedSizeInputCard(
                  icon: Icons.calendar_today,
                  label: "Fecha",
                  value: _selectedDate,
                  color: Colors.red,
                  onTap: () => _selectDate(context),
                ),
                _buildFixedSizeInputCard(
                  icon: Icons.access_time,
                  label: "Salida",
                  value: _horaSalida,
                  color: Colors.green,
                  onTap: () => _selectTime(context, true),
                ),
                _buildFixedSizeInputCard(
                  icon: Icons.access_time,
                  label: "Llegada",
                  value: _horaLlegada,
                  color: Colors.blue,
                  onTap: () => _selectTime(context, false),
                ),
              ],
            ),

            if (_motivoSeleccionado == "Laboral") ...[
              const SizedBox(height: 20),
              _buildFixedSizeInputCard(
                icon: Icons.location_city,
                label: "Destino",
                value: _seccionSeleccionada ?? "Seleccionar",
                color: const Color.fromARGB(255, 240, 126, 12),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ListView(
                        children: _secciones.map((seccion) {
                          return ListTile(
                            title: Text(seccion['nombre']),
                            onTap: () {
                              setState(() {
                                _seccionSeleccionada = seccion['nombre'];
                              });
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ],

            const SizedBox(height: 20),

            const Text(
              "Motivo de Permiso",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAnimatedChip("Personal", Icons.bedtime, Colors.red),
                    _buildAnimatedChip("Salud", Icons.health_and_safety, Colors.green),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAnimatedChip("Estudio", Icons.book, Colors.blue),
                    _buildAnimatedChip("Laboral", Icons.work, const Color.fromARGB(255, 240, 126, 12)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (_isFormValid)
              DropdownButtonFormField<String>(
                value: _autorizadorSeleccionado,
                items: (_motivoSeleccionado == "Personal"
                        ? ["Eider Matallana"]
                        : ["Eider Matallana", "Rodrigo Arturo Carreño Vallejo"])
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: "Autorizador",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _autorizadorSeleccionado = value;
                  });
                },
              ),

            const Spacer(),

            Center(
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _isButtonPressed["Enviar"] = true;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _isButtonPressed["Enviar"] = false;
                  });
                  if (_motivoSeleccionado.isEmpty ||
                      (_motivoSeleccionado == "Laboral" &&
                          _seccionSeleccionada == null) ||
                      _autorizadorSeleccionado == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Por favor, completa todos los campos antes de enviar.")),
                    );
                    return;
                  }

                  final nuevaSolicitud = {
                    "motivo": _motivoSeleccionado,
                    "fecha": _selectedDate,
                    "horaSalida": _horaSalida,
                    "horaLlegada": _horaLlegada,
                    "seccion": _seccionSeleccionada ?? "Ninguna",
                    "autorizador": _autorizadorSeleccionado ?? "Desconocido",
                  };

                  // Aquí puedes agregar la lógica para enviar la solicitud a tu API o backend
                  _enviarSolicitud(nuevaSolicitud);

                  Navigator.pop(context, nuevaSolicitud);
                },
                onTapCancel: () {
                  setState(() {
                    _isButtonPressed["Enviar"] = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  transform: Matrix4.identity()..scale(_isButtonPressed["Enviar"]! ? 1.1 : 1.0),
                  child: ElevatedButton.icon(
                    onPressed: () {}, // El evento onPressed se maneja en onTapUp
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 35, 219, 22),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text(
                      "Enviar Solicitud",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enviarSolicitud(Map<String, dynamic> solicitud) async {
    final url = Uri.parse('http://services.comfacauca.com:7100/api/THPermisos/solicitud');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(solicitud),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Solicitud enviada con éxito")),
        );
      } else {
        throw Exception('Error al enviar la solicitud');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al enviar la solicitud: $e")),
      );
    }
  }

  Widget _buildFixedSizeInputCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedChip(
    String label,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isButtonPressed[label] = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isButtonPressed[label] = false;
        });
        _selectMotivo(label);
      },
      onTapCancel: () {
        setState(() {
          _isButtonPressed[label] = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isButtonPressed[label]! ? 1.1 : 1.0),
        width: 130,
        height: 45,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}