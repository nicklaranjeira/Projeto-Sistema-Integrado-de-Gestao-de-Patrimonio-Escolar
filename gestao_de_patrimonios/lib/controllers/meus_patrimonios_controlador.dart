import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/patrimonio_modelo.dart';
import '../services/api_servico.dart';
import '../services/patrimonio_servico.dart';

class MeusPatrimoniosControlador extends GetxController {
  final PatrimonioServico _patrimonioServico = Get.find<PatrimonioServico>();
  final ApiServico _api = Get.find<ApiServico>();

  final RxBool carregando = false.obs;
  final RxString mensagemErro = ''.obs;

  final RxList<PatrimonioModelo> meusPatrimonios = <PatrimonioModelo>[].obs;
  final RxList<PatrimonioModelo> patrimoniosFiltrados = <PatrimonioModelo>[].obs;

  final Rx<PatrimonioModelo?> patrimonioSelecionado = Rx<PatrimonioModelo?>(null);

  final RxString textoBusca = ''.obs;

  @override
  void onInit() {
    super.onInit();
    carregarMeusPatrimonios();
  }

  Future<void> carregarMeusPatrimonios() async {
    carregando.value = true;
    mensagemErro.value = '';

    try {
      final resposta = await _patrimonioServico.obterPatrimonios();

      if (resposta.isOk && resposta.body != null) {
        final List<dynamic> dados = resposta.body is List
            ? resposta.body
            : (resposta.body['patrimonios'] ?? resposta.body['data'] ?? []);

        meusPatrimonios.value = dados
            .map((item) => PatrimonioModelo.fromJson(item as Map<String, dynamic>))
            .toList();

        _aplicarFiltro();
      } else {
        mensagemErro.value = _api.tratarErro(resposta);
      }
    } catch (e) {
      mensagemErro.value = 'Falha ao buscar seus patrimônios vinculados.';
    } finally {
      carregando.value = false;
    }
  }

  Future<void> atualizarLista() async {
    await carregarMeusPatrimonios();
  }

  void aoMudarBusca(String busca) {
    textoBusca.value = busca;
    _aplicarFiltro();
  }

  void _aplicarFiltro() {
    if (textoBusca.value.trim().isEmpty) {
      patrimoniosFiltrados.assignAll(meusPatrimonios);
      return;
    }

    final termo = textoBusca.value.toLowerCase();
    patrimoniosFiltrados.assignAll(
      meusPatrimonios.where((item) {
        final tombamento = item.tombamento.toLowerCase();
        final descricao = item.descricao.toLowerCase();
        final categoria = item.categoria.toLowerCase();
        final marca = (item.marca ?? '').toLowerCase();
        final localizacao = (item.localizacao ?? '').toLowerCase();

        return tombamento.contains(termo) ||
            descricao.contains(termo) ||
            categoria.contains(termo) ||
            marca.contains(termo) ||
            localizacao.contains(termo);
      }).toList(),
    );
  }

  void verDetalhes(PatrimonioModelo item) {
    patrimonioSelecionado.value = item;
  }
}
