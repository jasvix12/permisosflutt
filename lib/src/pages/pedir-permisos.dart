import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'acept-permisos.dart'; // Importar la pantalla de aceptar permisos
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'colaborador.dart';

class PedirPermisosScreen extends StatefulWidget {
  final String? userPhotoUrl; //Url de la foto del perfil
  final String? userName;  //Nombre de Usuario
  final String? userEmail; //Nombre del Correo


const PedirPermisosScreen({
          Key? key,
          this.userPhotoUrl,
          this.userName,
          this.userEmail,
          }) : super(key: key);

  @override
  _PedirPermisosScreenState createState() => _PedirPermisosScreenState();
}
class _PedirPermisosScreenState extends State<PedirPermisosScreen> {
  late String _selectedDate;
  Colaborador? _colaborador;
  String _horaSalida = "5:21 PM";
  String _horaLlegada = "5:21 PM";
  String _motivoSeleccionado = "";
  String? _seccionSeleccionada;
  int? _autorizadorSeleccionado;
  List<dynamic> _secciones = [];
  bool _isLoading = false; // Estado para manejar la carga

Future<Colaborador?> fetchColaborador(String email) async {
  if (email.isEmpty) {
    print('Email del usuario no disponible');
  return null;
  }
  
  try {
    final encodedEmail = Uri.encodeComponent(email);
    final url = Uri.parse('http://solicitudes.comfacauca.com:7200/api/THPermisos/colaborador/email/$encodedEmail');
    
    print('Consultando colaborador con email: $email');
    
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    print('Respuesta del servidor (status: ${response.statusCode}), body: ${response.body}');

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
          print('El servidor respondió con una respuesta vacía');
        return null;
      }
      
      try {
        final dynamic decodedData = json.decode(response.body);
        
        if (decodedData is Map<String, dynamic>) {
          print('Datos del colaborador recibidos: $decodedData');
          final colaborador = Colaborador.fromJson(decodedData);
          
          // Verificación adicional
          if (colaborador.email.isEmpty) {
            print('El colaborador obtenido no tiene email válido');
            return null;
          }
          
          return colaborador;
        } else {
          print('Formato de respuesta inesperado: $decodedData');
          return null;
        }
      } catch (e) {
        print('Error al decodificar JSON: $e');
        return null;
      }
    } else {
      print('Error del servidor: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Excepción al obtener colaborador: $e');
    return null;
  }
}
  //Lista de autorizadores
  final List<Map<String, dynamic>> _autorizadores = [
    {"id": 95, "nombre": "Eider Matallana", "isSelected": false},
    {"id": 3, "nombre": "Rodrigo Arturo Carreño Vallejo", "isSelected":false},
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

  // Cargar datos del colaborador si tenemos el email
  if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
    _loadColaboradorData();
  }
}

Future<void> _loadColaboradorData() async {
  if (widget.userEmail == null || widget.userEmail!.isEmpty) {
    print('Email del usuario no disponible');
    return;
  }
  
  setState(() => _isLoading = true);

  try {
    final colaborador = await fetchColaborador(widget.userEmail!);
    
    if (colaborador != null) {
      print('Datos del colaborador obtenidos: ${colaborador.nombreColaborador}');
      setState(() => _colaborador = colaborador);
    } else {
      print('No se pudo obtener información del colaborador');
    }
  } catch (e) {
    print('Error al cargar datos del colaborador: $e');
  } finally {
    setState(() => _isLoading = false);
  }
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

int? idxSeccionDesplazamiento;

 // Solo validar sección para motivo Laboral
    if (_motivoSeleccionado == "Laboral") {
      if (_seccionSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Por favor, selecciona una sección de destino")),
        );
        return;
      }

      idxSeccionDesplazamiento = int.tryParse(_seccionSeleccionada!);
      if (idxSeccionDesplazamiento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("El ID de la sección de destino no es válido")),
        );
        return;
      }
    }

// En el método _enviarSolicitud, modifica el body:
final body = {
  "tipo": _motivoSeleccionado == "Laboral" ? "L"
      : _motivoSeleccionado == "Personal" ? "P"
      : _motivoSeleccionado == "Salud" ? "S"
      : "E", // Estudio
  "fechaSolicitud": DateTime.now().toIso8601String(),
  "diaSolicitud": _selectedDate,
  "horaInicio": "${_selectedDate}T${horaSalida.hour.toString().padLeft(2, '0')}:${horaSalida.minute.toString().padLeft(2, '0')}:00",
  "horaFin": "${_selectedDate}T${horaLlegada.hour.toString().padLeft(2, '0')}:${horaLlegada.minute.toString().padLeft(2, '0')}:00",
  "estado": "P",
  "idxColaborador": _colaborador?.idx ?? 95, // Usar la variable _colaborador
  "idxSeccionDesplazamiento": _motivoSeleccionado == "Laboral" ? idxSeccionDesplazamiento :  null,
  "createdBy": _colaborador?.documento ?? '1059600761', // Usar documento del colaborador o un valor por defecto
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
  if (responseData["success"] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(responseData["message"] ?? "Solicitud enviada correctamente")),
    );

    await _notificarAutorizador(responseData["data"] ?? {});

    await _showLocalNotification(
      "Solicitud enviada",
      "Tu solicitud de permiso ha sido enviada correctamente",
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

final colaborador = _colaborador;

 // Si no tenemos datos del colaborador en el estado, intentar obtenerlos de la respuesta
  final nombreColaborador = colaborador?.nombreColaborador?.trim() ??
                        solicitud["nombre_colaborador"]?.toString().trim() ??
                        'Desconocido';

  final seccionColaborador = colaborador?.nombreSeccion?.toString() ??
                          solicitud["nombre_seccion"]?.toString() ??
                          'Sin sección';
                          
 // Obtener nombre del autorizador
  final autorizador = _autorizadores.firstWhere(
    (a) => a['id'] == solicitud["idxAutorizador"],
    orElse: () => {'nombre': 'Autorizador no especificado'},
  )['nombre'];


final nombreSeccionDestino = _seccionSeleccionada != null 
    ? _secciones.firstWhere(
        (s) => s['idx'].toString() == _seccionSeleccionada,
        orElse: () => {'nombre': 'Desconocida'}
      )['nombre']
    : "No aplica";


  print("Nombre colaborador: $nombreColaborador");
  print("Sección colaborador: $seccionColaborador");

  final body = {
    "to": "jasbi030803@gmail.com",
    "id_solicitud": solicitud["idx"]?.toString() ?? 'N/A',
    "nombre_colaborador": nombreColaborador,
    "seccion": seccionColaborador,
    "tipo_permiso": _getTipoPermiso(solicitud["tipo"]),
    "fecha_salida": solicitud["diaSolicitud"]?.toString() ?? "Fecha no especificada",
    "hora_salida": solicitud["horaInicio"]?.toString() ?? "Hora no especificada",
    "hora_llegada": solicitud["horaFin"]?.toString() ?? "Hora no especificada",
    "seccion_destino": nombreSeccionDestino,
    "descripcion": solicitud["descripcion"]?.toString() ?? "Sin descripción",
    "autorizador": autorizador,
    "approveUrl": "https://colaboradores.comfacauca.com/aprobar/${solicitud["idx"]?.toString() ?? 'N/A'}",
    "rejectUrl": "https://colaboradores.comfacauca.com/rechazar/${solicitud["idx"]?.toString() ?? 'N/A'}"
  };

  print("Body antes de enviar: ${jsonEncode(body)}");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("Respuesta del servidor: ${response.statusCode} - ${response.body}");
  } catch (e) {
    print("Error al notificar: $e");
  }
}

String _getTipoPermiso(dynamic tipo) {
  if (tipo == null) return "Desconocido";
  
  final tipoStr = tipo.toString().toUpperCase();
  switch (tipoStr) {
    case "L": return "Laboral";
    case "P": return "Personal";
    case "S": return "Salud";
    case "E": return "Estudio";
    default: return "Desconocido";
  }
}
void _showUserInfo(BuildContext context) async {
  if (widget.userEmail == null) return;

  // Mostrar loading mientras se obtienen los datos
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final colaborador = await fetchColaborador(widget.userEmail!);
    
    Navigator.pop(context); // Cerrar el loading
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Información del usuario"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.userPhotoUrl != null)
                Center(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.userPhotoUrl!),
                    radius: 30,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                "Nombre: ${colaborador?.nombreColaborador ?? widget.userName ?? 'No disponible'}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Correo: ${widget.userEmail ?? 'No disponible'}"),
              if (colaborador != null) ...[
                const SizedBox(height: 8),
                Text("Documento: ${colaborador.documento}"),
                const SizedBox(height: 8),
                Text("Sección: ${colaborador.nombreSeccion}"),
                const SizedBox(height: 8),
                Text("Celular: ${colaborador.celular}"),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  } catch (e) {
    Navigator.pop(context); // Cerrar el loading
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error al obtener información del usuario")),
    );
  }
}
  bool get _isFormValid {
  return _motivoSeleccionado.isNotEmpty &&
      _horaSalida.isNotEmpty &&
      _horaLlegada.isNotEmpty &&
      _selectedDate.isNotEmpty &&
      _autorizadorSeleccionado != null &&
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
    onPressed: () => Navigator.pop(context),
  ),
  actions: [
    GestureDetector(
      onTap: () => _showUserInfo(context),
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: widget.userPhotoUrl != null
                ? Image.network(
                    widget.userPhotoUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 20);
                    },
                  )
                : Icon(Icons.person, size: 20),
          ),
        ),
      ),
    ),
  ],
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
                                _seccionSeleccionada = seccion['idx'].toString(); //Usar 'idx' en lugar de 'nombre'
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