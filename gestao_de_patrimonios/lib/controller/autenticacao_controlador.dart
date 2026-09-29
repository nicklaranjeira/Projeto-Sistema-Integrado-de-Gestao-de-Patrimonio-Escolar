import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/usuario_modelo.dart';
import '../service/api_servico.dart';
import '../service/armazenamento_servico.dart';
import '../service/autenticacao_servico.dart';
import '../routes/rotas_app.dart';

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
    codigoController.dispose();
    super.onClose();
  }

  void alternarVisibilidadeSenha() => senhaVisivel.toggle();
  void alternarVisibilidadeConfirmarSenha() => confirmarSenhaVisivel.toggle();

  Future<void> verificarStatusAutenticacao() async {
    final token = _armazenamento.obterToken();
    final usuario = _armazenamento.obterUsuario();

    if (token != null && token.isNotEmpty && usuario != null) {
      usuarioAtual.value = usuario;
      _redirecionarPorPapel(usuario.papel);
    } else {
      Get.offAllNamed(RotasApp.LOGIN);
    }
  }

  Future<void> login() async {
    if (!formularioLoginChave.currentState!.validate()) return;

    carregando.value = true;
    try {
      final resposta = await _autenticacaoServico.login(
        emailController.text,
        senhaController.text,
      );

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

        final usuario = UsuarioModelo.fromJson(mapaUsuario).copyWith(
          token: token,
          refreshToken: refreshToken,
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
        _exibirMensagemErro('Falha no Login', erro);
      }
    } catch (e) {
      _exibirMensagemErro('Erro de Conexão', 'Não foi possível conectar ao servidor.');
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
      );

      if (resposta.isOk) {
        _limparCampos();
        Get.snackbar(
          'Cadastro Realizado!',
          'Conta de Coordenador criada com sucesso. Faça login para continuar.',
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

  Future<void> solicitarRecuperacaoSenha() async {
    if (!formularioEsqueciSenhaChave.currentState!.validate()) return;

    carregando.value = true;
    try {
      final email = emailController.text.trim();
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
        Get.toNamed(RotasApp.VALIDAR_CODIGO);
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

    carregando.value = true;
    try {
      final resposta = await _autenticacaoServico.redefinirSenha(
        email: emailRecuperacao.value,
        codigo: codigoRecuperacao.value,
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
    if (papel.toLowerCase() == 'admin') {
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
