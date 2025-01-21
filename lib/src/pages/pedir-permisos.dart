import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PedirPermisosScreen extends StatefulWidget {
  @override
  _PedirPermisosScreenState createState() => _PedirPermisosScreenState();
}

class _PedirPermisosScreenState extends State<PedirPermisosScreen> {
  String _selectedDate = "2024-12-26";
  String _horaSalida = "5:21 PM";
  String _horaLlegada = "5:21 PM";
  String _motivoSeleccionado = "";
  String? _seccionSeleccionada;
  String? _autorizadorSeleccionado;

  double _chipSizePersonal = 1.0;
  double _chipSizeSalud = 1.0;
  double _chipSizeEstudio = 1.0;
  double _chipSizeLaboral = 1.0;

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
        _seccionSeleccionada = null; // Reiniciar sección si no es "Laboral".
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
        backgroundColor: const Color.fromRGBO(0, 107, 44, 1),
        title: Center(
          child: const Text("Solicitud de Permiso",
          style: TextStyle( fontSize: 22),
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
            // Fecha, horas y sección destino
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: _buildInputCard(
                      icon: Icons.calendar_today,
                      label: "Fecha",
                      value: _selectedDate,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, true),
                    child: _buildInputCard(
                      icon: Icons.access_time,
                      label: "Salida",
                      value: _horaSalida,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, false),
                    child: _buildInputCard(
                      icon: Icons.access_time,
                      label: "Llegada",
                      value: _horaLlegada,
                      color: Colors.blue,
                    ),
                  ),
                ),
                if (_motivoSeleccionado == "Laboral")
                  const SizedBox(width: 8),
                if (_motivoSeleccionado == "Laboral")
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView(
                              children: ["A", "B", "C"].map((seccion) {
                                return ListTile(
                                  title: Text("Sección $seccion"),
                                  onTap: () {
                                    setState(() {
                                      _seccionSeleccionada = seccion;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                      child: _buildInputCard(
                        icon: Icons.location_city,
                        label: "Destino",
                        value: _seccionSeleccionada ?? "Seleccionar",
                        color: const Color.fromARGB(255, 240, 126, 12),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Motivos
            const Text(
              "Motivo de Permiso",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnimatedChip("Personal", Icons.bedtime, Colors.red,
                    () => _chipSizePersonal),
                _buildAnimatedChip("Salud", Icons.health_and_safety, Colors.green,
                () => _chipSizeSalud),
                _buildAnimatedChip("Estudio", Icons.book, Colors.blue,
                    () => _chipSizeEstudio),
                _buildAnimatedChip(
                    "Laboral", Icons.work, const Color.fromARGB(255, 240, 126, 12),
                    () => _chipSizeLaboral),
              ],
            ),
            const SizedBox(height: 20),
            
            if(_isFormValid)
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

            // Botón de enviar
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
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
                 "seccion": _seccionSeleccionada ?? "Ninguna",  // Valor por defecto
                 "autorizador": _autorizadorSeleccionado ?? "Desconocido",  // Valor por defecto
                };

                Navigator.pop(context, nuevaSolicitud);  // Enviar la solicitud

                },
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
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedChip(
    String label,
    IconData icon,
    Color color,
    Function chipSizeGetter,
  ) {
    return GestureDetector(
      onTap: () {
        _selectMotivo(label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(chipSizeGetter()),
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              if (label == "Personal") _chipSizePersonal = 1.2;
              if (label == "Salud") _chipSizeSalud = 1.2;
              if (label == "Estudio") _chipSizeEstudio = 1.2;
              if (label == "Laboral") _chipSizeLaboral = 1.2;
            });
          },
          onExit: (_) {
            setState(() {
              if (label == "Personal") _chipSizePersonal = 1.0;
              if (label == "Salud") _chipSizeSalud = 1.0;
              if (label == "Estudio") _chipSizeEstudio = 1.0;
              if (label == "Laboral") _chipSizeLaboral = 1.0;
            });
          },
          child: _buildChip(label, icon, color),
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 18),
      backgroundColor: color,
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}