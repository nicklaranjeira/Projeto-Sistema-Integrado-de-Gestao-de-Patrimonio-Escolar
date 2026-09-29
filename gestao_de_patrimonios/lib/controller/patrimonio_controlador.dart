import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/historico_movimentacao_modelo.dart';
import '../model/patrimonio_modelo.dart';
import '../model/professor_modelo.dart';
import '../service/api_servico.dart';
import '../service/patrimonio_servico.dart';
import '../service/professor_servico.dart';
import '../routes/rotas_app.dart';

class PatrimonioControlador extends GetxController {
  final PatrimonioServico _patrimonioServico = Get.find<PatrimonioServico>();
  final ProfessorServico _professorServico = Get.find<ProfessorServico>();
  final ApiServico _api = Get.find<ApiServico>();

  final RxBool carregando = false.obs;
  final RxBool carregandoDetalhes = false.obs;
  final RxBool carregandoProfessores = false.obs;
  final RxBool salvando = false.obs;

  final RxList<PatrimonioModelo> listaPatrimonios = <PatrimonioModelo>[].obs;
  final RxList<PatrimonioModelo> listaFiltrada = <PatrimonioModelo>[].obs;
  final Rx<PatrimonioModelo?> patrimonioSelecionado = Rx<PatrimonioModelo?>(null);
  final RxList<HistoricoMovimentacaoModelo> historicoMovimentacoes = <HistoricoMovimentacaoModelo>[].obs;
  final RxList<ProfessorModelo> listaProfessoresAtivos = <ProfessorModelo>[].obs;

  final RxString filtroStatus = ''.obs;
  final RxString filtroCategoria = ''.obs;
  final RxString buscaTexto = ''.obs;

  final Rx<ProfessorModelo?> professorSelecionadoParaAlocacao = Rx<ProfessorModelo?>(null);

  final formularioChave = GlobalKey<FormState>();
  final formularioAlocacaoChave = GlobalKey<FormState>();
  final formularioDevolucaoChave = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final numeroTomboController = TextEditingController();
  final numeroSerieController = TextEditingController();
  final categoriaController = TextEditingController();
  final localizacaoController = TextEditingController();
  final descricaoController = TextEditingController();
  final observacoesAlocacaoController = TextEditingController();
  final observacoesDevolucaoController = TextEditingController();

  final List<String> categoriasDisponiveis = [
    'Eletrônicos',
    'Mobiliário',
    'Informática',
    'Audiovisual',
    'Laboratório',
    'Esportivo',
    'Outros',
  ];

  final List<String> statusDisponiveis = [
    'disponivel',
    'alocado',
    'manutencao',
    'baixado',
  ];

  @override
  void onInit() {
    super.onInit();
    listarPatrimonios();
  }

  @override
  void onClose() {
    nomeController.dispose();
    numeroTomboController.dispose();
    numeroSerieController.dispose();
    categoriaController.dispose();
    localizacaoController.dispose();
    descricaoController.dispose();
    observacoesAlocacaoController.dispose();
    observacoesDevolucaoController.dispose();
    super.onClose();
  }

  Future<void> listarPatrimonios() async {
    carregando.value = true;
    try {
      final resposta = await _patrimonioServico.listarPatrimonios(
        status: filtroStatus.value.isEmpty ? null : filtroStatus.value,
        categoria: filtroCategoria.value.isEmpty ? null : filtroCategoria.value,
        busca: buscaTexto.value.isEmpty ? null : buscaTexto.value,
      );

      if (resposta.isOk && resposta.body != null) {
        final List dados = resposta.body is List ? resposta.body : (resposta.body['data'] ?? []);
        final patrimonios = dados
            .map((e) => PatrimonioModelo.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

        listaPatrimonios.assignAll(patrimonios);
        aplicarFiltrosLocais();
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirErro('Erro ao carregar patrimônios', erro);
      }
    } catch (e) {
      _exibirErro('Erro de Conexão', 'Não foi possível buscar os patrimônios.');
    } finally {
      carregando.value = false;
    }
  }

  void aplicarFiltrosLocais() {
    List<PatrimonioModelo> resultado = List.from(listaPatrimonios);

    if (buscaTexto.value.isNotEmpty) {
      final busca = buscaTexto.value.toLowerCase();
      resultado = resultado.where((p) {
        return p.nome.toLowerCase().contains(busca) ||
            p.numeroTombo.toLowerCase().contains(busca) ||
            (p.numeroSerie?.toLowerCase().contains(busca) ?? false) ||
            (p.categoria?.toLowerCase().contains(busca) ?? false);
      }).toList();
    }

    if (filtroStatus.value.isNotEmpty) {
      resultado = resultado.where((p) => p.status.toLowerCase() == filtroStatus.value.toLowerCase()).toList();
    }

    if (filtroCategoria.value.isNotEmpty) {
      resultado = resultado.where((p) => (p.categoria ?? '').toLowerCase() == filtroCategoria.value.toLowerCase()).toList();
    }

    listaFiltrada.assignAll(resultado);
  }

  void definirFiltroStatus(String? status) {
    filtroStatus.value = status ?? '';
    aplicarFiltrosLocais();
  }

  void definirFiltroCategoria(String? categoria) {
    filtroCategoria.value = categoria ?? '';
    aplicarFiltrosLocais();
  }

  void buscar(String texto) {
    buscaTexto.value = texto;
    aplicarFiltrosLocais();
  }

  void limparFiltros() {
    filtroStatus.value = '';
    filtroCategoria.value = '';
    buscaTexto.value = '';
    aplicarFiltrosLocais();
  }

  Future<void> carregarDetalhesPatrimonio(int id) async {
    carregandoDetalhes.value = true;
    try {
      final resposta = await _patrimonioServico.obterPatrimonioPorId(id);
      if (resposta.isOk && resposta.body != null) {
        final dados = Map<String, dynamic>.from(resposta.body is Map ? resposta.body : {});
        patrimonioSelecionado.value = PatrimonioModelo.fromJson(dados);
        await carregarHistoricoMovimentacoes(id);
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirErro('Erro', erro);
      }
    } catch (e) {
      _exibirErro('Erro', 'Falha ao obter detalhes do patrimônio.');
    } finally {
      carregandoDetalhes.value = false;
    }
  }

  Future<void> carregarHistoricoMovimentacoes(int patrimonioId) async {
    try {
      final resposta = await _patrimonioServico.obterHistoricoMovimentacoes(patrimonioId);
      if (resposta.isOk && resposta.body != null) {
        final List dados = resposta.body is List ? resposta.body : (resposta.body['data'] ?? []);
        final historico = dados
            .map((e) => HistoricoMovimentacaoModelo.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        historicoMovimentacoes.assignAll(historico);
      }
    } catch (_) {
    }
  }

  void prepararCadastro() {
    _limparFormulario();
    patrimonioSelecionado.value = null;
  }

  void prepararEdicao(PatrimonioModelo patrimonio) {
    patrimonioSelecionado.value = patrimonio;
    nomeController.text = patrimonio.nome;
    numeroTomboController.text = patrimonio.numeroTombo;
    numeroSerieController.text = patrimonio.numeroSerie ?? '';
    categoriaController.text = patrimonio.categoria ?? '';
    localizacaoController.text = patrimonio.localizacao ?? '';
    descricaoController.text = patrimonio.descricao ?? '';
  }

  Future<void> salvarPatrimonio() async {
    if (!formularioChave.currentState!.validate()) return;

    salvando.value = true;
    try {
      final dados = {
        'nome': nomeController.text.trim(),
        'numero_tombo': numeroTomboController.text.trim(),
        'numero_serie': numeroSerieController.text.trim().isEmpty ? null : numeroSerieController.text.trim(),
        'categoria': categoriaController.text.trim().isEmpty ? null : categoriaController.text.trim(),
        'localizacao': localizacaoController.text.trim().isEmpty ? null : localizacaoController.text.trim(),
        'descricao': descricaoController.text.trim().isEmpty ? null : descricaoController.text.trim(),
      };

      Response resposta;
      final bool ehEdicao = patrimonioSelecionado.value != null;

      if (ehEdicao) {
        resposta = await _patrimonioServico.atualizarPatrimonio(patrimonioSelecionado.value!.id, dados);
      } else {
        resposta = await _patrimonioServico.cadastrarPatrimonio(dados);
      }

      if (resposta.isOk) {
        _limparFormulario();
        await listarPatrimonios();
        Get.back();
        Get.snackbar(
          'Sucesso',
          ehEdicao ? 'Patrimônio atualizado com sucesso!' : 'Patrimônio cadastrado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirErro('Erro ao Salvar', erro);
      }
    } catch (e) {
      _exibirErro('Erro', 'Ocorreu um erro ao salvar o patrimônio.');
    } finally {
      salvando.value = false;
    }
  }

  Future<void> carregarProfessoresParaAlocacao() async {
    carregandoProfessores.value = true;
    try {
      final resposta = await _professorServico.listarProfessores(status: 'ativo');
      if (resposta.isOk && resposta.body != null) {
        final List dados = resposta.body is List ? resposta.body : (resposta.body['data'] ?? []);
        final professores = dados
            .map((e) => ProfessorModelo.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        listaProfessoresAtivos.assignAll(professores);
      }
    } catch (_) {
    } finally {
      carregandoProfessores.value = false;
    }
  }

  Future<void> alocarPatrimonio({required int patrimonioId, required int professorId}) async {
    salvando.value = true;
    try {
      final resposta = await _patrimonioServico.alocarPatrimonio(
        patrimonioId: patrimonioId,
        professorId: professorId,
        observacoes: observacoesAlocacaoController.text.trim().isEmpty
            ? null
            : observacoesAlocacaoController.text.trim(),
      );

      if (resposta.isOk) {
        observacoesAlocacaoController.clear();
        professorSelecionadoParaAlocacao.value = null;
        await carregarDetalhesPatrimonio(patrimonioId);
        await listarPatrimonios();
        Get.back();
        Get.snackbar(
          'Patrimônio Alocado',
          'O item foi vinculado ao docente com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirErro('Falha na Alocação', erro);
      }
    } catch (e) {
      _exibirErro('Erro', 'Não foi possível alocar o patrimônio.');
    } finally {
      salvando.value = false;
    }
  }

  Future<void> devolverPatrimonio({required int patrimonioId}) async {
    salvando.value = true;
    try {
      final resposta = await _patrimonioServico.devolverPatrimonio(
        patrimonioId: patrimonioId,
        observacoes: observacoesDevolucaoController.text.trim().isEmpty
            ? null
            : observacoesDevolucaoController.text.trim(),
      );

      if (resposta.isOk) {
        observacoesDevolucaoController.clear();
        await carregarDetalhesPatrimonio(patrimonioId);
        await listarPatrimonios();
        Get.back();
        Get.snackbar(
          'Devolução Registrada',
          'O item retornou ao status de disponível.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirErro('Falha na Devolução', erro);
      }
    } catch (e) {
      _exibirErro('Erro', 'Não foi possível registrar a devolução.');
    } finally {
      salvando.value = false;
    }
  }

  Future<void> desativarPatrimonio(int patrimonioId, {String? motivo}) async {
    salvando.value = true;
    try {
      final resposta = await _patrimonioServico.desativarPatrimonio(patrimonioId, motivo: motivo);
      if (resposta.isOk) {
        await carregarDetalhesPatrimonio(patrimonioId);
        await listarPatrimonios();
        Get.snackbar(
          'Patrimônio Baixado',
          'O item foi marcado como desativado/baixado.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
        );
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirErro('Falha ao Desativar', erro);
      }
    } catch (e) {
      _exibirErro('Erro', 'Não foi possível desativar o patrimônio.');
    } finally {
      salvando.value = false;
    }
  }

  void _limparFormulario() {
    nomeController.clear();
    numeroTomboController.clear();
    numeroSerieController.clear();
    categoriaController.clear();
    localizacaoController.clear();
    descricaoController.clear();
    observacoesAlocacaoController.clear();
    observacoesDevolucaoController.clear();
  }

  void _exibirErro(String titulo, String mensagem) {
    Get.snackbar(
      titulo,
      mensagem,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
