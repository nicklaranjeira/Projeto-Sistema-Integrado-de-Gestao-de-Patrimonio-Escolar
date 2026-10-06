import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/autenticacao_controlador.dart';
import '../../controller/perfil_controlador.dart';
import '..view/patrimonios.dart';

/// Visão de Perfil do Usuário (RF09 / RN06 / RF04) - Dados cadastrais, atualização de contato e logout seguro.
class PerfilView extends GetView<PerfilControlador> {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            tooltip: 'Sair da Conta',
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            onPressed: () => _confirmarLogout(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.carregando.value && controller.usuario.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.usuario.value;
        final nome = user?.nome ?? 'Usuário';
        final papel = user?.papel ?? 'docente';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho de Perfil com Avatar e Papel
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: tema.colorScheme.primary.withOpacity(0.12),
                      child: Text(
                        nome.isNotEmpty ? nome.substring(0, 1).toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: tema.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nome,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600),
                    ),
                    const SizedBox(height: 10),
                    CrachaStatus(
                      status: papel.toLowerCase() == 'admin' ? 'Coordenador (Admin)' : 'Professor (Docente)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Formulário de Atualização Cadastral (RF09 / RN06)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Form(
                  key: controller.formularioChave,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_note_rounded, color: tema.colorScheme.primary, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'Atualizar Informações Cadastrais',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF263238),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Nome
                      CampoTextoPersonalizado(
                        controlador: controller.nomeController,
                        rotulo: 'Nome Completo *',
                        iconePrefixo: Icons.person_outline_rounded,
                        validador: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe seu nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // E-mail (somente leitura)
                      CampoTextoPersonalizado(
                        controlador: controller.emailController,
                        rotulo: 'E-mail Institucional (Identificador)',
                        iconePrefixo: Icons.email_outlined,
                        somenteLeitura: true,
                        dica: 'O e-mail é gerido institucionalmente',
                      ),
                      const SizedBox(height: 16),

                      // Telefone
                      CampoTextoPersonalizado(
                        controlador: controller.telefoneController,
                        rotulo: 'Telefone de Contato / WhatsApp',
                        dica: '(11) 98765-4321',
                        iconePrefixo: Icons.phone_outlined,
                        tipoTeclado: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Departamento
                      CampoTextoPersonalizado(
                        controlador: controller.departamentoController,
                        rotulo: 'Departamento / Área de Ensino',
                        dica: 'Ex: Ciências Exatas e Tecnologia',
                        iconePrefixo: Icons.apartment_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Botão Salvar
                      Obx(
                        () => BotaoPersonalizado(
                          texto: 'Salvar Alterações',
                          icone: Icons.save_outlined,
                          carregando: controller.salvando.value,
                          aoPressionar: controller.atualizarPerfil,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Botão de Logout Seguro (RF04)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _confirmarLogout(context),
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                      label: const Text('Encerrar Sessão (Sair)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _confirmarLogout(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Sair do Aplicativo'),
          ],
        ),
        content: const Text(
          'Deseja realmente encerrar sua sessão? Você precisará informar seu e-mail e senha para acessar novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              // Executa o logout limpo através do AutenticacaoControlador (RF04)
              if (Get.isRegistered<AutenticacaoControlador>()) {
                Get.find<AutenticacaoControlador>().encerrarSessao();
              } else {
                Get.put(AutenticacaoControlador()).encerrarSessao();
              }
            },
            child: const Text('Sim, Sair'),
          ),
        ],
      ),
    );
  }
}
