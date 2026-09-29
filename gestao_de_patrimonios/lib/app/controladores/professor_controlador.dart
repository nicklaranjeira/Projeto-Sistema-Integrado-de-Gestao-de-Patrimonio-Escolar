import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dados/modelos/professor_modelo.dart';
import '../dados/servicos/api_servico.dart';
import '../dados/servicos/professor_servico.dart';
import '../rotas/rotas_app.dart';

class ProfessorControlador extends GetxController {
  final ProfessorServico _professorServico = Get.find<ProfessorServico>();
  final ApiServico _api = Get.find<ApiServico>();

  final RxBool carregando = false.obs;
  final RxBool salvando = false.obs;
  final RxBool carregandoDetalhes = false.obs;
  final RxString mensagemErro = ''.obs;

  final RxList<ProfessorModelo> professores = <ProfessorModelo>[].obs;
  final RxList<ProfessorModelo> professoresFiltrados = <ProfessorModelo>[].obs;

  final Rx<ProfessorModelo?> professorSelecionado = Rx<ProfessorModelo?>(null);

  final RxString textoBusca = ''.obs;

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final matriculaController = TextEditingController();
  final departamentoController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaProvisoriaController = TextEditingController();

  final formularioChave = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    carregarProfessores();
  }

  @override
  void onClose() {
    nomeController.dispose();
    emailController.dispose();
    matriculaController.dispose();
    departamentoController.dispose();
    telefoneController.dispose();
    senhaProvisoriaController.dispose();
    super.onClose();
  }

  Future<void> carregarProfessores() async {
    carregando.value = true;
    mensagemErro.value = '';

    try {
      final resposta = await _professorServico.obterProfessores();

      if (resposta.isOk && resposta.body != null) {
        final List<dynamic> dados = resposta.body is List
            ? resposta.body
            : (resposta.body['professores'] ?? resposta.body['data'] ?? []);

        professores.value = dados
            .map((item) => ProfessorModelo.fromJson(item as Map<String, dynamic>))
            .toList();

        _aplicarFiltro();
      } else {
        mensagemErro.value = _api.tratarErro(resposta);
      }
    } catch (e) {
      mensagemErro.value = 'Falha ao carregar lista de professores.';
    } finally {
      carregando.value = false;
    }
  }

  void aoMudarBusca(String busca) {
    textoBusca.value = busca;
    _aplicarFiltro();
  }

  void _aplicarFiltro() {
    if (textoBusca.value.trim().isEmpty) {
      professoresFiltrados.assignAll(professores);
      return;
    }

    final termo = textoBusca.value.toLowerCase();
    professoresFiltrados.assignAll(
      professores.where((prof) {
        return prof.nome.toLowerCase().contains(termo) ||
            prof.email.toLowerCase().contains(termo) ||
            prof.matricula.toLowerCase().contains(termo) ||
            prof.departamento.toLowerCase().contains(termo);
      }).toList(),
    );
  }

  Future<void> cadastrarProfessor() async {
    if (!formularioChave.currentState!.validate()) return;

    salvando.value = true;
    try {
      final resposta = await _professorServico.cadastrarProfessor(
        nome: nomeController.text,
        email: emailController.text,
        matricula: matriculaController.text,
        departamento: departamentoController.text,
        telefone: telefoneController.text,
        senhaProvisoria: senhaProvisoriaController.text,
      );

      if (resposta.isOk) {
        _limparFormulario();
        Get.back();
        await carregarProfessores();
        Get.snackbar(
          'Professor Cadastrado!',
          'O docente foi inserido com sucesso. Informe a senha provisória ao professor.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Erro no Cadastro',
          _api.tratarErro(resposta),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao processar cadastro do docente.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      salvando.value = false;
    }
  }

  Future<void> verDetalhesProfessor(int id) async {
    carregandoDetalhes.value = true;
    Get.toNamed(RotasApp.ADMIN_DETALHES_PROFESSOR);

    try {
      final resposta = await _professorServico.obterProfessorPorId(id);

      if (resposta.isOk && resposta.body != null) {
        final Map<String, dynamic> dados =
            resposta.body is Map ? Map<String, dynamic>.from(resposta.body) : {};
        professorSelecionado.value = ProfessorModelo.fromJson(dados);
      } else {
        Get.snackbar('Aviso', _api.tratarErro(resposta),
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange.shade700, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao obter detalhes do professor.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      carregandoDetalhes.value = false;
    }
  }

  void _limparFormulario() {
    nomeController.clear();
    emailController.clear();
    matriculaController.clear();
    departamentoController.clear();
    telefoneController.clear();
    senhaProvisoriaController.clear();
  }
}
