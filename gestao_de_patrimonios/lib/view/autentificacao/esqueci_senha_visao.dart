import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/autenticacao_controlador.dart';
import '../widgets/botao_personalizado.dart';
import '../widgets/campo_texto_personalizado.dart';

/// Visão de Recuperação de Senha - Etapa 1 (RF03): Solicitação de código por e-mail.
class EsqueciSenhaVisao extends GetView<AutenticacaoControlador> {
  const EsqueciSenhaVisao({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Recuperação de Senha'),
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
                key: controller.formularioEsqueciSenhaChave,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ícone ilustrativo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        color: Colors.amber.shade800,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Esqueceu sua senha?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Informe seu e-mail institucional para enviarmos um código de validação de 6 dígitos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Card de solicitação
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
                          CampoTextoPersonalizado(
                            controlador: controller.emailController,
                            rotulo: 'E-mail Cadastrado',
                            dica: 'seu.email@escola.edu.br',
                            iconePrefixo: Icons.email_outlined,
                            tipoTeclado: TextInputType.emailAddress,
                            validador: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Por favor, informe seu e-mail';
                              }
                              if (!GetUtils.isEmail(v.trim())) {
                                return 'Informe um e-mail com formato válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Obx(
                            () => BotaoPersonalizado(
                              texto: 'Enviar Código de Validação',
                              icone: Icons.send_rounded,
                              carregando: controller.carregando.value,
                              aoPressionar: controller.solicitarRecuperacaoSenha,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Voltar
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Get.back(),
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
