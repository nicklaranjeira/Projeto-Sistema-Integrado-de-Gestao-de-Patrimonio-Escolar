/// Modelo de Usuário e Perfil do Sistema
class UserModel {
  final int? id;
  final String nome;
  final String email;
  final String role; // 'admin' ou 'professor'
  final String? departamento;
  final String? telefone;
  final String? matricula;
  final String? token;
  final String? refreshToken;

  UserModel({
    this.id,
    required this.nome,
    required this.email,
    required this.role,
    this.departamento,
    this.telefone,
    this.matricula,
    this.token,
    this.refreshToken,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isProfessor => role.toLowerCase() == 'professor';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      nome: json['nome'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'professor',
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
      'role': role,
      'departamento': departamento,
      'telefone': telefone,
      'matricula': matricula,
      'token': token,
      'refresh_token': refreshToken,
    };
  }

  UserModel copyWith({
    int? id,
    String? nome,
    String? email,
    String? role,
    String? departamento,
    String? telefone,
    String? matricula,
    String? token,
    String? refreshToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      role: role ?? this.role,
      departamento: departamento ?? this.departamento,
      telefone: telefone ?? this.telefone,
      matricula: matricula ?? this.matricula,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
