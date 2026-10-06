import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/autenticacao_controlador.dart';
import '../../routes/rotas_app.dart';
import '../widgets/botao_personalizado.dart';
import '../widgets/texto_personalizado.dart';

/// Visão de Login (RF01) - Autenticação com credenciais e redirecionamento condicional.
class LoginView extends GetView<AutenticacaoControlador> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: controller.formularioLoginChave,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ícone e Apresentação Institucional
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tema.colorScheme.primary,
                            const Color(0xFF1565C0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: tema.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Patrimônio Escolar',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sistema Integrado de Gestão e Acompanhamento',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Card de Login
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Acesse sua Conta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Informe suas credenciais institucionais para entrar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blueGrey.shade500,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Campo de E-mail
                          CampoTextoPersonalizado(
                            controlador: controller.emailController,
                            rotulo: 'E-mail Institucional',
                            dica: 'exemplo@escola.edu.br',
                            iconePrefixo: Icons.email_outlined,
                            tipoTeclado: TextInputType.emailAddress,
                            validador: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return 'Por favor, informe seu e-mail';
                              }
                              if (!GetUtils.isEmail(valor.trim())) {
                                return 'Informe um e-mail válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Campo de Senha
                          Obx(
                            () => CampoTextoPersonalizado(
                              controlador: controller.senhaController,
                              rotulo: 'Senha de Acesso',
                              dica: 'Digite sua senha',
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
                              validador: (valor) {
                                if (valor == null || valor.isEmpty) {
                                  return 'Por favor, informe sua senha';
                                }
                                if (valor.length < 4) {
                                  return 'A senha deve ter pelo menos 4 caracteres';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Link Esqueci minha senha
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Get.toNamed(RotasApp.ESQUECI_SENHA),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              ),
                              child: Text(
                                'Esqueceu a senha?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: tema.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Botão de Entrar
                          Obx(
                            () => BotaoPersonalizado(
                              texto: 'Entrar no Sistema',
                              icone: Icons.login_rounded,
                              carregando: controller.carregando.value,
                              aoPressionar: controller.login,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Rodapé de Cadastro de Coordenador (RN01)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'É um novo gestor escolar?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey.shade600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(RotasApp.CADASTRO),
                          child: Text(
                            'Cadastrar Coordenador',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: tema.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
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
