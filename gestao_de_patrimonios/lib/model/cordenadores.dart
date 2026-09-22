// Coordenadores

class Coordenadores {
  final String email;
  final String password;
  final String nome;
  final String departamento;
  final String telefone;
  final String cpf;

  Coordenadores({
    required this.email,
    required this.password,
    required this.nome,
    required this.departamento,
    required this.telefone,
    required this.cpf,
  });

  /// Converte o JSON recebido da API em uma instância de Coordenadores
  factory Coordenadores.fromJson(Map<String, dynamic> json) {
    return Coordenadores(
      email: json['email'],
      password: json['password'],
      nome: json['nome'],
      departamento: json['departamento'],
      telefone: json['telefone'],
      cpf: json['cpf'],
    );
  }

  /// Converte os dados para o formato esperado pelo backend
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
      "nome": nome,
      "departamento": departamento,
      "telefone": telefone,
      "cpf": cpf,
    };
  }
}

