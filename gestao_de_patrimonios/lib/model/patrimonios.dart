// Patrimonios
class Patrimonios {
  final String codigo;
  final String nome;
  final String descricao;
  final String categoria;
  final String marca;
  final String? modelo;
  final String numeroSerie;
  final String? estadoConservacao;
  final String? localizacao;
  final String professorId;
  final String? observacoes;

  Patrimonios({
    required this.codigo,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.marca,
    required this.modelo,
    required this.numeroSerie,
    required this.estadoConservacao,
    required this.localizacao,
    required this.professorId,
    required this.observacoes,
  });

  /// Converte o JSON recebido da API em uma instância de Patrimonios
  factory Patrimonios.fromJson(Map<String, dynamic> json) {
    return Patrimonios(
      codigo: json['codigo'],
      nome: json['nome'],
      descricao: (json['descricao']),
      categoria: (json['categoria']),
      marca: (json['marca']),
      modelo: json['modelo'],
      numeroSerie: json['numeroSerie'],
      estadoConservacao: json['estadoConservacao'],
      localizacao: json['localizacao'],
      professorId: json['professorId'],
      observacoes: json['observacoes'],
    );
  }

  /// Converte os dados para o formato esperado pelo backend
  /// Envia tanto n_do_inventario quanto numero_inventario para garantir compatibilidade
  Map<String, dynamic> toJson() {
    return {
      "codigo": codigo,
      "nome": nome,
      "descricao": descricao,
      "categoria": categoria,
      "marca": marca,
      "modelo": modelo,
      "numeroSerie": numeroSerie,
      "estadoConservacao": estadoConservacao,
      "localizacao": localizacao,
      "professorId": professorId,
      "observacoes": observacoes,
    };
  }
}

// Professores

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

  /// Converte o JSON recebido da API em uma instância de Professores
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

  /// Converte os dados para o formato esperado pelo backend
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

// Cordenador

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
