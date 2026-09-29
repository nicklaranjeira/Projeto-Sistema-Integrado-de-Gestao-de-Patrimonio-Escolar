class PatrimonioModelo {
  final int id;
  final String nome;
  final String numeroTombo;
  final String? numeroSerie;
  final String? categoria;
  final String? localizacao;
  final String? descricao;
  final String status;
  final int? professorResponsavelId;
  final String? professorResponsavelNome;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;

  PatrimonioModelo({
    required this.id,
    required this.nome,
    required this.numeroTombo,
    this.numeroSerie,
    this.categoria,
    this.localizacao,
    this.descricao,
    required this.status,
    this.professorResponsavelId,
    this.professorResponsavelNome,
    this.dataCriacao,
    this.dataAtualizacao,
  });

  bool get estaDisponivel => status.toLowerCase() == 'disponivel';
  bool get estaAlocado => status.toLowerCase() == 'alocado';
  bool get emManutencao => status.toLowerCase() == 'manutencao';
  bool get estaBaixado => status.toLowerCase() == 'baixado';

  factory PatrimonioModelo.fromJson(Map<String, dynamic> json) {
    return PatrimonioModelo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nome: json['nome'] ?? '',
      numeroTombo: json['numero_tombo'] ?? '',
      numeroSerie: json['numero_serie'],
      categoria: json['categoria'],
      localizacao: json['localizacao'],
      descricao: json['descricao'],
      status: json['status'] ?? 'disponivel',
      professorResponsavelId: json['professor_responsavel_id'] is int
          ? json['professor_responsavel_id']
          : int.tryParse(json['professor_responsavel_id']?.toString() ?? ''),
      professorResponsavelNome: json['professor_responsavel_nome'] ?? json['professor_nome'],
      dataCriacao: json['criado_em'] != null ? DateTime.tryParse(json['criado_em']) : null,
      dataAtualizacao: json['atualizado_em'] != null ? DateTime.tryParse(json['atualizado_em']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'numero_tombo': numeroTombo,
      'numero_serie': numeroSerie,
      'categoria': categoria,
      'localizacao': localizacao,
      'descricao': descricao,
      'status': status,
      'professor_responsavel_id': professorResponsavelId,
      'professor_responsavel_nome': professorResponsavelNome,
    };
  }

  PatrimonioModelo copyWith({
    int? id,
    String? nome,
    String? numeroTombo,
    String? numeroSerie,
    String? categoria,
    String? localizacao,
    String? descricao,
    String? status,
    int? professorResponsavelId,
    String? professorResponsavelNome,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return PatrimonioModelo(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      numeroTombo: numeroTombo ?? this.numeroTombo,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      categoria: categoria ?? this.categoria,
      localizacao: localizacao ?? this.localizacao,
      descricao: descricao ?? this.descricao,
      status: status ?? this.status,
      professorResponsavelId: professorResponsavelId ?? this.professorResponsavelId,
      professorResponsavelNome: professorResponsavelNome ?? this.professorResponsavelNome,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }
}
