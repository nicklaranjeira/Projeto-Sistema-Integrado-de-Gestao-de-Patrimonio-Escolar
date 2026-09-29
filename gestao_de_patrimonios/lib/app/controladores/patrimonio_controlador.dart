import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dados/modelos/historico_movimentacao_modelo.dart';
import '../dados/modelos/patrimonio_modelo.dart';
import '../dados/servicos/api_servico.dart';
import '../dados/servicos/patrimonio_servico.dart';
import '../rotas/rotas_app.dart';

class PatrimonioControlador extends GetxController {
  final PatrimonioServico _patrimonioServico = Get.find<PatrimonioServico>();
  final ApiServico _api = Get.find<ApiServico>();

  final RxBool carregando = false.obs;
  final RxBool salvando = false.obs;
  final RxBool carregandoHistorico = false.obs;
  final RxString mensagemErro = ''.obs;

  final RxList<PatrimonioModelo> patrimonios = <PatrimonioModelo>[].obs;
  final RxList<PatrimonioModelo> patrimoniosFiltrados = <PatrimonioModelo>[].obs;
  final RxList<HistoricoMovimentacaoModelo> historicoLista = <HistoricoMovimentacaoModelo>[].obs;

  final Rx<PatrimonioModelo?> patrimonioSelecionado = Rx<PatrimonioModelo?>(null);

  final RxString filtroStatusSelecionado = 'todos'.obs;
  final RxString filtroCategoriaSelecionada = 'todas'.obs;
  final RxString textoBusca = ''.obs;

  final RxList<String> categoriasDisponiveis = <String>[
    'todas',
    'Informática',
    'Audiovisual',
    'Mobiliário',
    'Laboratório',
    'Esportivo',
    'Outros'
  ].obs;

  final tombamentoController = TextEditingController();
  final descricaoController = TextEditingController();
  final categoriaController = TextEditingController();
  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final numeroSerieController = TextEditingController();
  final localizacaoController = TextEditingController();
  final observacoesController = TextEditingController();

  final motivoDevolucaoController = TextEditingController();
  final observacaoAtribuicaoController = TextEditingController();
  final Rx<int?> professorIdSelecionadoParaAtribuicao = Rx<int?>(null);

  final formularioChave = GlobalKey<FormState>();
  final formularioDevolucaoChave = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    final argumentos = Get.arguments;
    if (argumentos is Map && argumentos['filtroStatus'] != null) {
      filtroStatusSelecionado.value = argumentos['filtroStatus'];
    }
    carregarPatrimonios();
  }

  @override
  void onClose() {
    tombamentoController.dispose();
    descricaoController.dispose();
    categoriaController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    numeroSerieController.dispose();
    localizacaoController.dispose();
    observacoesController.dispose();
    motivoDevolucaoController.dispose();
    observacaoAtribuicaoController.dispose();
    super.onClose();
  }

  Future<void> carregarPatrimonios() async {
    carregando.value = true;
    mensagemErro.value = '';

    try {
      final resposta = await _patrimonioServico.obterPatrimonios(
        status: filtroStatusSelecionado.value,
        categoria: filtroCategoriaSelecionada.value,
        busca: textoBusca.value,
      );

      if (resposta.isOk && resposta.body != null) {
        final List<dynamic> dados = resposta.body is List
            ? resposta.body
            : (resposta.body['patrimonios'] ?? resposta.body['data'] ?? []);

        patrimonios.value = dados
            .map((item) => PatrimonioModelo.fromJson(item as Map<String, dynamic>))
            .toList();

        _aplicarFiltroLocal();
      } else {
        mensagemErro.value = _api.tratarErro(resposta);
      }
    } catch (e) {
      mensagemErro.value = 'Falha ao carregar patrimônios.';
    } finally {
      carregando.value = false;
    }
  }

  void definirFiltroStatus(String status) {
    filtroStatusSelecionado.value = status;
    carregarPatrimonios();
  }

  void definirFiltroCategoria(String categoria) {
    filtroCategoriaSelecionada.value = categoria;
    carregarPatrimonios();
  }

  void aoMudarBusca(String busca) {
    textoBusca.value = busca;
    _aplicarFiltroLocal();
  }

  void _aplicarFiltroLocal() {
    if (textoBusca.value.trim().isEmpty) {
      patrimoniosFiltrados.assignAll(patrimonios);
      return;
    }

    final termo = textoBusca.value.toLowerCase();
    patrimoniosFiltrados.assignAll(
      patrimonios.where((item) {
        final tombamento = item.tombamento.toLowerCase();
        final descricao = item.descricao.toLowerCase();
        final marca = (item.marca ?? '').toLowerCase();
        final profNome = (item.professorNome ?? '').toLowerCase();
        return tombamento.contains(termo) ||
            descricao.contains(termo) ||
            marca.contains(termo) ||
            profNome.contains(termo);
      }).toList(),
    );
  }

  Future<void> criarPatrimonio() async {
    if (!formularioChave.currentState!.validate()) return;

    salvando.value = true;
    try {
      final dados = {
        'tombamento': tombamentoController.text.trim(),
        'descricao': descricaoController.text.trim(),
        'categoria': categoriaController.text.trim().isEmpty ? 'Geral' : categoriaController.text.trim(),
        if (marcaController.text.isNotEmpty) 'marca': marcaController.text.trim(),
        if (modeloController.text.isNotEmpty) 'modelo': modeloController.text.trim(),
        if (numeroSerieController.text.isNotEmpty) 'numero_serie': numeroSerieController.text.trim(),
        if (localizacaoController.text.isNotEmpty) 'localizacao': localizacaoController.text.trim(),
        if (observacoesController.text.isNotEmpty) 'observacoes': observacoesController.text.trim(),
        'status': 'disponivel',
      };

      final resposta = await _patrimonioServico.criarPatrimonio(dados);

      if (resposta.isOk) {
        _limparFormulario();
        Get.back();
        await carregarPatrimonios();
        Get.snackbar(
          'Sucesso',
          'Patrimônio cadastrado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erro',
          _api.tratarErro(resposta),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao salvar patrimônio.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      salvando.value = false;
    }
  }

  Future<void> atualizarPatrimonio(int id) async {
    if (!formularioChave.currentState!.validate()) return;

    salvando.value = true;
    try {
      final dados = {
        'tombamento': tombamentoController.text.trim(),
        'descricao': descricaoController.text.trim(),
        'categoria': categoriaController.text.trim(),
        'marca': marcaController.text.trim(),
        'modelo': modeloController.text.trim(),
        'numero_serie': numeroSerieController.text.trim(),
        'localizacao': localizacaoController.text.trim(),
        'observacoes': observacoesController.text.trim(),
      };

      final resposta = await _patrimonioServico.atualizarPatrimonio(id, dados);

      if (resposta.isOk) {
        _limparFormulario();
        Get.back();
        await carregarPatrimonios();
        Get.snackbar('Sucesso', 'Patrimônio atualizado!',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade600, colorText: Colors.white);
      } else {
        Get.snackbar('Erro', _api.tratarErro(resposta),
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar patrimônio.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      salvando.value = false;
    }
  }

  Future<void> excluirPatrimonio(int id) async {
    salvando.value = true;
    try {
      final resposta = await _patrimonioServico.excluirPatrimonio(id);

      if (resposta.isOk) {
        await carregarPatrimonios();
        Get.snackbar('Sucesso', 'Patrimônio removido.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade600, colorText: Colors.white);
      } else {
        Get.snackbar('Erro ao Excluir', _api.tratarErro(resposta),
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível excluir o patrimônio.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      salvando.value = false;
    }
  }

  Future<void> atribuirPatrimonio({required int patrimonioId, required int professorId}) async {
    salvando.value = true;
    try {
      final resposta = await _patrimonioServico.atribuirPatrimonio(
        patrimonioId,
        professorId,
        observacao: observacaoAtribuicaoController.text.trim(),
      );

      if (resposta.isOk) {
        observacaoAtribuicaoController.clear();
        professorIdSelecionadoParaAtribuicao.value = null;
        Get.back();
        await carregarPatrimonios();
        Get.snackbar('Atribuição Concluída', 'O bem agora está sob responsabilidade do docente.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade600, colorText: Colors.white);
      } else {
        Get.snackbar('Falha na Atribuição', _api.tratarErro(resposta),
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao processar atribuição.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      salvando.value = false;
    }
  }

  Future<void> devolverPatrimonio(int patrimonioId) async {
    if (!formularioDevolucaoChave.currentState!.validate()) return;

    salvando.value = true;
    try {
      final resposta = await _patrimonioServico.devolverPatrimonio(
        patrimonioId,
        motivo: motivoDevolucaoController.text.trim(),
      );

      if (resposta.isOk) {
        motivoDevolucaoController.clear();
        Get.back();
        await carregarPatrimonios();
        Get.snackbar('Devolução Registrada', 'O bem retornou ao estoque com status disponível.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade600, colorText: Colors.white);
      } else {
        Get.snackbar('Falha na Devolução', _api.tratarErro(resposta),
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao processar devolução.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      salvando.value = false;
    }
  }

  Future<void> carregarHistorico(int patrimonioId) async {
    carregandoHistorico.value = true;
    historicoLista.clear();

    try {
      final resposta = await _patrimonioServico.obterHistoricoPatrimonio(patrimonioId);

      if (resposta.isOk && resposta.body != null) {
        final List<dynamic> dados = resposta.body is List
            ? resposta.body
            : (resposta.body['historico'] ?? resposta.body['data'] ?? []);

        historicoLista.value = dados
            .map((item) => HistoricoMovimentacaoModelo.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
    } finally {
      carregandoHistorico.value = false;
    }
  }

  void prepararEdicao(PatrimonioModelo item) {
    patrimonioSelecionado.value = item;
    tombamentoController.text = item.tombamento;
    descricaoController.text = item.descricao;
    categoriaController.text = item.categoria;
    marcaController.text = item.marca ?? '';
    modeloController.text = item.modelo ?? '';
    numeroSerieController.text = item.numeroSerie ?? '';
    localizacaoController.text = item.localizacao ?? '';
    observacoesController.text = item.observacoes ?? '';
  }

  void _limparFormulario() {
    patrimonioSelecionado.value = null;
    tombamentoController.clear();
    descricaoController.clear();
    categoriaController.clear();
    marcaController.clear();
    modeloController.clear();
    numeroSerieController.clear();
    localizacaoController.clear();
    observacoesController.clear();
  }

  void verDetalhes(PatrimonioModelo item) {
    patrimonioSelecionado.value = item;
    if (item.id != null) {
      carregarHistorico(item.id!);
    }
    Get.toNamed(RotasApp.ADMIN_DETALHES_PATRIMONIO);
  }
}
