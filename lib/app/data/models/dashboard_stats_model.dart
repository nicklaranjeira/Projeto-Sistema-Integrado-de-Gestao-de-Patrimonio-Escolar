/// Modelo com as estatísticas e métricas do painel administrativo
class DashboardStatsModel {
  final int totalPatrimonios;
  final int emUso;
  final int disponiveis;
  final int emManutencao;
  final int totalProfessores;
  final int totalUsuarios;
  final Map<String, int> categorias;

  DashboardStatsModel({
    this.totalPatrimonios = 0,
    this.emUso = 0,
    this.disponiveis = 0,
    this.emManutencao = 0,
    this.totalProfessores = 0,
    this.totalUsuarios = 0,
    this.categorias = const {},
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    Map<String, int> parsedCategorias = {};
    if (json['categorias'] is Map) {
      json['categorias'].forEach((key, value) {
        parsedCategorias[key.toString()] = int.tryParse(value.toString()) ?? 0;
      });
    }

    return DashboardStatsModel(
      totalPatrimonios: json['total_patrimonios'] ?? json['total_assets'] ?? 0,
      emUso: json['em_uso'] ?? json['in_use'] ?? 0,
      disponiveis: json['disponiveis'] ?? json['available'] ?? 0,
      emManutencao: json['em_manutencao'] ?? json['in_maintenance'] ?? 0,
      totalProfessores: json['total_professores'] ?? json['total_teachers'] ?? 0,
      totalUsuarios: json['total_usuarios'] ?? json['total_users'] ?? 0,
      categorias: parsedCategorias,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_patrimonios': totalPatrimonios,
      'em_uso': emUso,
      'disponiveis': disponiveis,
      'em_manutencao': emManutencao,
      'total_professores': totalProfessores,
      'total_usuarios': totalUsuarios,
      'categorias': categorias,
    };
  }
}
