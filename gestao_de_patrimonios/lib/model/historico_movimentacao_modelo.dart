class HistoricoMovimentacaoModelo {
  final int id;
  final int patrimonioId;
  final String? patrimonioNome;
  final String tipoMovimentacao;
  final int? professorId;
  final String? professorNome;
  final int? usuarioAcaoId;
  final String? usuarioAcaoNome;
  final String? observacoes;
  final DateTime dataHora;

  HistoricoMovimentacaoModelo({
    required this.id,
    required this.patrimonioId,
    this.patrimonioNome,
    required this.tipoMovimentacao,
    this.professorId,
    this.professorNome,
    this.usuarioAcaoId,
    this.usuarioAcaoNome,
    this.observacoes,
    required this.dataHora,
  });

  bool get ehAlocacao => tipoMovimentacao.toLowerCase() == 'alocacao';
  bool get ehDevolucao => tipoMovimentacao.toLowerCase() == 'devolucao';
  bool get ehManutencao => tipoMovimentacao.toLowerCase() == 'manutencao';
  bool get ehBaixa => tipoMovimentacao.toLowerCase() == 'baixa';
  bool get ehCriacao => tipoMovimentacao.toLowerCase() == 'criacao';

  factory HistoricoMovimentacaoModelo.fromJson(Map<String, dynamic> json) {
    return HistoricoMovimentacaoModelo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      patrimonioId: json['patrimonio_id'] is int
          ? json['patrimonio_id']
          : int.tryParse(json['patrimonio_id']?.toString() ?? '0') ?? 0,
      patrimonioNome: json['patrimonio_nome'],
      tipoMovimentacao: json['tipo_movimentacao'] ?? json['tipo'] ?? 'movimentacao',
      professorId: json['professor_id'] is int
          ? json['professor_id']
          : int.tryParse(json['professor_id']?.toString() ?? ''),
      professorNome: json['professor_nome'],
      usuarioAcaoId: json['usuario_acao_id'] is int
          ? json['usuario_acao_id']
          : int.tryParse(json['usuario_acao_id']?.toString() ?? ''),
      usuarioAcaoNome: json['usuario_acao_nome'] ?? json['usuario_nome'],
      observacoes: json['observacoes'] ?? json['motivo'],
      dataHora: json['data_hora'] != null
          ? (DateTime.tryParse(json['data_hora']) ?? DateTime.now())
          : (json['criado_em'] != null
              ? (DateTime.tryParse(json['criado_em']) ?? DateTime.now())
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patrimonio_id': patrimonioId,
      'patrimonio_nome': patrimonioNome,
      'tipo_movimentacao': tipoMovimentacao,
      'professor_id': professorId,
      'professor_nome': professorNome,
      'usuario_acao_id': usuarioAcaoId,
      'usuario_acao_nome': usuarioAcaoNome,
      'observacoes': observacoes,
      'data_hora': dataHora.toIso8601String(),
    };
  }
}
