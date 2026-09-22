import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_patrimonios/model/atribuicoes.dart';
import 'package:gestao_de_patrimonios/model/devolucao.dart';
import 'package:gestao_de_patrimonios/model/patrimonios.dart';
import 'package:gestao_de_patrimonios/service/patrimonios.dart';
import 'package:gestao_de_patrimonios/service/autenticacao.dart';
import 'package:gestao_de_patrimonios/service/professores.dart';

void main() {
  group('Testes da Camada Service e Models', () {
    test('PatrimoniosService instancia com URL correta', () {
      final service = PatrimoniosService(baseUrl: 'http://localhost:8000');
      expect(service.httpClient.baseUrl, 'http://localhost:8000');
      expect(service.httpClient.timeout, const Duration(seconds: 10));
    });

    test('Serialização e Desserialização de Patrimonios', () {
      final json = {
        'codigo': 'SENAI-001',
        'nome': 'Notebook Dell Latitude',
        'descricao': 'Notebook para desenvolvimento',
        'categoria': 'Informática',
        'marca': 'Dell',
        'modelo': '3420',
        'numeroSerie': 'ABC123XYZ',
        'estadoConservacao': 'Novo',
        'localizacao': 'Laboratório 2',
        'professorId': '10',
        'observacoes': 'Entregue com fonte',
      };

      final patrimonio = Patrimonios.fromJson(json);
      expect(patrimonio.codigo, 'SENAI-001');
      expect(patrimonio.nome, 'Notebook Dell Latitude');

      final serializado = patrimonio.toJson();
      expect(serializado['codigo'], 'SENAI-001');
      expect(serializado['numeroSerie'], 'ABC123XYZ');
    });

    test('AtribuicaoPatrimonio e DevolucaoPatrimonio serializam corretamente', () {
      final atribuicao = AtribuicaoPatrimonio(professorId: 5, observacoes: 'Para uso em aula');
      expect(atribuicao.toJson(), {'professorId': 5, 'observacoes': 'Para uso em aula'});

      final devolucao = DevolucaoPatrimonio(motivo: 'Fim de semestre');
      expect(devolucao.toJson(), {'motivo': 'Fim de semestre'});
    });

    test('AutenticacaoService e ProfessoresService instanciam corretamente', () {
      final authService = AutenticacaoService(baseUrl: 'http://localhost:8000');
      final profService = ProfessoresService(baseUrl: 'http://localhost:8000');

      expect(authService.httpClient.baseUrl, 'http://localhost:8000');
      expect(profService.httpClient.baseUrl, 'http://localhost:8000');
    });
  });
}
