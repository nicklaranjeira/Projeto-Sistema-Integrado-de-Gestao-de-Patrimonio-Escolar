import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/professor_controlador.dart';
import '../../widgets/botao_personalizado.dart';
import '../../widgets/campo_texto_personalizado.dart';

/// Visão de Formulário de Professor (RF06 / RN02) - Cadastro e Edição centralizada de docentes pelo Coordenador.
class FormularioProfessorView extends GetView<ProfessorControlador> {
  const FormularioProfessorView({super.key});

  @override
  Widget build(BuildContext context) {
    final ehEdicao = controller.professorSelecionado.value != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(ehEdicao ? 'Editar Professor' : 'Novo Professor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: controller.formularioChave,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner informativo sobre a RN02
                if (!ehEdicao) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.badge_outlined, color: Colors.blue.shade700, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Novos professores são cadastrados exclusivamente pela coordenação. Os dados cadastrais fornecidos permitirão o acesso institucional do docente.',
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
                  const SizedBox(height: 20),
                ],

                // Card com campos
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_pin_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Dados Pessoais e Funcionais',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Nome
                      CampoTextoPersonalizado(
                        controlador: controller.nomeController,
                        rotulo: 'Nome Completo do Professor *',
                        dica: 'Ex: Prof. Carlos Eduardo Mendes',
                        iconePrefixo: Icons.person_outline_rounded,
                        validador: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe o nome do professor';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // E-mail Institucional
                      CampoTextoPersonalizado(
                        controlador: controller.emailController,
                        rotulo: 'E-mail Institucional *',
                        dica: 'carlos.mendes@escola.edu.br',
                        iconePrefixo: Icons.email_outlined,
                        tipoTeclado: TextInputType.emailAddress,
                        somenteLeitura: ehEdicao, // E-mail institucional fixo na edição
                        validador: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe o e-mail institucional';
                          }
                          if (!GetUtils.isEmail(v.trim())) {
                            return 'Informe um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Matrícula
                      CampoTextoPersonalizado(
                        controlador: controller.matriculaController,
                        rotulo: 'Matrícula Institucional *',
                        dica: 'Ex: MAT-2026-44',
                        iconePrefixo: Icons.badge_outlined,
                        validador: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe o código de matrícula';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Departamento / Área
                      CampoTextoPersonalizado(
                        controlador: controller.departamentoController,
                        rotulo: 'Departamento / Disciplina *',
                        dica: 'Ex: Robótica e Ciências da Computação',
                        iconePrefixo: Icons.school_outlined,
                        validador: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe a área ou departamento';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Telefone
                      CampoTextoPersonalizado(
                        controlador: controller.telefoneController,
                        rotulo: 'Telefone de Contato / WhatsApp',
                        dica: '(11) 98888-7777',
                        iconePrefixo: Icons.phone_outlined,
                        tipoTeclado: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botão de Salvar
                Obx(
                  () => BotaoPersonalizado(
                    texto: ehEdicao ? 'Salvar Alterações' : 'Cadastrar Professor',
                    icone: Icons.check_circle_outline_rounded,
                    carregando: controller.salvando.value,
                    aoPressionar: controller.salvarProfessor,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Cancelar e Voltar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
