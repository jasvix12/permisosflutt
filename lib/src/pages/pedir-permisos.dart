import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'acept-permisos.dart'; // Importar la pantalla de aceptar permisos
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; //Importar notificaciones locales

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
  int? _autorizadorSeleccionado;
  List<dynamic> _secciones = [];
  bool _isLoading = false; // Estado para manejar la carga

  //Lista de autorizadores
  final List<Map<String, dynamic>> _autorizadores = [
    {"id": 1, "nombre": "Eider Matallana", "isSelected": false},
    {"id": 2, "nombre": "Rodrigo Arturo Carreño Vallejo", "isSelected":false},
  ];

  //Configuracion de notificaciones locales
  final FlutterLocalNotificationsPlugin  flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fetchSecciones();
  _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> _fetchSecciones() async {
    final url = Uri.parse('http://solicitudes.comfacauca.com:7200/api/THPermisos/seccion');
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
        final String formattedTime = _formatearHora(picked);
        if (isSalida) {
          _horaSalida = formattedTime;
        } else {
          _horaLlegada = formattedTime;
        }
      });
    }
  }

  String _formatearHora(TimeOfDay time) {
    final DateTime now = DateTime.now();
    final DateTime dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dateTime); // Formato 12 horas AM/PM
  }

  TimeOfDay _convertirHora(String hora) {
    try {
      hora = hora.replaceAll(RegExp(r'\s+'), ' ').trim();
      hora = hora.replaceAll('\u200B', ''); // Elimina Zero-Width Space

      if (!RegExp(r'^\d{1,2}:\d{2} (AM|PM)$').hasMatch(hora)) {
        throw Exception('Formato de hora no válido: $hora');
      }

      final DateTime dateTime = DateFormat('h:mm a').parse(hora);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      print('Error al convertir la hora: $e');
      throw Exception('Error al convertir la hora: $e');
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

Future<void> _enviarSolicitud() async {
  if (!_isFormValid) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Por favor, completa todos los campos")),
    );
    return;
  }

  setState(() => _isLoading = true);

  final url = Uri.parse('http://solicitudes.comfacauca.com:7200/api/THPermisos/solicitud/crear');

  try {
    // Convertir las horas al formato de 24 horas
    final horaSalida = _convertirHora(_horaSalida);
    final horaLlegada = _convertirHora(_horaLlegada);

print("Autorizador seleccionado antes de enviar: $_autorizadorSeleccionado");
print("Sección seleccionada antes de enviar: $_seccionSeleccionada");
print("Lista de secciones disponibles: $_secciones");

    // Crear el cuerpo de la solicitud
    final body = {
      "tipo": _motivoSeleccionado == "Laboral" ? "L" : "P",
      "fechaSolicitud": DateTime.now().toIso8601String(),
      "diaSolicitud": _selectedDate,
      "horaInicio": "${_selectedDate}T${horaSalida.hour.toString().padLeft(2, '0')}:${horaSalida.minute.toString().padLeft(2, '0')}:00",
      "horaFin": "${_selectedDate}T${horaLlegada.hour.toString().padLeft(2, '0')}:${horaLlegada.minute.toString().padLeft(2, '0')}:00",
      "estado": "P",
      "idxColaborador": 95, // Asegúrate de que este valor sea correcto
      "idxSeccionDesplazamiento": _seccionSeleccionada != null ? int.tryParse(_seccionSeleccionada!) :null,
      "createdBy": 1059600761, // Asegúrate de que este valor sea correcto
      "idxAutorizador": _autorizadorSeleccionado,
    };

    // Enviar la solicitud
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    print("Respuesta del servidor: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (responseData["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"])),
        );

       // Notificar al Autorizador
        await _notificarAutorizador(responseData["data"]);

        // Mostrar notificación local con el nombre del usuario
        await _showLocalNotification(
          "Nueva solicitud de permiso",
          "Ha llegado una notificación de permiso de ${responseData["data"]["nombre_solicitante"]}.",
        );

        // Navegar a AceptPermisosScreen con los datos de la solicitud creada
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AceptPermisosScreen(),
            settings: RouteSettings(arguments: responseData["data"]),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${responseData["message"]}")),
        );
      }
    } else {
      throw Exception('Error al enviar la solicitud: ${response.statusCode}');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

Future<void> _notificarAutorizador(Map<String, dynamic> solicitud) async {
  final url = Uri.parse('http://solicitudes.comfacauca.com:7200/api/THPermisos/email/notificarSolicitud');

  
final body = json.encode({
  "to": "jasbi030803@gmail.com", //Cambia esto por el correo del autorizador
  "id_solicitud": solicitud["idx_solicitud"].toString(),
  "nombre_colaborador": solicitud["nombre_solicitante"],
  "seccion": solicitud["seccion"],
  "tipo_permiso": solicitud["tipo"] == "L" ? "Laboral" : "Personal",
  "fecha_salida": solicitud["dia_solicitud"],
  "hora_salida": solicitud["hora_inicio"],
  "hora_llegada": solicitud["hora_fin"],
  "seccion_destino": solicitud["seccion_destino"],
  "descripcion": solicitud["descripcion"],
  "autorizador": "Eider Matallana",
  "approveUrl": "https://colaboradores.comfacauca.com/rechazar/${solicitud["idx_solicitud"]}",
  "rejectUrl": "https://colaboradores.comfacauca.com/rechazar/${solicitud["idx_solicitud"]}"
});

try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        print("Notificación enviada correctamente");
      } else {
        throw Exception('Error en la respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print("Error al enviar la notificación: $e");
    }
  }

  bool get _isFormValid {
    return _motivoSeleccionado.isNotEmpty &&
        _horaSalida.isNotEmpty &&
        _horaLlegada.isNotEmpty &&
        _selectedDate.isNotEmpty &&
        (_motivoSeleccionado != "Laboral" || _seccionSeleccionada != null) &&
        _autorizadorSeleccionado != null;
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
            if (_motivoSeleccionado.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Autorizador",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Mostrar solo el jefe si el motivo es "Personal"
                  if (_motivoSeleccionado == "Personal")
                    CheckboxListTile(
                      title: Text(_autorizadores[0]['nombre']),
                      value: _autorizadores[0]['isSelected'],
                      onChanged: (value) {
                        setState(() {
                          _autorizadores[0]['isSelected'] = value!;
                          _autorizadorSeleccionado = value ? _autorizadores[0]['id'] : null;
                        });
                      },
                    ),
                  // Mostrar ambos autorizadores para otros motivos
                  if (_motivoSeleccionado != "Personal")
                    ..._autorizadores.map((autorizador) {
                      return CheckboxListTile(
                        title: Text(autorizador['nombre']),
                        value: autorizador['isSelected'],
                        onChanged: (value) {
                          setState(() {
                            autorizador['isSelected'] = value!;
                            if (value) {
                              _autorizadorSeleccionado = autorizador['id'];
                            } else {
                              _autorizadorSeleccionado = null;
                            }
                          });
                        },
                      );
                    }).toList(),
                ],
              ),
            const Spacer(),
          
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading || !_isFormValid ? null : _enviarSolicitud,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid
                      ? const Color.fromARGB(255, 35, 219, 22)
                      : Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: _isLoading
                    ? const Text("Enviando...")
                    : const Text(
                        "Enviar Solicitud",
                        style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    bool isSelected = _motivoSeleccionado == label;

    return GestureDetector(
      onTap: () => _selectMotivo(label),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),  //Duracion de la animacion
        width: isSelected ? 140 : 130, //Aumenta el ancho si esta seleccionado
        height: isSelected ? 50 : 45, //Aumenta la altura si esta seleccionado
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