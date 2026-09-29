import 'patrimonio_modelo.dart';

class ProfessorModelo {
  final int? id;
  final String nome;
  final String email;
  final String matricula;
  final String departamento;
  final String? telefone;
  final int quantidadePatrimonios;
  final List<PatrimonioModelo> patrimonios;

  ProfessorModelo({
    this.id,
    required this.nome,
    required this.email,
    required this.matricula,
    required this.departamento,
    this.telefone,
    this.quantidadePatrimonios = 0,
    this.patrimonios = const [],
  });

  factory ProfessorModelo.fromJson(Map<String, dynamic> json) {
    var rawList = json['patrimonios'] ?? json['assets'] ?? [];
    List<PatrimonioModelo> parsedList = [];
    if (rawList is List) {
      parsedList = rawList
          .map((item) => PatrimonioModelo.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ProfessorModelo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      nome: json['nome'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      matricula: json['matricula'] ?? json['registration_number'] ?? '',
      departamento: json['departamento'] ?? json['department'] ?? '',
      telefone: json['telefone'] ?? json['phone'],
      quantidadePatrimonios: json['quantidade_patrimonios'] ??
          json['assets_count'] ??
          parsedList.length,
      patrimonios: parsedList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'matricula': matricula,
      'departamento': departamento,
      'telefone': telefone,
      'quantidade_patrimonios': quantidadePatrimonios,
      'patrimonios': patrimonios.map((e) => e.toJson()).toList(),
    };
  }

  ProfessorModelo copyWith({
    int? id,
    String? nome,
    String? email,
    String? matricula,
    String? departamento,
    String? telefone,
    int? quantidadePatrimonios,
    List<PatrimonioModelo>? patrimonios,
  }) {
    return ProfessorModelo(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      matricula: matricula ?? this.matricula,
      departamento: departamento ?? this.departamento,
      telefone: telefone ?? this.telefone,
      quantidadePatrimonios: quantidadePatrimonios ?? this.quantidadePatrimonios,
      patrimonios: patrimonios ?? this.patrimonios,
    );
  }
}
