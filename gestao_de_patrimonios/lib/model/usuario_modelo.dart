class UsuarioModelo {
  final int id;
  final String nome;
  final String email;
  final String papel;
  final String? telefone;
  final String? departamento;
  final int? professorId;
  final String? token;
  final String? refreshToken;

  UsuarioModelo({
    required this.id,
    required this.nome,
    required this.email,
    required this.papel,
    this.telefone,
    this.departamento,
    this.professorId,
    this.token,
    this.refreshToken,
  });

  bool get ehAdministrador => papel.toLowerCase() == 'admin';
  bool get ehDocente => papel.toLowerCase() == 'docente';

  factory UsuarioModelo.fromJson(Map<String, dynamic> json) {
    return UsuarioModelo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nome: json['nome'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      papel: json['papel'] ?? json['role'] ?? 'docente',
      telefone: json['telefone'] ?? json['phone'],
      departamento: json['departamento'] ?? json['department'],
      professorId: json['professor_id'] is int
          ? json['professor_id']
          : int.tryParse(json['professor_id']?.toString() ?? ''),
      token: json['token'] ?? json['access_token'],
      refreshToken: json['refresh_token'] ?? json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'papel': papel,
      'telefone': telefone,
      'departamento': departamento,
      'professor_id': professorId,
      'token': token,
      'refresh_token': refreshToken,
    };
  }

  UsuarioModelo copyWith({
    int? id,
    String? nome,
    String? email,
    String? papel,
    String? telefone,
    String? departamento,
    int? professorId,
    String? token,
    String? refreshToken,
  }) {
    return UsuarioModelo(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      papel: papel ?? this.papel,
      telefone: telefone ?? this.telefone,
      departamento: departamento ?? this.departamento,
      professorId: professorId ?? this.professorId,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
