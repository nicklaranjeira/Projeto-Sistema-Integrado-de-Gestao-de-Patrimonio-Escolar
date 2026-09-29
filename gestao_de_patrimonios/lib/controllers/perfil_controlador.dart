import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/usuario_modelo.dart';
import '../services/api_servico.dart';
import '../services/armazenamento_servico.dart';
import '../services/perfil_servico.dart';
import 'autenticacao_controlador.dart';

class PerfilControlador extends GetxController {
  final PerfilServico _perfilServico = Get.find<PerfilServico>();
  final ArmazenamentoServico _armazenamento = Get.find<ArmazenamentoServico>();
  final ApiServico _api = Get.find<ApiServico>();

  final RxBool carregando = false.obs;
  final RxBool atualizando = false.obs;
  final Rx<UsuarioModelo?> perfilUsuario = Rx<UsuarioModelo?>(null);
  final RxBool senhaAtualVisivel = false.obs;
  final RxBool novaSenhaVisivel = false.obs;
  final RxBool confirmarSenhaVisivel = false.obs;

  final telefoneController = TextEditingController();
  final departamentoController = TextEditingController();
  final senhaAtualController = TextEditingController();
  final novaSenhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  final formularioPerfilChave = GlobalKey<FormState>();
  final formularioSenhaChave = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    perfilUsuario.value = _armazenamento.obterUsuario();
    _preencherCampos();
    carregarPerfil();
  }

  @override
  void onClose() {
    telefoneController.dispose();
    departamentoController.dispose();
    senhaAtualController.dispose();
    novaSenhaController.dispose();
    confirmarSenhaController.dispose();
    super.onClose();
  }

  void alternarVisibilidadeSenhaAtual() => senhaAtualVisivel.toggle();
  void alternarVisibilidadeNovaSenha() => novaSenhaVisivel.toggle();
  void alternarVisibilidadeConfirmarSenha() => confirmarSenhaVisivel.toggle();

  void _preencherCampos() {
    if (perfilUsuario.value != null) {
      telefoneController.text = perfilUsuario.value!.telefone ?? '';
      departamentoController.text = perfilUsuario.value!.departamento ?? '';
    }
  }

  Future<void> carregarPerfil() async {
    carregando.value = true;
    try {
      final resposta = await _perfilServico.obterPerfil();

      if (resposta.isOk && resposta.body != null) {
        final Map<String, dynamic> dados =
            resposta.body is Map ? Map<String, dynamic>.from(resposta.body) : {};

        final usuarioAtualizado = UsuarioModelo.fromJson(dados);
        perfilUsuario.value = usuarioAtualizado;
        await _armazenamento.salvarUsuario(usuarioAtualizado);
        _preencherCampos();
      }
    } catch (e) {
    } finally {
      carregando.value = false;
    }
  }

  Future<void> atualizarDadosCadastrais() async {
    if (!formularioPerfilChave.currentState!.validate()) return;

    atualizando.value = true;
    try {
      final resposta = await _perfilServico.atualizarPerfil(
        telefone: telefoneController.text.trim(),
        departamento: departamentoController.text.trim(),
      );

      if (resposta.isOk) {
        await carregarPerfil();
        Get.snackbar(
          'Perfil Atualizado',
          'Seus dados de contato foram salvos com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erro ao Atualizar',
          _api.tratarErro(resposta),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao comunicar com o servidor.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      atualizando.value = false;
    }
  }

  Future<void> alterarSenha() async {
    if (!formularioSenhaChave.currentState!.validate()) return;

    if (novaSenhaController.text != confirmarSenhaController.text) {
      Get.snackbar('Validação', 'A confirmação da nova senha não confere.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
      return;
    }

    atualizando.value = true;
    try {
      final resposta = await _perfilServico.atualizarPerfil(
        senhaAtual: senhaAtualController.text,
        novaSenha: novaSenhaController.text,
      );

      if (resposta.isOk) {
        senhaAtualController.clear();
        novaSenhaController.clear();
        confirmarSenhaController.clear();

        Get.snackbar(
          'Senha Alterada',
          'Sua senha foi alterada com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erro na Alteração',
          _api.tratarErro(resposta),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao trocar a senha.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      atualizando.value = false;
    }
  }

  void encerrarSessao() {
    Get.find<AutenticacaoControlador>().encerrarSessao();
  }
}
