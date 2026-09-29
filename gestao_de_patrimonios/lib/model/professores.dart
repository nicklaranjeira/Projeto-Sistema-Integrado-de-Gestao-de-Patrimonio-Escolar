class Professores {
  final String nome;
  final String email;
  final String password;
  final String matricula;
  final String departamento;
  final String telefone;
  final String cpf;

  Professores({
    required this.nome,
    required this.email,
    required this.password,
    required this.matricula,
    required this.departamento,
    required this.telefone,
    required this.cpf,
  });

  factory Professores.fromJson(Map<String, dynamic> json) {
    return Professores(
      nome: json['nome'],
      email: json['email'],
      password: json['password'],
      matricula: json['matricula'],
      departamento: json['departamento'],
      telefone: json['telefone'],
      cpf: json['cpf'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nome": nome,
      "email": email,
      "password": password,
      "matricula": matricula,
      "departamento": departamento,
      "telefone": telefone,
      "cpf": cpf,
    };
  }
}
