class UsuarioModelo {
  final int? id;
  final String nome;
  final String email;
  final String papel;
  final String? departamento;
  final String? telefone;
  final String? matricula;
  final String? token;
  final String? refreshToken;

  UsuarioModelo({
    this.id,
    required this.nome,
    required this.email,
    required this.papel,
    this.departamento,
    this.telefone,
    this.matricula,
    this.token,
    this.refreshToken,
  });

  bool get eAdmin => papel.toLowerCase() == 'admin';
  bool get eProfessor => papel.toLowerCase() == 'professor';

  factory UsuarioModelo.fromJson(Map<String, dynamic> json) {
    return UsuarioModelo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      nome: json['nome'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      papel: json['role'] ?? json['papel'] ?? 'professor',
      departamento: json['departamento'] ?? json['department'],
      telefone: json['telefone'] ?? json['phone'],
      matricula: json['matricula'] ?? json['registration_number'],
      token: json['token'] ?? json['access_token'],
      refreshToken: json['refresh_token'] ?? json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'role': papel,
      'departamento': departamento,
      'telefone': telefone,
      'matricula': matricula,
      'token': token,
      'refresh_token': refreshToken,
    };
  }

  UsuarioModelo copyWith({
    int? id,
    String? nome,
    String? email,
    String? papel,
    String? departamento,
    String? telefone,
    String? matricula,
    String? token,
    String? refreshToken,
  }) {
    return UsuarioModelo(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      papel: papel ?? this.papel,
      departamento: departamento ?? this.departamento,
      telefone: telefone ?? this.telefone,
      matricula: matricula ?? this.matricula,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
