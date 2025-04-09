class Colaborador {
  final int idx;
  final String? estado;
  final String email;
  final String documento;
  final String celular;
  final int nivel;
  final String nombreColaborador;
  final String? primerNombre;
  final String? segundoNombre;
  final String? primerApellido;
  final String? segundoApellido;
  final int idxSeccion;
  final String nombreSeccion;
  final String? createdBy;
  final DateTime? createdAt;
  final String? updateBy;
  final DateTime? updateAt;

  Colaborador({
    required this.idx,
    this.estado,
    required this.email,
    required this.documento,
    required this.celular,
    required this.nivel,
    required this.nombreColaborador,
    this.primerNombre,
    this.segundoNombre,
    this.primerApellido,
    this.segundoApellido,
    required this.idxSeccion,
    required this.nombreSeccion,
    this.createdBy,
    this.createdAt,
    this.updateBy,
    this.updateAt,
  });

  factory Colaborador.fromJson(Map<String, dynamic> json) {
    return Colaborador(
      idx: json['idx'] as int? ?? 0,
      estado: json['estado'] as String?,
      email: json['email'] as String? ?? '',
      documento: json['documento'] as String? ?? '',
      celular: json['celular'] as String? ?? '',
      nivel: json['nivel'] as int? ?? 0,
      nombreColaborador: (json['nombre_colaborador'] as String?)?.trim() ?? '',
      primerNombre: json['primer_nombre'] as String?,
      segundoNombre: json['segundo_nombre'] as String?,
      primerApellido: json['primer_apellido'] as String?,
      segundoApellido: json['segundo_apellido'] as String?,
      idxSeccion: json['idx_seccion'] as int? ?? 0,
      nombreSeccion: json['nombre_seccion'] as String? ?? '',
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String) 
          : null,
      updateBy: json['update_by'] as String?,
      updateAt: json['update_at'] != null 
          ? DateTime.tryParse(json['update_at'] as String) 
          : null,
    );
  }
}