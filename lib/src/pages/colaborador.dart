class Colaborador {
  final int idx;
  final String estado;
  final String email;
  final String documento;
  final String celular;
  final int nivel;
  final String nombreColaborador;
  final String primerNombre;
  final String segundoNombre;
  final String primerApellido;
  final String segundoApellido;
  final int idxSeccion;
  final String nombreSeccion;
  final String createdBy;
  final DateTime? createdAt;
  final String updateBy;
  final DateTime? updateAt;

  Colaborador({
    required this.idx,
    required this.estado,
    required this.email,
    required this.documento,
    required this.celular,
    required this.nivel,
    required this.nombreColaborador,
    required this.primerNombre,
    required this.segundoNombre,
    required this.primerApellido,
    required this.segundoApellido,
    required this.idxSeccion,
    required this.nombreSeccion,
    required this.createdBy,
    this.createdAt,
    required this.updateBy,
    this.updateAt,
  });
factory Colaborador.fromJson(Map<String, dynamic> json) {
  return Colaborador(
    idx: json['idx'] ?? 0,
    estado: json['estado'] ?? '',
    email: json['email'] ?? '',
    documento: json['documento'] ?? '',
    celular: json['celular'] ?? '',
    nivel: json['nivel'] ?? 0,
    nombreColaborador: json['nombre_colaborador'] ?? 
                      '${json['primer_nombre'] ?? ''} ${json['segundo_nombre'] ?? ''} ${json['primer_apellido'] ?? ''} ${json['segundo_apellido'] ?? ''}',
    primerNombre: json['primer_nombre'] ?? '',
    segundoNombre: json['segundo_nombre'] ?? '',
    primerApellido: json['primer_apellido'] ?? '',
    segundoApellido: json['segundo_apellido'] ?? '',
    idxSeccion: json['idx_seccion'] ?? 0,
    nombreSeccion: json['nombre_seccion'] ?? '',
    createdBy: json['created_by'] ?? '',
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    updateBy: json['update_by'] ?? '',
    updateAt: json['update_at'] != null ? DateTime.tryParse(json['update_at']) : null,
  );
}
}