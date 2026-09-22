class AtribuicaoPatrimonio {
  final int professorId;
  final String observacoes;

  AtribuicaoPatrimonio({required this.professorId, required this.observacoes});

  /// Converte o JSON recebido da API em uma instância de AtribuicaoPatrimonio
  factory AtribuicaoPatrimonio.fromJson(Map<String, dynamic> json) {
    return AtribuicaoPatrimonio(
      professorId: json['professorId'],
      observacoes: json['observacoes'],
    );
  }

  /// Converte os dados para o formato esperado pelo backend
  Map<String, dynamic> toJson() {
    return {"professorId": professorId, "observacoes": observacoes};
  }
}
