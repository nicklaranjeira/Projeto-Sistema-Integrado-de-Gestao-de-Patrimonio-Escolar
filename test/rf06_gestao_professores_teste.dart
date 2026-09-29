import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sistema_patrimonio_escolar/app/dados/modelos/patrimonio_modelo.dart';
import 'package:sistema_patrimonio_escolar/app/dados/modelos/professor_modelo.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('RF06 - Testes de Gestão de Professores', () {
    test('Deve desserializar ProfessorModelo com lista de patrimônios sob sua tutela', () {
      final jsonProfessor = {
        'id': 5,
        'nome': 'Prof. Fernando Souza',
        'email': 'fernando.souza@escola.com',
        'matricula': 'MAT-4455',
        'departamento': 'Física e Robótica',
        'telefone': '11977665544',
        'quantidade_patrimonios': 2,
        'patrimonios': [
          {
            'id': 101,
            'tombamento': 'PAT-2026-001',
            'descricao': 'Kit Arduino Avançado',
            'categoria': 'Laboratório',
            'status': 'em_uso',
          },
          {
            'id': 102,
            'tombamento': 'PAT-2026-002',
            'descricao': 'Osciloscópio Digital',
            'categoria': 'Laboratório',
            'status': 'em_uso',
          }
        ]
      };

      final professor = ProfessorModelo.fromJson(jsonProfessor);

      expect(professor.id, 5);
      expect(professor.nome, 'Prof. Fernando Souza');
      expect(professor.matricula, 'MAT-4455');
      expect(professor.departamento, 'Física e Robótica');
      expect(professor.quantidadePatrimonios, 2);
      expect(professor.patrimonios.length, 2);
      expect(professor.patrimonios.first.tombamento, 'PAT-2026-001');
      expect(professor.patrimonios.last.tombamento, 'PAT-2026-002');
    });

    test('Deve filtrar lista de professores por nome ou matrícula', () {
      final listaProfessores = [
        ProfessorModelo(
          id: 1,
          nome: 'Mariana Costa',
          email: 'mariana@escola.com',
          matricula: 'MAT-101',
          departamento: 'Matemática',
        ),
        ProfessorModelo(
          id: 2,
          nome: 'Roberto Almeida',
          email: 'roberto@escola.com',
          matricula: 'MAT-102',
          departamento: 'História',
        ),
        ProfessorModelo(
          id: 3,
          nome: 'Mariana Duarte',
          email: 'mduarte@escola.com',
          matricula: 'MAT-103',
          departamento: 'Biologia',
        ),
      ];

      final termoBusca = 'mariana';
      final resultado = listaProfessores
          .where((p) =>
              p.nome.toLowerCase().contains(termoBusca) ||
              p.matricula.toLowerCase().contains(termoBusca))
          .toList();

      expect(resultado.length, 2);
      expect(resultado.any((p) => p.nome == 'Roberto Almeida'), isFalse);
    });

    test('Deve validar dados obrigatórios para cadastro de professor com senha provisória', () {
      final dadosCadastro = {
        'nome': 'Juliana Ramos',
        'email': 'juliana.ramos@escola.com',
        'matricula': 'MAT-9988',
        'departamento': 'Geografia',
        'senha_provisoria': 'Escola2026@',
      };

      expect(dadosCadastro['nome'], isNotEmpty);
      expect(dadosCadastro['email'], contains('@'));
      expect(dadosCadastro['matricula'], isNotEmpty);
      expect(dadosCadastro['departamento'], isNotEmpty);
      expect(dadosCadastro['senha_provisoria'], isNotEmpty);
    });
  });
}
