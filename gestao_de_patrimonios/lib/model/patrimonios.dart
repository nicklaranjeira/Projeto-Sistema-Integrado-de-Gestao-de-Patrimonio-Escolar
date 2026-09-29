// Patrimonios
class Patrimonios {
  final String codigo;
  final String nome;
  final String descricao;
  final String categoria;
  final String marca;
  final String? modelo;
  final String numeroSerie;
  final String? estadoConservacao;
  final String? localizacao;
  final String? professorId;
  final String? observacoes;

  Patrimonios({
    required this.codigo,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.marca,
    this.modelo,
    required this.numeroSerie,
    this.estadoConservacao,
    this.localizacao,
    this.professorId,
    this.observacoes,
  });

  /// Converte o JSON recebido da API em uma instância de Patrimonios
  factory Patrimonios.fromJson(Map<String, dynamic> json) {
    return Patrimonios(
      codigo: json['codigo']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString(),
      numeroSerie: json['numero_serie']?.toString() ??
          json['numeroSerie']?.toString() ??
          '',
      estadoConservacao: json['estado_conservacao']?.toString() ??
          json['estadoConservacao']?.toString(),
      localizacao: json['localizacao']?.toString(),
      professorId: json['professor_id']?.toString() ??
          json['professorId']?.toString(),
      observacoes: json['observacoes']?.toString(),
    );
  }

  /// Converte os dados para o formato esperado pelo backend
  Map<String, dynamic> toJson() {
    return {
      "codigo": codigo,
      "nome": nome,
      "descricao": descricao,
      "categoria": categoria,
      "marca": marca,
      "modelo": modelo,
      "numeroSerie": numeroSerie,
      "numero_serie": numeroSerie,
      "estadoConservacao": estadoConservacao,
      "estado_conservacao": estadoConservacao,
      "localizacao": localizacao,
      "professorId": professorId,
      "professor_id":
          professorId != null ? int.tryParse(professorId!) ?? professorId : null,
      "observacoes": observacoes,
    };
  }
}

