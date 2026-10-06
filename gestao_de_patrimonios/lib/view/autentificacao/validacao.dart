import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/autenticacao_controlador.dart';
import '../widgets/botao_personalizado.dart';
import '../widgets/campo_texto_personalizado.dart';

/// Visão de Validação de Código - Etapa 2 (RF03): Inserção do código numérico de 6 dígitos.
class ValidacaoView extends GetView<AutenticacaoControlador> {
  const ValidacaoView({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Validação de Código'),
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
                key: controller.formularioValidarCodigoChave,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ícone ilustrativo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Icon(
                        Icons.pin_outlined,
                        color: tema.colorScheme.primary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Código de Confirmação',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        controller.emailRecuperacao.value.isNotEmpty
                            ? 'Insira o código enviado para:\n${controller.emailRecuperacao.value}'
                            : 'Insira o código numérico de 6 dígitos gerado.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Card do código
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
                            controlador: controller.codigoController,
                            rotulo: 'Código de 6 dígitos',
                            dica: 'Ex: 123456',
                            iconePrefixo: Icons.dialpad_rounded,
                            tipoTeclado: TextInputType.number,
                            validador: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe o código recebido';
                              }
                              if (v.trim().length != 6) {
                                return 'O código deve conter exatamente 6 dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Obx(
                            () => BotaoPersonalizado(
                              texto: 'Validar Código',
                              icone: Icons.check_circle_outline_rounded,
                              carregando: controller.carregando.value,
                              aoPressionar: controller.validarCodigoRecuperacao,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dica de ambiente
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Em modo de desenvolvimento, o código gerado é impresso no terminal onde o backend api.exe está rodando.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Voltar
                    Center(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Voltar à etapa anterior'),
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
