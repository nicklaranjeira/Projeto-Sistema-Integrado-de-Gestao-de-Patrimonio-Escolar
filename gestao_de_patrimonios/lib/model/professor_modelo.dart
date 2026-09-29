class ProfessorModelo {
  final int id;
  final String nome;
  final String email;
  final String? matricula;
  final String? departamento;
  final String? telefone;
  final String status;
  final int totalPatrimoniosAlocados;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;

  ProfessorModelo({
    required this.id,
    required this.nome,
    required this.email,
    this.matricula,
    this.departamento,
    this.telefone,
    required this.status,
    this.totalPatrimoniosAlocados = 0,
    this.dataCriacao,
    this.dataAtualizacao,
  });

  bool get estaAtivo => status.toLowerCase() == 'ativo';
  bool get estaInativo => status.toLowerCase() == 'inativo';

  factory ProfessorModelo.fromJson(Map<String, dynamic> json) {
    return ProfessorModelo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nome: json['nome'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      matricula: json['matricula'] ?? json['registration_number'],
      departamento: json['departamento'] ?? json['department'],
      telefone: json['telefone'] ?? json['phone'],
      status: json['status'] ?? 'ativo',
      totalPatrimoniosAlocados: json['total_patrimonios'] is int
          ? json['total_patrimonios']
          : int.tryParse(json['total_patrimonios']?.toString() ?? '0') ?? 0,
      dataCriacao: json['criado_em'] != null ? DateTime.tryParse(json['criado_em']) : null,
      dataAtualizacao: json['atualizado_em'] != null ? DateTime.tryParse(json['atualizado_em']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'matricula': matricula,
      'departamento': departamento,
      'telefone': telefone,
      'status': status,
      'total_patrimonios': totalPatrimoniosAlocados,
    };
  }

  ProfessorModelo copyWith({
    int? id,
    String? nome,
    String? email,
    String? matricula,
    String? departamento,
    String? telefone,
    String? status,
    int? totalPatrimoniosAlocados,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return ProfessorModelo(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      matricula: matricula ?? this.matricula,
      departamento: departamento ?? this.departamento,
      telefone: telefone ?? this.telefone,
      status: status ?? this.status,
      totalPatrimoniosAlocados: totalPatrimoniosAlocados ?? this.totalPatrimoniosAlocados,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }
}
