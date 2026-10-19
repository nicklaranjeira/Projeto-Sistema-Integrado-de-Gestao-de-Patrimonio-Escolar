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
  final RxBool senhaVisivel = false.obs;
  final Rx<UsuarioModelo?> usuario = Rx<UsuarioModelo?>(null);

  final formularioChave = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final departamentoController = TextEditingController();
  final telefoneController = TextEditingController();
  final cpfController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    carregarPerfil();
  }

  @override
  void onClose() {
    nomeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    departamentoController.dispose();
    telefoneController.dispose();
    cpfController.dispose();
    super.onClose();
  }

  void alternarVisibilidadeSenha() => senhaVisivel.toggle();

  void _preencherCampos(UsuarioModelo user) {
    usuario.value = user;
    final ehAdmin = user.ehAdministrador;

    nomeController.text = user.nome.isNotEmpty ? user.nome : (ehAdmin ? 'Prof. Carlos Drummond (Coordenador)' : 'Prof. Carlos Drummond');
    emailController.text = user.email.isNotEmpty ? user.email : (ehAdmin ? 'coordenador@escola.gov.br' : 'carlos.drummond@escola.gov.br');
    passwordController.text = user.password ?? (ehAdmin ? 'admin01' : 'prof02');
    departamentoController.text = user.departamento ?? (ehAdmin ? 'Coordenação Geral Pedagógica' : 'Língua Portuguesa e Literatura');
    telefoneController.text = user.telefone ?? (ehAdmin ? '(11) 98765-4321' : '(11) 91234-5678');
    cpfController.text = user.cpf ?? (ehAdmin ? '123.456.789-01' : '987.654.321-02');
  }

  Future<void> carregarPerfil() async {
    carregando.value = true;
    try {
      final resposta = await _perfilServico.obterPerfil();

      if (resposta.isOk && resposta.body != null) {
        final dados = Map<String, dynamic>.from(resposta.body is Map ? resposta.body : {});
        final usuarioAtualizado = UsuarioModelo.fromJson(dados);

        _preencherCampos(usuarioAtualizado);
        await _armazenamento.salvarUsuario(usuarioAtualizado);
      } else {
        final usuarioSalvo = _armazenamento.obterUsuario();
        if (usuarioSalvo != null) {
          _preencherCampos(usuarioSalvo);
        }
      }
    } catch (_) {
      final usuarioSalvo = _armazenamento.obterUsuario();
      if (usuarioSalvo != null) {
        _preencherCampos(usuarioSalvo);
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
        'cpf': cpfController.text.trim().isEmpty ? null : cpfController.text.trim(),
        'password': passwordController.text.trim(),
      };

      final resposta = await _perfilServico.atualizarPerfil(dados);

      if (resposta.isOk && resposta.body != null) {
        final dadosAtualizados = Map<String, dynamic>.from(resposta.body is Map ? resposta.body : {});
        final usuarioAtualizado = UsuarioModelo.fromJson(dadosAtualizados).copyWith(
          cpf: cpfController.text.trim(),
          password: passwordController.text.trim(),
        );

        _preencherCampos(usuarioAtualizado);
        await _armazenamento.salvarUsuario(usuarioAtualizado);

        Get.snackbar(
          'Perfil Atualizado',
          'Seus dados foram atualizados com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      } else {
        // Atualização em modo offline/demonstração
        if (usuario.value != null) {
          final atualizado = usuario.value!.copyWith(
            nome: nomeController.text.trim(),
            telefone: telefoneController.text.trim(),
            departamento: departamentoController.text.trim(),
            cpf: cpfController.text.trim(),
            password: passwordController.text.trim(),
          );
          _preencherCampos(atualizado);
          await _armazenamento.salvarUsuario(atualizado);

          Get.snackbar(
            'Perfil Atualizado',
            'Dados salvos com sucesso.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
          );
          return;
        }

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
      if (usuario.value != null) {
        final atualizado = usuario.value!.copyWith(
          nome: nomeController.text.trim(),
          telefone: telefoneController.text.trim(),
          departamento: departamentoController.text.trim(),
          cpf: cpfController.text.trim(),
          password: passwordController.text.trim(),
        );
        _preencherCampos(atualizado);
        await _armazenamento.salvarUsuario(atualizado);

        Get.snackbar(
          'Perfil Atualizado',
          'Dados salvos localmente com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
        return;
      }

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
