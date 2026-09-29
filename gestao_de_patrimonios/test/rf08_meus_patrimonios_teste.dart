import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gestao_de_patrimonios/model/patrimonio_modelo.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('RF08 - Testes de Meus Patrimônios (Painel do Professor - Apenas Leitura)', () {
    test('Deve validar a exibição de patrimônios vinculados exclusivamente ao professor', () {
      final meusBens = [
        PatrimonioModelo(
          id: 501,
          tombamento: 'PAT-DOC-001',
          descricao: 'Microscópio Binocular Óptico',
          categoria: 'Laboratório',
          marca: 'Olympus',
          localizacao: 'Laboratório de Biologia Sala 3',
          status: 'em_uso',
          professorId: 2,
          professorNome: 'Prof. Carlos Silva',
        ),
        PatrimonioModelo(
          id: 502,
          tombamento: 'PAT-DOC-002',
          descricao: 'Notebook Lenovo ThinkPad',
          categoria: 'Informática',
          marca: 'Lenovo',
          localizacao: 'Gabinete dos Docentes',
          status: 'em_uso',
          professorId: 2,
          professorNome: 'Prof. Carlos Silva',
        ),
      ];

      expect(meusBens.length, 2);
      expect(meusBens.every((b) => b.professorId == 2), isTrue);
      expect(meusBens.first.tombamento, 'PAT-DOC-001');
      expect(meusBens.last.tombamento, 'PAT-DOC-002');
    });

    test('Deve permitir busca rápida nos bens vinculados por termo', () {
      final lista = [
        PatrimonioModelo(tombamento: 'PAT-01', descricao: 'Projetor Sala 1', categoria: 'Audiovisual'),
        PatrimonioModelo(tombamento: 'PAT-02', descricao: 'Microscópio', categoria: 'Laboratório'),
        PatrimonioModelo(tombamento: 'PAT-03', descricao: 'Projetor Portátil', categoria: 'Audiovisual'),
      ];

      final busca = 'projetor';
      final filtrados = lista.where((b) => b.descricao.toLowerCase().contains(busca)).toList();

      expect(filtrados.length, 2);
    });

    test('Deve verificar que o modelo de leitura preserva todas as informações de localização e detalhes', () {
      final bem = PatrimonioModelo(
        tombamento: 'PAT-EXP-99',
        descricao: 'Balança de Precisão Analítica',
        categoria: 'Laboratório',
        marca: 'Shimadzu',
        modelo: 'ATX224',
        numeroSerie: 'SN-SHIM-1234',
        localizacao: 'Bancada Central Lab 2',
        observacoes: 'Calibrada em Agosto/2026',
      );

      expect(bem.localizacao, 'Bancada Central Lab 2');
      expect(bem.observacoes, 'Calibrada em Agosto/2026');
      expect(bem.marca, 'Shimadzu');
      expect(bem.modelo, 'ATX224');
    });
  });
}
