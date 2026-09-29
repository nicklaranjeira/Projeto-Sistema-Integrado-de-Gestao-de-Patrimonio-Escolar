class HistoricoMovimentacaoModelo {
  final int? id;
  final int patrimonioId;
  final String tipo;
  final String? motivo;
  final String? observacao;
  final int? professorId;
  final String? professorNome;
  final String? usuarioResponsavel;
  final DateTime data;

  HistoricoMovimentacaoModelo({
    this.id,
    required this.patrimonioId,
    required this.tipo,
    this.motivo,
    this.observacao,
    this.professorId,
    this.professorNome,
    this.usuarioResponsavel,
    required this.data,
  });

  factory HistoricoMovimentacaoModelo.fromJson(Map<String, dynamic> json) {
    return HistoricoMovimentacaoModelo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      patrimonioId: json['patrimonio_id'] ?? json['asset_id'] ?? 0,
      tipo: json['tipo'] ?? json['type'] ?? 'movimentacao',
      motivo: json['motivo'] ?? json['reason'],
      observacao: json['observacao'] ?? json['observation'] ?? json['notes'],
      professorId: json['professor_id'] is int ? json['professor_id'] : int.tryParse(json['professor_id']?.toString() ?? ''),
      professorNome: json['professor_nome'] ?? json['professor_name'],
      usuarioResponsavel: json['usuario_responsavel'] ?? json['created_by'],
      data: json['data'] != null || json['created_at'] != null
          ? DateTime.tryParse((json['data'] ?? json['created_at']).toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patrimonio_id': patrimonioId,
      'tipo': tipo,
      'motivo': motivo,
      'observacao': observacao,
      'professor_id': professorId,
      'professor_nome': professorNome,
      'usuario_responsavel': usuarioResponsavel,
      'data': data.toIso8601String(),
    };
  }
}
