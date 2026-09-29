/// Modelo que representa um Patrimônio Escolar (Bem Material)
class PatrimonioModel {
  final int? id;
  final String tombamento;
  final String descricao;
  final String categoria;
  final String? marca;
  final String? modelo;
  final String? numeroSerie;
  final String status; // 'disponivel', 'em_uso', 'em_manutencao'
  final String? localizacao;
  final int? professorId;
  final String? professorNome;
  final DateTime? dataAquisicao;
  final DateTime? dataAtribuicao;
  final String? observacoes;

  PatrimonioModel({
    this.id,
    required this.tombamento,
    required this.descricao,
    required this.categoria,
    this.marca,
    this.modelo,
    this.numeroSerie,
    this.status = 'disponivel',
    this.localizacao,
    this.professorId,
    this.professorNome,
    this.dataAquisicao,
    this.dataAtribuicao,
    this.observacoes,
  });

  bool get isDisponivel => status.toLowerCase() == 'disponivel';
  bool get isEmUso => status.toLowerCase() == 'em_uso';
  bool get isEmManutencao => status.toLowerCase() == 'em_manutencao';

  factory PatrimonioModel.fromJson(Map<String, dynamic> json) {
    return PatrimonioModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      tombamento: json['tombamento'] ?? json['codigo'] ?? '',
      descricao: json['descricao'] ?? json['nome'] ?? '',
      categoria: json['categoria'] ?? json['category'] ?? 'Geral',
      marca: json['marca'] ?? json['brand'],
      modelo: json['modelo'] ?? json['model'],
      numeroSerie: json['numero_serie'] ?? json['serial_number'],
      status: json['status'] ?? 'disponivel',
      localizacao: json['localizacao'] ?? json['location'],
      professorId: json['professor_id'] is int ? json['professor_id'] : int.tryParse(json['professor_id']?.toString() ?? ''),
      professorNome: json['professor_nome'] ?? json['professor_name'],
      dataAquisicao: json['data_aquisicao'] != null ? DateTime.tryParse(json['data_aquisicao'].toString()) : null,
      dataAtribuicao: json['data_atribuicao'] != null ? DateTime.tryParse(json['data_atribuicao'].toString()) : null,
      observacoes: json['observacoes'] ?? json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tombamento': tombamento,
      'descricao': descricao,
      'categoria': categoria,
      'marca': marca,
      'modelo': modelo,
      'numero_serie': numeroSerie,
      'status': status,
      'localizacao': localizacao,
      'professor_id': professorId,
      'professor_nome': professorNome,
      'data_aquisicao': dataAquisicao?.toIso8601String(),
      'data_atribuicao': dataAtribuicao?.toIso8601String(),
      'observacoes': observacoes,
    };
  }

  PatrimonioModel copyWith({
    int? id,
    String? tombamento,
    String? descricao,
    String? categoria,
    String? marca,
    String? modelo,
    String? numeroSerie,
    String? status,
    String? localizacao,
    int? professorId,
    String? professorNome,
    DateTime? dataAquisicao,
    DateTime? dataAtribuicao,
    String? observacoes,
  }) {
    return PatrimonioModel(
      id: id ?? this.id,
      tombamento: tombamento ?? this.tombamento,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      status: status ?? this.status,
      localizacao: localizacao ?? this.localizacao,
      professorId: professorId ?? this.professorId,
      professorNome: professorNome ?? this.professorNome,
      dataAquisicao: dataAquisicao ?? this.dataAquisicao,
      dataAtribuicao: dataAtribuicao ?? this.dataAtribuicao,
      observacoes: observacoes ?? this.observacoes,
    );
  }
}
