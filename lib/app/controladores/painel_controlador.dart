import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dados/modelos/estatisticas_painel_modelo.dart';
import '../dados/servicos/api_servico.dart';
import '../dados/servicos/painel_servico.dart';
import '../rotas/rotas_app.dart';

class PainelControlador extends GetxController {
  final PainelServico _painelServico = Get.find<PainelServico>();
  final ApiServico _api = Get.find<ApiServico>();

  final RxBool carregando = false.obs;
  final Rx<EstatisticasPainelModelo> estatisticas = EstatisticasPainelModelo().obs;
  final RxString mensagemErro = ''.obs;

  @override
  void onInit() {
    super.onInit();
    carregarEstatisticas();
  }

  Future<void> carregarEstatisticas() async {
    carregando.value = true;
    mensagemErro.value = '';

    try {
      final resposta = await _painelServico.obterEstatisticas();

      if (resposta.isOk && resposta.body != null) {
        final Map<String, dynamic> dados =
            resposta.body is Map ? Map<String, dynamic>.from(resposta.body) : {};
        estatisticas.value = EstatisticasPainelModelo.fromJson(dados);
      } else {
        mensagemErro.value = _api.tratarErro(resposta);
      }
    } catch (e) {
      mensagemErro.value = 'Falha ao conectar com o servidor para obter os indicadores.';
    } finally {
      carregando.value = false;
    }
  }

  Future<void> atualizarPainel() async {
    await carregarEstatisticas();
  }

  void irParaPatrimonios({String? status}) {
    Get.toNamed(RotasApp.ADMIN_PATRIMONIOS, arguments: {'filtroStatus': status});
  }

  void irParaNovoPatrimonio() {
    Get.toNamed(RotasApp.ADMIN_NOVO_PATRIMONIO);
  }

  void irParaProfessores() {
    Get.toNamed(RotasApp.ADMIN_PROFESSORES);
  }

  void irParaNovoProfessor() {
    Get.toNamed(RotasApp.ADMIN_NOVO_PROFESSOR);
  }

  void irParaPerfil() {
    Get.toNamed(RotasApp.PERFIL);
  }
}
