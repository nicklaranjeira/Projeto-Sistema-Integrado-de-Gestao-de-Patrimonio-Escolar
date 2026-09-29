import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/estatisticas_painel_modelo.dart';
import '../model/historico_movimentacao_modelo.dart';
import '../model/patrimonio_modelo.dart';
import '../service/api_servico.dart';
import '../service/painel_servico.dart';
import '../routes/rotas_app.dart';

class PainelControlador extends GetxController {
  final PainelServico _painelServico = Get.find<PainelServico>();
  final ApiServico _api = Get.find<ApiServico>();

  final RxBool carregando = false.obs;
  final Rx<EstatisticasPainelModelo> estatisticas = EstatisticasPainelModelo.vazio().obs;
  final RxList<PatrimonioModelo> ultimosPatrimonios = <PatrimonioModelo>[].obs;
  final RxList<HistoricoMovimentacaoModelo> ultimasMovimentacoes = <HistoricoMovimentacaoModelo>[].obs;

  @override
  void onInit() {
    super.onInit();
    carregarDadosPainel();
  }

  Future<void> carregarDadosPainel() async {
    carregando.value = true;
    try {
      final resposta = await _painelServico.obterEstatisticas();

      if (resposta.isOk && resposta.body != null) {
        final dados = resposta.body is Map<String, dynamic>
            ? resposta.body as Map<String, dynamic>
            : Map<String, dynamic>.from(resposta.body as Map);

        estatisticas.value = EstatisticasPainelModelo.fromJson(dados);

        if (dados.containsKey('ultimos_patrimonios') && dados['ultimos_patrimonios'] is List) {
          ultimosPatrimonios.assignAll(
            (dados['ultimos_patrimonios'] as List)
                .map((e) => PatrimonioModelo.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList(),
          );
        }

        if (dados.containsKey('ultimas_movimentacoes') && dados['ultimas_movimentacoes'] is List) {
          ultimasMovimentacoes.assignAll(
            (dados['ultimas_movimentacoes'] as List)
                .map((e) => HistoricoMovimentacaoModelo.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList(),
          );
        }
      } else {
        final erro = _api.tratarErro(resposta);
        Get.snackbar(
          'Erro ao Carregar Painel',
          erro,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro de Conexão',
        'Não foi possível atualizar as estatísticas do painel.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      carregando.value = false;
    }
  }

  Future<void> atualizar() async {
    await carregarDadosPainel();
  }

  void navegarParaPatrimonios() => Get.toNamed(RotasApp.ADMIN_PATRIMONIOS);
  void navegarParaNovoPatrimonio() => Get.toNamed(RotasApp.ADMIN_NOVO_PATRIMONIO);
  void navegarParaProfessores() => Get.toNamed(RotasApp.ADMIN_PROFESSORES);
  void navegarParaNovoProfessor() => Get.toNamed(RotasApp.ADMIN_NOVO_PROFESSOR);
  void navegarParaPerfil() => Get.toNamed(RotasApp.PERFIL);
}
