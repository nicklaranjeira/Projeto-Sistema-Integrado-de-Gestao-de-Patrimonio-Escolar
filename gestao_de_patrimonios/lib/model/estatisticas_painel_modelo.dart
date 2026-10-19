class EstatisticasPainelModelo {
  final int totalPatrimonios;
  final int totalAlocados;
  final int totalDisponiveis;
  final int totalManutencao;
  final int totalBaixados;
  final int totalProfessores;
  final int totalProfessoresAtivos;
  final int totalUsuarios;
  final Map<String, int> contagemPorCategoria;

  // Aliases compatíveis com RF05
  int get emUso => totalAlocados;
  int get disponiveis => totalDisponiveis;
  int get emManutencao => totalManutencao;
  Map<String, int> get categorias => contagemPorCategoria;

  EstatisticasPainelModelo({
    this.totalPatrimonios = 0,
    int? totalAlocados,
    int? emUso,
    int? totalDisponiveis,
    int? disponiveis,
    int? totalManutencao,
    int? emManutencao,
    this.totalBaixados = 0,
    this.totalProfessores = 0,
    int? totalUsuarios,
    this.totalProfessoresAtivos = 0,
    Map<String, int>? contagemPorCategoria,
    Map<String, int>? categorias,
  })  : totalAlocados = totalAlocados ?? emUso ?? 0,
        totalDisponiveis = totalDisponiveis ?? disponiveis ?? 0,
        totalManutencao = totalManutencao ?? emManutencao ?? 0,
        totalUsuarios = totalUsuarios ?? totalProfessores ?? 0,
        contagemPorCategoria = contagemPorCategoria ?? categorias ?? const {};

  factory EstatisticasPainelModelo.vazio() => EstatisticasPainelModelo();

  factory EstatisticasPainelModelo.fromJson(Map<String, dynamic> json) {
    Map<String, int> categorias = {};
    final rawCat = json['por_categoria'] ?? json['categorias'] ?? json['porCategoria'];
    if (rawCat is Map) {
      rawCat.forEach((k, v) {
        categorias[k.toString()] = v is int ? v : int.tryParse(v.toString()) ?? 0;
      });
    }

    int parseVal(dynamic v) {
      if (v is int) return v;
      if (v == null) return 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    final alocadosVal = json['total_alocados'] ?? json['em_uso'] ?? json['patrimoniosEmUso'];
    final disponiveisVal = json['total_disponiveis'] ?? json['disponiveis'] ?? json['patrimoniosDisponiveis'];
    final manutencaoVal = json['total_manutencao'] ?? json['em_manutencao'] ?? json['patrimoniosEmManutencao'];
    final profVal = json['total_professores'] ?? json['total_usuarios'] ?? json['totalProfessores'];
    final usuariosVal = json['total_usuarios'] ?? json['total_professores'] ?? json['totalProfessores'];
    final totalPat = json['total_patrimonios'] ?? json['totalPatrimonios'];

    return EstatisticasPainelModelo(
      totalPatrimonios: parseVal(totalPat),
      totalAlocados: parseVal(alocadosVal),
      totalDisponiveis: parseVal(disponiveisVal),
      totalManutencao: parseVal(manutencaoVal),
      totalBaixados: parseVal(json['total_baixados']),
      totalProfessores: parseVal(profVal),
      totalUsuarios: parseVal(usuariosVal),
      totalProfessoresAtivos: parseVal(json['total_professores_ativos']),
      contagemPorCategoria: categorias,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_patrimonios': totalPatrimonios,
      'total_alocados': totalAlocados,
      'em_uso': totalAlocados,
      'total_disponiveis': totalDisponiveis,
      'disponiveis': totalDisponiveis,
      'total_manutencao': totalManutencao,
      'em_manutencao': totalManutencao,
      'total_baixados': totalBaixados,
      'total_professores': totalProfessores,
      'total_usuarios': totalUsuarios,
      'total_professores_ativos': totalProfessoresAtivos,
      'por_categoria': contagemPorCategoria,
      'categorias': contagemPorCategoria,
    };
  }
}
