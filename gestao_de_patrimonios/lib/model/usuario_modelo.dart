class UsuarioModelo {
  final int id;
  final String nome;
  final String email;
  final String papel;
  final String? telefone;
  final String? departamento;
  final String? matricula;
  final String? cpf;
  final String? password;
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
    this.matricula,
    this.cpf,
    this.password,
    this.professorId,
    this.token,
    this.refreshToken,
  });

  bool get ehAdministrador => papel.toLowerCase() == 'admin' || papel.toLowerCase() == 'coordenador';
  bool get ehDocente => papel.toLowerCase() == 'docente' || papel.toLowerCase() == 'professor';
  bool get eAdmin => ehAdministrador;
  bool get eProfessor => ehDocente;

  factory UsuarioModelo.fromJson(Map<String, dynamic> json) {
    return UsuarioModelo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nome: json['nome'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      papel: json['papel'] ?? json['role'] ?? 'docente',
      telefone: json['telefone'] ?? json['phone'],
      departamento: json['departamento'] ?? json['department'],
      matricula: json['matricula'] ?? json['registration'],
      cpf: json['cpf'],
      password: json['password'] ?? json['senha'],
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
      'role': papel,
      'telefone': telefone,
      'departamento': departamento,
      'matricula': matricula,
      'cpf': cpf,
      'password': password,
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
    String? matricula,
    String? cpf,
    String? password,
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
      matricula: matricula ?? this.matricula,
      cpf: cpf ?? this.cpf,
      password: password ?? this.password,
      professorId: professorId ?? this.professorId,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
