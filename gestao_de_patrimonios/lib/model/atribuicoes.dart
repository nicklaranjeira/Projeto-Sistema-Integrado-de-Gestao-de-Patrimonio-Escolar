class AtribuicaoPatrimonio {
  final int professorId;
  final String observacoes;

  AtribuicaoPatrimonio({required this.professorId, required this.observacoes});

  factory AtribuicaoPatrimonio.fromJson(Map<String, dynamic> json) {
    return AtribuicaoPatrimonio(
      professorId: json['professorId'],
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"professorId": professorId, "observacoes": observacoes};
  }
}
