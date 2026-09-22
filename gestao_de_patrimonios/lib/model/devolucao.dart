class DevolucaoPatrimonio {
  final String motivo;

  DevolucaoPatrimonio({required this.motivo});

  /// Converte o JSON recebido da API em uma instância de DevolucaoPatrimonio
  factory DevolucaoPatrimonio.fromJson(Map<String, dynamic> json) {
    return DevolucaoPatrimonio(motivo: json['motivo']);
  }

  /// Converte os dados para o formato esperado pelo backend
  Map<String, dynamic> toJson() {
    return {"motivo": motivo};
  }
}
