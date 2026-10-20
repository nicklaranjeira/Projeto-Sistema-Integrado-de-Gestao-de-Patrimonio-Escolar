import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/usuario_modelo.dart';
import '../service/api_servico.dart';
import '../service/armazenamento_servico.dart';
import '../service/autenticacao_servico.dart';
import '../service/jwt_servico.dart';
import '../routes/rotas_app.dart';
import 'professor_controlador.dart';

class AutenticacaoControlador extends GetxController {
  final AutenticacaoServico _autenticacaoServico = Get.find<AutenticacaoServico>();
  final ArmazenamentoServico _armazenamento = Get.find<ArmazenamentoServico>();
  final ApiServico _api = Get.find<ApiServico>();

  final RxBool carregando = false.obs;
  final RxBool senhaVisivel = false.obs;
  final RxBool confirmarSenhaVisivel = false.obs;
  final Rx<UsuarioModelo?> usuarioAtual = Rx<UsuarioModelo?>(null);
  final RxString emailRecuperacao = ''.obs;
  final RxString codigoRecuperacao = ''.obs;

  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  final nomeController = TextEditingController();
  final departamentoController = TextEditingController();
  final telefoneController = TextEditingController();
  final cpfController = TextEditingController();
  final codigoController = TextEditingController();

  final formularioLoginChave = GlobalKey<FormState>();
  final formularioCadastroChave = GlobalKey<FormState>();
  final formularioEsqueciSenhaChave = GlobalKey<FormState>();
  final formularioValidarCodigoChave = GlobalKey<FormState>();
  final formularioRedefinirSenhaChave = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    usuarioAtual.value = _armazenamento.obterUsuario();
  }

  @override
  void onClose() {
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    nomeController.dispose();
    departamentoController.dispose();
    telefoneController.dispose();
    cpfController.dispose();
    codigoController.dispose();
    super.onClose();
  }

  void alternarVisibilidadeSenha() => senhaVisivel.toggle();
  void alternarVisibilidadeConfirmarSenha() => confirmarSenhaVisivel.toggle();

  Future<void> verificarStatusAutenticacao() async {
    final token = _armazenamento.obterToken();
    final usuario = _armazenamento.obterUsuario();

    if (token != null && token.isNotEmpty && usuario != null) {
      if (JwtServico.estaExpirado(token)) {
        await _armazenamento.limparTudo();
        usuarioAtual.value = null;
        Get.offAllNamed(RotasApp.LOGIN);
        return;
      }
      usuarioAtual.value = usuario;
      final papelJwt = JwtServico.extrairRole(token);
      _redirecionarPorPapel(papelJwt);
    } else {
      Get.offAllNamed(RotasApp.LOGIN);
    }
  }

  Future<void> login() async {
    if (!formularioLoginChave.currentState!.validate()) return;

    final senha = senhaController.text.trim();
    final identificador = emailController.text.trim();
    String emailLogin = identificador.toLowerCase();

    // Se o usuário digitou nome ou matrícula sem '@', tenta resolver para o e-mail cadastrado
    if (!emailLogin.contains('@')) {
      final prof = ProfessorControlador.professoresCadastradosEmMemoria.firstWhereOrNull((p) {
        return p.nome.toLowerCase() == emailLogin ||
            (p.matricula != null && p.matricula!.toLowerCase() == emailLogin) ||
            p.email.toLowerCase().startsWith(emailLogin);
      });

      if (prof != null) {
        emailLogin = prof.email.toLowerCase();
      } else if (emailLogin.contains('carlos drummond') || emailLogin == 'carlos') {
        emailLogin = 'professor@escola.com';
      } else if (emailLogin.contains('maria silva') || emailLogin == 'maria') {
        emailLogin = 'maria.silva@escola.com';
      } else if (emailLogin == 'admin' || emailLogin == 'coordenador') {
        emailLogin = 'admin@admin.com';
      } else {
        emailLogin = '${emailLogin.replaceAll(' ', '.')}@escola.edu.br';
      }
    }

    carregando.value = true;
    try {
      Response resposta = await _autenticacaoServico.login(
        emailLogin,
        senha,
      );

      // Se falhou e tínhamos tentado inferir um e-mail diferente da entrada bruta, tenta com a entrada bruta
      if (!resposta.isOk && emailLogin != identificador.toLowerCase()) {
        final retry = await _autenticacaoServico.login(
          identificador,
          senha,
        );
        if (retry.isOk) {
          resposta = retry;
        }
      }

      if (resposta.isOk && resposta.body != null) {
        final dados = resposta.body is Map ? resposta.body : {};
        
        final String token = dados['token'] ?? dados['access_token'] ?? '';
        final String? refreshToken = dados['refresh_token'] ?? dados['refreshToken'];
        
        Map<String, dynamic> mapaUsuario = {};
        if (dados['user'] is Map) {
          mapaUsuario = Map<String, dynamic>.from(dados['user']);
        } else {
          mapaUsuario = Map<String, dynamic>.from(dados);
        }

        // VERIFICAÇÃO DO ROLE DIRETAMENTE DAS CLAIMS DO JWT
        final papel = JwtServico.extrairRole(token);
        final ehAdmin = JwtServico.ehAdmin(token);

        final usuario = UsuarioModelo.fromJson(mapaUsuario).copyWith(
          token: token,
          refreshToken: refreshToken,
          papel: papel,
          password: senha,
          cpf: mapaUsuario['cpf'] ?? (ehAdmin ? '123.456.789-01' : '987.654.321-02'),
          telefone: mapaUsuario['telefone'] ?? (ehAdmin ? '(11) 98765-4321' : '(11) 91234-5678'),
          departamento: mapaUsuario['departamento'] ?? (ehAdmin ? 'Coordenação Pedagógica' : 'Letras e Literatura'),
        );

        await _armazenamento.salvarToken(token);
        if (refreshToken != null) {
          await _armazenamento.salvarRefreshToken(refreshToken);
        }
        await _armazenamento.salvarUsuario(usuario);

        usuarioAtual.value = usuario;
        _limparCampos();

        Get.snackbar(
          'Sucesso',
          'Bem-vindo(a), ${usuario.nome}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        _redirecionarPorPapel(usuario.papel);
      } else {
        final erro = _api.tratarErro(resposta);
        Get.snackbar(
          'Falha no Login',
          erro.isNotEmpty ? erro : 'Credenciais inválidas. Verifique seu e-mail e senha.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro de Conexão',
        'Não foi possível conectar ao servidor da API (http://localhost:8081).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      carregando.value = false;
    }
  }

  Future<void> cadastrarCoordenador() async {
    if (!formularioCadastroChave.currentState!.validate()) return;

    if (senhaController.text != confirmarSenhaController.text) {
      _exibirMensagemErro('Validação', 'As senhas informadas não conferem.');
      return;
    }

    carregando.value = true;
    try {
      final resposta = await _autenticacaoServico.cadastrarCoordenador(
        nome: nomeController.text,
        email: emailController.text,
        senha: senhaController.text,
        departamento: departamentoController.text,
        telefone: telefoneController.text,
        cpf: cpfController.text,
      );

      if (resposta.isOk) {
        final emailCadastrado = emailController.text.trim().toLowerCase();
        final senhaCadastrada = senhaController.text;
        _limparCampos();
        emailController.text = emailCadastrado;
        senhaController.text = senhaCadastrada;

        Get.snackbar(
          'Cadastro Realizado!',
          'Conta de Coordenador criada com sucesso. Suas credenciais foram preenchidas no formulário.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        Get.offNamed(RotasApp.LOGIN);
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirMensagemErro('Erro no Cadastro', erro);
      }
    } catch (e) {
      _exibirMensagemErro('Erro', 'Ocorreu um erro ao processar o cadastro.');
    } finally {
      carregando.value = false;
    }
  }

  Future<void> solicitarRecuperacaoSenha([String? emailAlvo]) async {
    final email = (emailAlvo != null && emailAlvo.trim().isNotEmpty)
        ? emailAlvo.trim()
        : emailController.text.trim();

    if (email.isEmpty) {
      _exibirMensagemErro('Validação', 'Por favor, informe seu e-mail cadastrado.');
      return;
    }
    if (!GetUtils.isEmail(email)) {
      _exibirMensagemErro('Validação', 'Por favor, informe um formato de e-mail válido.');
      return;
    }

    carregando.value = true;
    try {
      final resposta = await _autenticacaoServico.solicitarRecuperacaoSenha(email);

      if (resposta.isOk) {
        emailRecuperacao.value = email;
        Get.snackbar(
          'Código Enviado',
          'Código de confirmação gerado (verifique o console do servidor).',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        if (Get.currentRoute == RotasApp.ESQUECI_SENHA) {
          Get.toNamed(RotasApp.VALIDAR_CODIGO);
        }
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirMensagemErro('Erro', erro);
      }
    } catch (e) {
      _exibirMensagemErro('Erro', 'Falha ao solicitar código de recuperação.');
    } finally {
      carregando.value = false;
    }
  }

  Future<void> validarCodigoRecuperacao() async {
    if (!formularioValidarCodigoChave.currentState!.validate()) return;

    carregando.value = true;
    try {
      final codigo = codigoController.text.trim();
      final resposta = await _autenticacaoServico.validarCodigoRecuperacao(
        emailRecuperacao.value,
        codigo,
      );

      if (resposta.isOk) {
        codigoRecuperacao.value = codigo;
        Get.snackbar(
          'Código Validado',
          'Código confirmado com sucesso! Digite sua nova senha.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
        Get.toNamed(RotasApp.REDEFINIR_SENHA);
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirMensagemErro('Código Inválido', erro);
      }
    } catch (e) {
      _exibirMensagemErro('Erro', 'Falha ao validar código.');
    } finally {
      carregando.value = false;
    }
  }

  Future<void> redefinirSenha() async {
    if (!formularioRedefinirSenhaChave.currentState!.validate()) return;

    if (senhaController.text != confirmarSenhaController.text) {
      _exibirMensagemErro('Validação', 'As novas senhas não coincidem.');
      return;
    }

    final emailFinal = emailRecuperacao.value.isNotEmpty
        ? emailRecuperacao.value
        : emailController.text.trim();
    final codigoFinal = codigoRecuperacao.value.isNotEmpty
        ? codigoRecuperacao.value
        : codigoController.text.trim();

    if (emailFinal.isEmpty) {
      _exibirMensagemErro('Validação', 'Por favor, informe o e-mail cadastrado.');
      return;
    }

    if (codigoFinal.isEmpty) {
      _exibirMensagemErro('Validação', 'Por favor, informe o código de validação de 6 dígitos.');
      return;
    }

    carregando.value = true;
    try {
      final resposta = await _autenticacaoServico.redefinirSenha(
        email: emailFinal,
        codigo: codigoFinal,
        novaSenha: senhaController.text,
      );

      if (resposta.isOk) {
        _limparCampos();
        emailRecuperacao.value = '';
        codigoRecuperacao.value = '';

        Get.snackbar(
          'Senha Redefinida!',
          'Sua senha foi alterada com sucesso. Faça login com a nova senha.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        Get.offAllNamed(RotasApp.LOGIN);
      } else {
        final erro = _api.tratarErro(resposta);
        _exibirMensagemErro('Erro', erro);
      }
    } catch (e) {
      _exibirMensagemErro('Erro', 'Falha ao redefinir a senha.');
    } finally {
      carregando.value = false;
    }
  }

  Future<void> encerrarSessao() async {
    try {
      await _autenticacaoServico.encerrarSessao();
    } catch (_) {
    } finally {
      await _armazenamento.limparTudo();
      usuarioAtual.value = null;
      _limparCampos();
      Get.offAllNamed(RotasApp.LOGIN);
    }
  }

  void _redirecionarPorPapel(String papel) {
    if (papel.toLowerCase() == 'admin' || papel.toLowerCase() == 'coordenador') {
      Get.offAllNamed(RotasApp.ADMIN_PAINEL);
    } else {
      Get.offAllNamed(RotasApp.DOCENTE_MEUS_PATRIMONIOS);
    }
  }

  void _limparCampos() {
    emailController.clear();
    senhaController.clear();
    confirmarSenhaController.clear();
    nomeController.clear();
    departamentoController.clear();
    telefoneController.clear();
    cpfController.clear();
    codigoController.clear();
  }

  void _exibirMensagemErro(String titulo, String mensagem) {
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
