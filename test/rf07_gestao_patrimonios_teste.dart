import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sistema_patrimonio_escolar/app/dados/modelos/historico_movimentacao_modelo.dart';
import 'package:sistema_patrimonio_escolar/app/dados/modelos/patrimonio_modelo.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('RF07 - Testes de Gestão de Patrimônios (Inventário, Atribuição, Devolução e Histórico)', () {
    test('Deve desserializar PatrimonioModelo e validar getters de status', () {
      final jsonPatrimonio = {
        'id': 20,
        'tombamento': 'PAT-INFO-0045',
        'descricao': 'Notebook Dell Latitude 3420',
        'categoria': 'Informática',
        'marca': 'Dell',
        'modelo': 'Latitude 3420',
        'numero_serie': 'SN-DELL-987654',
        'status': 'disponivel',
        'localizacao': 'Almoxarifado Central',
      };

      final bem = PatrimonioModelo.fromJson(jsonPatrimonio);

      expect(bem.id, 20);
      expect(bem.tombamento, 'PAT-INFO-0045');
      expect(bem.descricao, 'Notebook Dell Latitude 3420');
      expect(bem.categoria, 'Informática');
      expect(bem.marca, 'Dell');
      expect(bem.eDisponivel, isTrue);
      expect(bem.eEmUso, isFalse);
      expect(bem.eEmManutencao, isFalse);
    });

    test('Deve simular o fluxo de Atribuição mudando status para em_uso e associando professor', () {
      final bemDisponivel = PatrimonioModelo(
        id: 30,
        tombamento: 'PAT-LAB-0012',
        descricao: 'Projetor Epson PowerLite',
        categoria: 'Audiovisual',
        status: 'disponivel',
      );

      final bemAtribuido = bemDisponivel.copyWith(
        status: 'em_uso',
        professorId: 3,
        professorNome: 'Prof. Lucas Mendes',
        dataAtribuicao: DateTime(2026, 9, 29),
      );

      expect(bemAtribuido.status, 'em_uso');
      expect(bemAtribuido.eEmUso, isTrue);
      expect(bemAtribuido.eDisponivel, isFalse);
      expect(bemAtribuido.professorId, 3);
      expect(bemAtribuido.professorNome, 'Prof. Lucas Mendes');
      expect(bemAtribuido.dataAtribuicao, isNotNull);
    });

    test('Deve simular o fluxo de Devolução retornando status para disponivel', () {
      final bemEmUso = PatrimonioModelo(
        id: 30,
        tombamento: 'PAT-LAB-0012',
        descricao: 'Projetor Epson PowerLite',
        categoria: 'Audiovisual',
        status: 'em_uso',
        professorId: 3,
        professorNome: 'Prof. Lucas Mendes',
      );

      final bemDevolvido = bemEmUso.copyWith(
        status: 'disponivel',
        professorId: null,
        professorNome: null,
      );

      expect(bemDevolvido.status, 'disponivel');
      expect(bemDevolvido.eDisponivel, isTrue);
      expect(bemDevolvido.eEmUso, isFalse);
    });

    test('Deve desserializar HistoricoMovimentacaoModelo para rastreabilidade', () {
      final jsonHistorico = {
        'id': 1,
        'patrimonio_id': 30,
        'tipo': 'devolucao',
        'motivo': 'Término do período letivo',
        'professor_nome': 'Prof. Lucas Mendes',
        'usuario_responsavel': 'Coordenador Silva',
        'data': '2026-09-29T10:00:00Z',
      };

      final historico = HistoricoMovimentacaoModelo.fromJson(jsonHistorico);

      expect(historico.id, 1);
      expect(historico.patrimonioId, 30);
      expect(historico.tipo, 'devolucao');
      expect(historico.motivo, 'Término do período letivo');
      expect(historico.professorNome, 'Prof. Lucas Mendes');
      expect(historico.usuarioResponsavel, 'Coordenador Silva');
    });

    test('Deve filtrar lista de patrimônios por status e categoria', () {
      final lista = [
        PatrimonioModelo(tombamento: 'PAT-01', descricao: 'Projetor', categoria: 'Audiovisual', status: 'disponivel'),
        PatrimonioModelo(tombamento: 'PAT-02', descricao: 'Notebook', categoria: 'Informática', status: 'em_uso'),
        PatrimonioModelo(tombamento: 'PAT-03', descricao: 'Tablet', categoria: 'Informática', status: 'disponivel'),
        PatrimonioModelo(tombamento: 'PAT-04', descricao: 'Microscópio', categoria: 'Laboratório', status: 'em_manutencao'),
      ];

      final disponiveisInformatica = lista.where((p) => p.status == 'disponivel' && p.categoria == 'Informática').toList();

      expect(disponiveisInformatica.length, 1);
      expect(disponiveisInformatica.first.tombamento, 'PAT-03');
    });
  });
}
