import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/autenticacao_controlador.dart';
import '../widgets/botao_personalizado.dart';
import '../widgets/texto_personalizado.dart';

/// Visão de Cadastro de Coordenador (RF02 / RN01) - Cadastro restrito de administradores gestores.
class CadastroCoordenadorView extends GetView<AutenticacaoControlador> {
  const CadastroCoordenadorView({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Cadastro de Coordenador'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blueGrey.shade900,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: controller.formularioCadastroChave,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banner informativo sobre o papel de coordenador
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings_outlined, color: Colors.blue.shade700, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Este formulário cria a conta do Gestor/Coordenador responsável pelo patrimônio da escola.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade900,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card com os campos de formulário
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
                          // Nome Completo
                          CampoTextoPersonalizado(
                            controlador: controller.nomeController,
                            rotulo: 'Nome Completo',
                            dica: 'Ex: Profa. Maria Oliveira',
                            iconePrefixo: Icons.person_outline_rounded,
                            validador: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe o nome completo';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // E-mail Institucional
                          CampoTextoPersonalizado(
                            controlador: controller.emailController,
                            rotulo: 'E-mail Institucional',
                            dica: 'coordenacao@escola.edu.br',
                            iconePrefixo: Icons.email_outlined,
                            tipoTeclado: TextInputType.emailAddress,
                            validador: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe o e-mail de contato';
                              }
                              if (!GetUtils.isEmail(v.trim())) {
                                return 'Informe um e-mail válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Departamento / Coordenação
                          CampoTextoPersonalizado(
                            controlador: controller.departamentoController,
                            rotulo: 'Departamento / Unidade',
                            dica: 'Ex: Coordenação Geral, Diretoria de Ensino',
                            iconePrefixo: Icons.apartment_outlined,
                            validador: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe o departamento ou setor';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Telefone
                          CampoTextoPersonalizado(
                            controlador: controller.telefoneController,
                            rotulo: 'Telefone / WhatsApp',
                            dica: '(11) 98765-4321',
                            iconePrefixo: Icons.phone_outlined,
                            tipoTeclado: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          // Senha
                          Obx(
                            () => CampoTextoPersonalizado(
                              controlador: controller.senhaController,
                              rotulo: 'Senha Provisória ou de Acesso',
                              dica: 'Crie uma senha segura (mín. 6 caracteres)',
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
                                  return 'Informe a senha';
                                }
                                if (v.length < 6) {
                                  return 'A senha deve conter no mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Confirmação de Senha
                          Obx(
                            () => CampoTextoPersonalizado(
                              controlador: controller.confirmarSenhaController,
                              rotulo: 'Confirmar Senha',
                              dica: 'Repita a senha digitada acima',
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
                                  return 'Confirme a senha';
                                }
                                if (v != controller.senhaController.text) {
                                  return 'As senhas não coincidem';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botão de Cadastrar
                          Obx(
                            () => BotaoPersonalizado(
                              texto: 'Finalizar Cadastro de Gestor',
                              icone: Icons.how_to_reg_rounded,
                              carregando: controller.carregando.value,
                              aoPressionar: controller.cadastrarCoordenador,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Voltar ao Login
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Já possuo cadastro, voltar ao login'),
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
