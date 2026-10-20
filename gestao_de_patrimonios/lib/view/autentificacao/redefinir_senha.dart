import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/autenticacao_controlador.dart';
import '../../routes/rotas_app.dart';
import '../widgets/botao_personalizado.dart';
import '../widgets/texto_personalizado.dart';

/// Visão de Redefinição de Senha (RF03): Definição de nova senha com validação de código e e-mail.
class RedefinirSenhaView extends GetView<AutenticacaoControlador> {
  const RedefinirSenhaView({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    // Pré-preenche e-mail e código se vieram de etapas anteriores
    if (controller.emailRecuperacao.value.isNotEmpty &&
        controller.emailController.text.isEmpty) {
      controller.emailController.text = controller.emailRecuperacao.value;
    }
    if (controller.codigoRecuperacao.value.isNotEmpty &&
        controller.codigoController.text.isEmpty) {
      controller.codigoController.text = controller.codigoRecuperacao.value;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Redefinição de Senha'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blueGrey.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.offAllNamed(RotasApp.LOGIN),
        ),
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
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Redefinir Senha',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Informe seu e-mail cadastrado, o código de 6 dígitos e sua nova senha de acesso.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Card do Formulário
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
                          // E-mail Cadastrado com ação de Enviar Código
                          CampoTextoPersonalizado(
                            controlador: controller.emailController,
                            rotulo: 'E-mail Cadastrado *',
                            dica: 'seu.email@escola.edu.br',
                            iconePrefixo: Icons.email_outlined,
                            tipoTeclado: TextInputType.emailAddress,
                            validador: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe o e-mail cadastrado';
                              }
                              if (!GetUtils.isEmail(v.trim())) {
                                return 'Informe um e-mail com formato válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 4),

                          // Botão de solicitar/enviar código
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                controller.solicitarRecuperacaoSenha(
                                  controller.emailController.text.trim(),
                                );
                              },
                              icon: const Icon(Icons.send_rounded, size: 14),
                              label: const Text(
                                'Enviar / Reenviar código',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Código de 6 dígitos
                          CampoTextoPersonalizado(
                            controlador: controller.codigoController,
                            rotulo: 'Código de Validação (6 dígitos) *',
                            dica: 'Ex: 123456',
                            iconePrefixo: Icons.pin_outlined,
                            tipoTeclado: TextInputType.number,
                            validador: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe o código de 6 dígitos recebido';
                              }
                              if (v.trim().length != 6) {
                                return 'O código deve conter exatamente 6 dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Nova Senha
                          Obx(
                            () => CampoTextoPersonalizado(
                              controlador: controller.senhaController,
                              rotulo: 'Nova Senha *',
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
                              rotulo: 'Confirmar Nova Senha *',
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
                              texto: 'Redefinir Senha e Acessar Conta',
                              icone: Icons.check_circle_rounded,
                              carregando: controller.carregando.value,
                              aoPressionar: controller.redefinirSenha,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Voltar ao Login
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Get.offAllNamed(RotasApp.LOGIN),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Lembrei minha senha, voltar ao login'),
                        style: TextButton.styleFrom(
                          foregroundColor: tema.colorScheme.primary,
                        ),
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
