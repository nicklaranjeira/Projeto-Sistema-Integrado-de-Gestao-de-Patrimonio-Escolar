import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/usuario_modelo.dart';
import '../service/api_servico.dart';
import '../service/armazenamento_servico.dart';
import '../service/perfil_servico.dart';

class PerfilControlador extends GetxController {
  final PerfilServico _perfilServico = Get.find<PerfilServico>();
  final ArmazenamentoServico _armazenamento = Get.find<ArmazenamentoServico>();
  final ApiServico _api = Get.find<ApiServico>();

  final RxBool carregando = false.obs;
  final RxBool salvando = false.obs;
  final Rx<UsuarioModelo?> usuario = Rx<UsuarioModelo?>(null);

  final formularioChave = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final departamentoController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    carregarPerfil();
  }

  @override
  void onClose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    departamentoController.dispose();
    super.onClose();
  }

  Future<void> carregarPerfil() async {
    carregando.value = true;
    try {
      final resposta = await _perfilServico.obterPerfil();

      if (resposta.isOk && resposta.body != null) {
        final dados = Map<String, dynamic>.from(resposta.body is Map ? resposta.body : {});
        final usuarioAtualizado = UsuarioModelo.fromJson(dados);

        usuario.value = usuarioAtualizado;
        await _armazenamento.salvarUsuario(usuarioAtualizado);

        nomeController.text = usuarioAtualizado.nome;
        emailController.text = usuarioAtualizado.email;
        telefoneController.text = usuarioAtualizado.telefone ?? '';
        departamentoController.text = usuarioAtualizado.departamento ?? '';
      } else {
        final usuarioSalvo = _armazenamento.obterUsuario();
        if (usuarioSalvo != null) {
          usuario.value = usuarioSalvo;
          nomeController.text = usuarioSalvo.nome;
          emailController.text = usuarioSalvo.email;
          telefoneController.text = usuarioSalvo.telefone ?? '';
          departamentoController.text = usuarioSalvo.departamento ?? '';
        }
      }
    } catch (_) {
      final usuarioSalvo = _armazenamento.obterUsuario();
      if (usuarioSalvo != null) {
        usuario.value = usuarioSalvo;
        nomeController.text = usuarioSalvo.nome;
        emailController.text = usuarioSalvo.email;
        telefoneController.text = usuarioSalvo.telefone ?? '';
        departamentoController.text = usuarioSalvo.departamento ?? '';
      }
    } finally {
      carregando.value = false;
    }
  }

  Future<void> atualizarPerfil() async {
    if (!formularioChave.currentState!.validate()) return;

    salvando.value = true;
    try {
      final dados = {
        'nome': nomeController.text.trim(),
        'telefone': telefoneController.text.trim().isEmpty ? null : telefoneController.text.trim(),
        'departamento': departamentoController.text.trim().isEmpty ? null : departamentoController.text.trim(),
      };

      final resposta = await _perfilServico.atualizarPerfil(dados);

      if (resposta.isOk && resposta.body != null) {
        final dadosAtualizados = Map<String, dynamic>.from(resposta.body is Map ? resposta.body : {});
        final usuarioAtualizado = UsuarioModelo.fromJson(dadosAtualizados);

        usuario.value = usuarioAtualizado;
        await _armazenamento.salvarUsuario(usuarioAtualizado);

        Get.snackbar(
          'Perfil Atualizado',
          'Seus dados foram atualizados com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      } else {
        final erro = _api.tratarErro(resposta);
        Get.snackbar(
          'Erro ao Atualizar',
          erro,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar o perfil.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      salvando.value = false;
    }
  }
}
