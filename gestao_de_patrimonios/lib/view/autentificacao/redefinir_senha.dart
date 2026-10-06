import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/autenticacao_controlador.dart';
import '../widgets/botao_personalizado.dart';
import '../widgets/texto_personalizado.dart';

/// Visão de Redefinição de Senha - Etapa 3 (RF03): Definição de nova senha com confirmação idêntica.
class RedefinirSenhaView extends GetView<AutenticacaoControlador> {
  const RedefinirSenhaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Redefinir Senha'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blueGrey.shade900,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: controller.formularioRedefinirSenhaChave,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ícone ilustrativo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        color: Colors.green.shade700,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Criar Nova Senha',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Código validado com sucesso! Agora cadastre sua nova senha de acesso.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Card da nova senha
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Nova Senha
                          Obx(
                            () => CampoTextoPersonalizado(
                              controlador: controller.senhaController,
                              rotulo: 'Nova Senha',
                              dica: 'Digite a nova senha (mín. 6 caracteres)',
                              iconePrefixo: Icons.lock_outline_rounded,
                              ocultarTexto: !controller.senhaVisivel.value,
                              sufixo: IconButton(
                                icon: Icon(
                                  controller.senhaVisivel.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: controller.alternarVisibilidadeSenha,
                              ),
                              validador: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Informe a nova senha';
                                }
                                if (v.length < 6) {
                                  return 'A senha deve conter no mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Confirmação da Nova Senha
                          Obx(
                            () => CampoTextoPersonalizado(
                              controlador: controller.confirmarSenhaController,
                              rotulo: 'Confirmar Nova Senha',
                              dica: 'Digite a mesma senha novamente',
                              iconePrefixo: Icons.lock_clock_outlined,
                              ocultarTexto: !controller.confirmarSenhaVisivel.value,
                              sufixo: IconButton(
                                icon: Icon(
                                  controller.confirmarSenhaVisivel.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: controller.alternarVisibilidadeConfirmarSenha,
                              ),
                              validador: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Confirme a nova senha';
                                }
                                if (v != controller.senhaController.text) {
                                  return 'As senhas digitadas não conferem';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botão Salvar
                          Obx(
                            () => BotaoPersonalizado(
                              texto: 'Salvar e Acessar Conta',
                              icone: Icons.check_circle_rounded,
                              carregando: controller.carregando.value,
                              aoPressionar: controller.redefinirSenha,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
