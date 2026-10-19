class PatrimonioModelo {
  final int id;
  final String nome;
  final String numeroTombo;
  final String? numeroSerie;
  final String? categoria;
  final String? marca;
  final String? modelo;
  final String? localizacao;
  final String descricao;
  final String? observacoes;
  final String status;
  final int? professorResponsavelId;
  final String? professorResponsavelNome;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;
  final DateTime? dataAtribuicao;

  PatrimonioModelo({
    int? id,
    String? nome,
    String? numeroTombo,
    String? tombamento,
    this.numeroSerie,
    this.categoria,
    this.marca,
    this.modelo,
    this.localizacao,
    String? descricao,
    this.observacoes,
    String? status,
    int? professorResponsavelId,
    int? professorId,
    String? professorResponsavelNome,
    String? professorNome,
    this.dataCriacao,
    this.dataAtualizacao,
    this.dataAtribuicao,
  })  : id = id ?? 0,
        nome = nome ?? descricao ?? '',
        numeroTombo = numeroTombo ?? tombamento ?? '',
        descricao = descricao ?? nome ?? '',
        status = status ?? 'disponivel',
        professorResponsavelId = professorResponsavelId ?? professorId,
        professorResponsavelNome = professorResponsavelNome ?? professorNome;

  int? get professorId => professorResponsavelId;
  String? get professorNome => professorResponsavelNome;
  String get tombamento => numeroTombo;

  bool get estaDisponivel => status.toLowerCase() == 'disponivel';
  bool get estaAlocado => status.toLowerCase() == 'alocado' || status.toLowerCase() == 'em_uso';
  bool get emManutencao => status.toLowerCase() == 'manutencao';
  bool get estaBaixado => status.toLowerCase() == 'baixado';

  bool get eDisponivel => estaDisponivel;
  bool get eEmUso => estaAlocado;
  bool get eEmManutencao => emManutencao;

  factory PatrimonioModelo.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic val) {
      if (val is int) return val;
      if (val == null) return null;
      return int.tryParse(val.toString());
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      return DateTime.tryParse(val.toString());
    }

    final rawProfId = json['professor_responsavel_id'] ??
        json['professor_id'] ??
        json['professorId'] ??
        json['responsavelId'];

    final rawProfNome = json['professor_responsavel_nome'] ??
        json['professor_nome'] ??
        json['professorNome'] ??
        json['responsavelNome'];

    return PatrimonioModelo(
      id: parseId(json['id']) ?? 0,
      nome: json['nome'] ?? json['descricao'] ?? '',
      numeroTombo: json['numero_tombo'] ?? json['tombamento'] ?? json['codigo'] ?? '',
      numeroSerie: json['numero_serie'] ?? json['numeroSerie'],
      categoria: json['categoria'],
      marca: json['marca'],
      modelo: json['modelo'],
      localizacao: json['localizacao'],
      descricao: json['descricao'],
      observacoes: json['observacoes'],
      status: json['status'] ?? 'disponivel',
      professorResponsavelId: parseId(rawProfId),
      professorResponsavelNome: rawProfNome,
      dataCriacao: parseDate(json['criado_em'] ?? json['createdAt']),
      dataAtualizacao: parseDate(json['atualizado_em'] ?? json['updatedAt']),
      dataAtribuicao: parseDate(json['data_atribuicao'] ?? json['dataAtribuicao']),
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
    String? tombamento,
    String? numeroSerie,
    String? categoria,
    String? marca,
    String? modelo,
    String? localizacao,
    String? descricao,
    String? observacoes,
    String? status,
    int? professorResponsavelId,
    int? professorId,
    String? professorResponsavelNome,
    String? professorNome,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    DateTime? dataAtribuicao,
  }) {
    return PatrimonioModelo(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      numeroTombo: numeroTombo ?? tombamento ?? this.numeroTombo,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      categoria: categoria ?? this.categoria,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      localizacao: localizacao ?? this.localizacao,
      descricao: descricao ?? this.descricao,
      observacoes: observacoes ?? this.observacoes,
      status: status ?? this.status,
      professorResponsavelId: professorResponsavelId ?? professorId ?? this.professorResponsavelId,
      professorResponsavelNome: professorResponsavelNome ?? professorNome ?? this.professorResponsavelNome,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      dataAtribuicao: dataAtribuicao ?? this.dataAtribuicao,
    );
  }
}
