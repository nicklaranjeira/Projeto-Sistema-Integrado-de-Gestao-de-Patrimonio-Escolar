class EstatisticasPainelModelo {
  final int totalPatrimonios;
  final int totalAlocados;
  final int totalDisponiveis;
  final int totalManutencao;
  final int totalBaixados;
  final int totalProfessores;
  final int totalProfessoresAtivos;
  final Map<String, int> contagemPorCategoria;

  EstatisticasPainelModelo({
    this.totalPatrimonios = 0,
    this.totalAlocados = 0,
    this.totalDisponiveis = 0,
    this.totalManutencao = 0,
    this.totalBaixados = 0,
    this.totalProfessores = 0,
    this.totalProfessoresAtivos = 0,
    this.contagemPorCategoria = const {},
  });

  factory EstatisticasPainelModelo.vazio() => EstatisticasPainelModelo();

  factory EstatisticasPainelModelo.fromJson(Map<String, dynamic> json) {
    Map<String, int> categorias = {};
    if (json['por_categoria'] is Map) {
      (json['por_categoria'] as Map).forEach((k, v) {
        categorias[k.toString()] = v is int ? v : int.tryParse(v.toString()) ?? 0;
      });
    }

    return EstatisticasPainelModelo(
      totalPatrimonios: json['total_patrimonios'] is int
          ? json['total_patrimonios']
          : int.tryParse(json['total_patrimonios']?.toString() ?? '0') ?? 0,
      totalAlocados: json['total_alocados'] is int
          ? json['total_alocados']
          : int.tryParse(json['total_alocados']?.toString() ?? '0') ?? 0,
      totalDisponiveis: json['total_disponiveis'] is int
          ? json['total_disponiveis']
          : int.tryParse(json['total_disponiveis']?.toString() ?? '0') ?? 0,
      totalManutencao: json['total_manutencao'] is int
          ? json['total_manutencao']
          : int.tryParse(json['total_manutencao']?.toString() ?? '0') ?? 0,
      totalBaixados: json['total_baixados'] is int
          ? json['total_baixados']
          : int.tryParse(json['total_baixados']?.toString() ?? '0') ?? 0,
      totalProfessores: json['total_professores'] is int
          ? json['total_professores']
          : int.tryParse(json['total_professores']?.toString() ?? '0') ?? 0,
      totalProfessoresAtivos: json['total_professores_ativos'] is int
          ? json['total_professores_ativos']
          : int.tryParse(json['total_professores_ativos']?.toString() ?? '0') ?? 0,
      contagemPorCategoria: categorias,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_patrimonios': totalPatrimonios,
      'total_alocados': totalAlocados,
      'total_disponiveis': totalDisponiveis,
      'total_manutencao': totalManutencao,
      'total_baixados': totalBaixados,
      'total_professores': totalProfessores,
      'total_professores_ativos': totalProfessoresAtivos,
      'por_categoria': contagemPorCategoria,
    };
  }
}
