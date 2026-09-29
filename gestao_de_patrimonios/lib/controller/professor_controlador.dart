import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/patrimonio_modelo.dart';
import '../model/professor_modelo.dart';
import '../service/api_servico.dart';
import '../service/professor_servico.dart';
import '../routes/rotas_app.dart';

class ProfessorControlador extends GetxController {
  final ProfessorServico _professorServico = Get.find<ProfessorServico>();
  final ApiServico _api = Get.find<ApiServico>();

  final RxBool carregando = false.obs;
  final RxBool carregandoDetalhes = false.obs;
  final RxBool salvando = false.obs;

  final RxList<ProfessorModelo> listaProfessores = <ProfessorModelo>[].obs;
  final RxList<ProfessorModelo> listaFiltrada = <ProfessorModelo>[].obs;
  final Rx<ProfessorModelo?> professorSelecionado = Rx<ProfessorModelo?>(null);
  final RxList<PatrimonioModelo> patrimoniosDoProfessor = <PatrimonioModelo>[].obs;

  final RxString filtroStatus = ''.obs;
  final RxString buscaTexto = ''.obs;

  final formularioChave = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final matriculaController = TextEditingController();
  final departamentoController = TextEditingController();
  final telefoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    listarProfessores();
  }

  @override
  void onClose() {
    nomeController.dispose();
    emailController.dispose();
    matriculaController.dispose();
    departamentoController.dispose();
    telefoneController.dispose();
    super.onClose();
  }

  Future<void> listarProfessores() async {
    carregando.value = true;
    try {
      final resposta = await _professorServico.listarProfessores(
        status: filtroStatus.value.isEmpty ? null : filtroStatus.value,
        busca: buscaTexto.value.isEmpty ? null : buscaTexto.value,
      );

      if (resposta.isOk && resposta.body != null) {
        final List dados = resposta.body is List ? resposta.body : (resposta.body['data'] ?? []);
        final professores = dados
            .map((e) => ProfessorModelo.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

        listaProfessores.assignAll(professores);
        aplicarFiltrosLocais();
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirErro('Erro', erro);
      }
    } catch (e) {
      _exibirErro('Erro de Conexão', 'Não foi possível listar os professores.');
    } finally {
      carregando.value = false;
    }
  }

  void aplicarFiltrosLocais() {
    List<ProfessorModelo> resultado = List.from(listaProfessores);

    if (buscaTexto.value.isNotEmpty) {
      final busca = buscaTexto.value.toLowerCase();
      resultado = resultado.where((p) {
        return p.nome.toLowerCase().contains(busca) ||
            p.email.toLowerCase().contains(busca) ||
            (p.matricula?.toLowerCase().contains(busca) ?? false) ||
            (p.departamento?.toLowerCase().contains(busca) ?? false);
      }).toList();
    }

    if (filtroStatus.value.isNotEmpty) {
      resultado = resultado.where((p) => p.status.toLowerCase() == filtroStatus.value.toLowerCase()).toList();
    }

    listaFiltrada.assignAll(resultado);
  }

  void definirFiltroStatus(String? status) {
    filtroStatus.value = status ?? '';
    aplicarFiltrosLocais();
  }

  void buscar(String texto) {
    buscaTexto.value = texto;
    aplicarFiltrosLocais();
  }

  void limparFiltros() {
    filtroStatus.value = '';
    buscaTexto.value = '';
    aplicarFiltrosLocais();
  }

  Future<void> carregarDetalhesProfessor(int id) async {
    carregandoDetalhes.value = true;
    try {
      final resposta = await _professorServico.obterProfessorPorId(id);
      if (resposta.isOk && resposta.body != null) {
        final dados = Map<String, dynamic>.from(resposta.body is Map ? resposta.body : {});
        professorSelecionado.value = ProfessorModelo.fromJson(dados);
        await carregarPatrimoniosDoProfessor(id);
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirErro('Erro', erro);
      }
    } catch (e) {
      _exibirErro('Erro', 'Falha ao carregar detalhes do professor.');
    } finally {
      carregandoDetalhes.value = false;
    }
  }

  Future<void> carregarPatrimoniosDoProfessor(int professorId) async {
    try {
      final resposta = await _professorServico.obterPatrimoniosDoProfessor(professorId);
      if (resposta.isOk && resposta.body != null) {
        final List dados = resposta.body is List ? resposta.body : (resposta.body['data'] ?? []);
        final patrimonios = dados
            .map((e) => PatrimonioModelo.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        patrimoniosDoProfessor.assignAll(patrimonios);
      }
    } catch (_) {
    }
  }

  void prepararCadastro() {
    _limparFormulario();
    professorSelecionado.value = null;
  }

  void prepararEdicao(ProfessorModelo professor) {
    professorSelecionado.value = professor;
    nomeController.text = professor.nome;
    emailController.text = professor.email;
    matriculaController.text = professor.matricula ?? '';
    departamentoController.text = professor.departamento ?? '';
    telefoneController.text = professor.telefone ?? '';
  }

  Future<void> salvarProfessor() async {
    if (!formularioChave.currentState!.validate()) return;

    salvando.value = true;
    try {
      final dados = {
        'nome': nomeController.text.trim(),
        'email': emailController.text.trim(),
        'matricula': matriculaController.text.trim().isEmpty ? null : matriculaController.text.trim(),
        'departamento': departamentoController.text.trim().isEmpty ? null : departamentoController.text.trim(),
        'telefone': telefoneController.text.trim().isEmpty ? null : telefoneController.text.trim(),
      };

      Response resposta;
      final bool ehEdicao = professorSelecionado.value != null;

      if (ehEdicao) {
        resposta = await _professorServico.atualizarProfessor(professorSelecionado.value!.id, dados);
      } else {
        resposta = await _professorServico.cadastrarProfessor(dados);
      }

      if (resposta.isOk) {
        _limparFormulario();
        await listarProfessores();
        Get.back();
        Get.snackbar(
          'Sucesso',
          ehEdicao ? 'Professor atualizado com sucesso!' : 'Professor cadastrado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirErro('Erro ao Salvar', erro);
      }
    } catch (e) {
      _exibirErro('Erro', 'Ocorreu um erro ao salvar o professor.');
    } finally {
      salvando.value = false;
    }
  }

  Future<void> alterarStatusProfessor(int professorId, String novoStatus) async {
    salvando.value = true;
    try {
      final resposta = await _professorServico.alterarStatus(professorId, novoStatus);
      if (resposta.isOk) {
        await carregarDetalhesProfessor(professorId);
        await listarProfessores();
        Get.snackbar(
          'Status Atualizado',
          'Status alterado para "$novoStatus" com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirErro('Falha na Alteração', erro);
      }
    } catch (e) {
      _exibirErro('Erro', 'Não foi possível alterar o status do professor.');
    } finally {
      salvando.value = false;
    }
  }

  void _limparFormulario() {
    nomeController.clear();
    emailController.clear();
    matriculaController.clear();
    departamentoController.clear();
    telefoneController.clear();
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
