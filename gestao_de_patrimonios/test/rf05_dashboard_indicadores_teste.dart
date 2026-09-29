import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gestao_de_patrimonios/models/estatisticas_painel_modelo.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('RF05 - Testes de Dashboard e Indicadores Patrimoniais', () {
    test('Deve desserializar corretamente o modelo EstatisticasPainelModelo', () {
      final jsonEstatisticas = {
        'total_patrimonios': 150,
        'em_uso': 95,
        'disponiveis': 45,
        'em_manutencao': 10,
        'total_professores': 28,
        'total_usuarios': 32,
        'categorias': {
          'Informática': 60,
          'Audiovisual': 30,
          'Laboratório': 40,
          'Mobiliário': 20,
        }
      };

      final estatisticas = EstatisticasPainelModelo.fromJson(jsonEstatisticas);

      expect(estatisticas.totalPatrimonios, 150);
      expect(estatisticas.emUso, 95);
      expect(estatisticas.disponiveis, 45);
      expect(estatisticas.emManutencao, 10);
      expect(estatisticas.totalProfessores, 28);
      expect(estatisticas.totalUsuarios, 32);
      expect(estatisticas.categorias['Informática'], 60);
      expect(estatisticas.categorias['Audiovisual'], 30);
      expect(estatisticas.categorias['Laboratório'], 40);
      expect(estatisticas.categorias['Mobiliário'], 20);
    });

    test('Deve validar a consistência matemática dos totais de patrimônio', () {
      final stats = EstatisticasPainelModelo(
        totalPatrimonios: 100,
        emUso: 60,
        disponiveis: 35,
        emManutencao: 5,
      );

      final somaStatus = stats.emUso + stats.disponiveis + stats.emManutencao;

      expect(somaStatus, equals(stats.totalPatrimonios));
    });

    test('Deve serializar EstatisticasPainelModelo para JSON', () {
      final stats = EstatisticasPainelModelo(
        totalPatrimonios: 50,
        emUso: 30,
        disponiveis: 15,
        emManutencao: 5,
        totalProfessores: 10,
        totalUsuarios: 12,
        categorias: {'Informática': 30, 'Outros': 20},
      );

      final json = stats.toJson();

      expect(json['total_patrimonios'], 50);
      expect(json['em_uso'], 30);
      expect(json['disponiveis'], 15);
      expect(json['em_manutencao'], 5);
      expect(json['total_professores'], 10);
      expect(json['categorias']['Informática'], 30);
    });
  });
}
