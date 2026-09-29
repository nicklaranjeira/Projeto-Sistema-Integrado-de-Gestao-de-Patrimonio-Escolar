class DevolucaoPatrimonio {
  final String motivo;

  DevolucaoPatrimonio({required this.motivo});

  factory DevolucaoPatrimonio.fromJson(Map<String, dynamic> json) {
    return DevolucaoPatrimonio(motivo: json['motivo']);
  }

  Map<String, dynamic> toJson() {
    return {"motivo": motivo};
  }
}
