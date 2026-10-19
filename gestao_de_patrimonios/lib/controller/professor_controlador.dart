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
  final usuarioAcessoController = TextEditingController();
  final senhaAcessoController = TextEditingController();

  static final List<ProfessorModelo> professoresCadastradosEmMemoria = [];

  @override
  void onInit() {
    super.onInit();
    nomeController.addListener(_atualizarCredenciaisAcesso);
    matriculaController.addListener(_atualizarCredenciaisAcesso);
    listarProfessores();
  }

  void _atualizarCredenciaisAcesso() {
    usuarioAcessoController.text = nomeController.text.trim();
    final mat = matriculaController.text.trim();
    final digitos = mat.replaceAll(RegExp(r'\D'), '');
    if (digitos.length >= 6) {
      senhaAcessoController.text = digitos;
    } else if (digitos.isNotEmpty) {
      senhaAcessoController.text = 'prof$digitos'.padRight(6, '0');
    } else if (mat.length >= 6) {
      senhaAcessoController.text = mat;
    } else if (mat.isNotEmpty) {
      senhaAcessoController.text = 'prof$mat'.padRight(6, '0');
    } else {
      senhaAcessoController.text = '';
    }
  }

  @override
  void onClose() {
    nomeController.removeListener(_atualizarCredenciaisAcesso);
    matriculaController.removeListener(_atualizarCredenciaisAcesso);
    nomeController.dispose();
    emailController.dispose();
    matriculaController.dispose();
    departamentoController.dispose();
    telefoneController.dispose();
    usuarioAcessoController.dispose();
    senhaAcessoController.dispose();
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
        final List dados = resposta.body is List
            ? resposta.body
            : (resposta.body['professores'] ?? resposta.body['data'] ?? []);
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
        final dados = Map<String, dynamic>.from(
            resposta.body is Map ? (resposta.body['professor'] ?? resposta.body) : {});
        professorSelecionado.value = ProfessorModelo.fromJson(dados);
        if (resposta.body is Map && resposta.body['patrimonios'] is List) {
          final List bens = resposta.body['patrimonios'];
          patrimoniosDoProfessor.assignAll(
            bens.map((e) => PatrimonioModelo.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
          );
        } else {
          await carregarPatrimoniosDoProfessor(id);
        }
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
        final List dados = resposta.body is List
            ? resposta.body
            : (resposta.body['patrimonios'] ?? resposta.body['items'] ?? resposta.body['data'] ?? []);
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
    _atualizarCredenciaisAcesso();
  }

  Future<void> salvarProfessor() async {
    if (!formularioChave.currentState!.validate()) return;

    final nome = nomeController.text.trim();
    final matricula = matriculaController.text.trim().isEmpty ? null : matriculaController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final usuario = usuarioAcessoController.text.trim().isNotEmpty ? usuarioAcessoController.text.trim() : nome;
    String senha = senhaAcessoController.text.trim();

    if (senha.isEmpty) {
      final digitos = (matricula ?? '').replaceAll(RegExp(r'\D'), '');
      if (digitos.length >= 6) {
        senha = digitos;
      } else if (digitos.isNotEmpty) {
        senha = 'prof$digitos'.padRight(6, '0');
      } else {
        senha = 'prof123';
      }
    }

    if (senha.length < 6) {
      _exibirErro('Validação', 'A senha de acesso do professor deve conter no mínimo 6 caracteres.');
      return;
    }

    salvando.value = true;
    try {
      final dados = {
        'nome': nome,
        'email': email,
        'password': senha,
        'senha': senha,
        'matricula': matricula,
        'departamento': departamentoController.text.trim().isEmpty ? null : departamentoController.text.trim(),
        'telefone': telefoneController.text.trim().isEmpty ? null : telefoneController.text.trim(),
        'usuario': usuario,
      };

      Response resposta;
      final bool ehEdicao = professorSelecionado.value != null;

      if (ehEdicao) {
        resposta = await _professorServico.atualizarProfessor(professorSelecionado.value!.id, dados);
      } else {
        resposta = await _professorServico.cadastrarProfessor(dados);
      }

      if (resposta.isOk) {
        final Map corpoResp = resposta.body is Map ? resposta.body : {};
        final Map profApi = corpoResp['professor'] is Map ? corpoResp['professor'] : corpoResp;
        final int idGerado = profApi['id'] is int
            ? profApi['id']
            : (ehEdicao ? professorSelecionado.value!.id : DateTime.now().millisecondsSinceEpoch);

        final novoProf = ProfessorModelo(
          id: idGerado,
          nome: profApi['nome']?.toString() ?? nome,
          email: profApi['email']?.toString() ?? email,
          matricula: profApi['matricula']?.toString() ?? matricula,
          departamento: profApi['departamento']?.toString() ?? (departamentoController.text.trim().isEmpty ? null : departamentoController.text.trim()),
          telefone: profApi['telefone']?.toString() ?? (telefoneController.text.trim().isEmpty ? null : telefoneController.text.trim()),
          status: 'ativo',
        );

        if (!ehEdicao) {
          professoresCadastradosEmMemoria.add(novoProf);
          listaProfessores.add(novoProf);
          aplicarFiltrosLocais();
        }

        _limparFormulario();
        await listarProfessores();
        Get.back();
        Get.snackbar(
          ehEdicao ? 'Sucesso' : 'Professor Cadastrado com Sucesso!',
          ehEdicao
              ? 'Professor atualizado com sucesso!'
              : 'Credenciais de Acesso:\n• E-mail (Login): $email\n• Senha: $senha\n• Matrícula: ${matricula ?? "-"}\n\nO professor deve entrar utilizando este E-MAIL e SENHA.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
        );
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirErro('Falha no Cadastro do Professor', erro);
      }
    } catch (e) {
      _exibirErro('Erro de Conexão', 'Não foi possível comunicar com a API. Verifique se o backend está em execução.');
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
    usuarioAcessoController.clear();
    senhaAcessoController.clear();
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
