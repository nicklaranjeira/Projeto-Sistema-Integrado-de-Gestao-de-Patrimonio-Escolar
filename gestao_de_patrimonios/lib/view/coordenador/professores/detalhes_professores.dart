import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/professor_controlador.dart';
import '../../../routes/rotas_app.dart';
import '../../widgets/card_patrimonio.dart';
import '../../widgets/cracha_status.dart';

/// Visão de Detalhes do Professor (RF06 / RN04) - Dados funcionais e relação de bens sob sua tutela.
class DetalhesProfessorView extends GetView<ProfessorControlador> {
  const DetalhesProfessorView({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    // Carrega dados se veio argumento
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = Get.arguments as int?;
      if (id != null &&
          (controller.professorSelecionado.value == null ||
              controller.professorSelecionado.value!.id != id)) {
        controller.carregarDetalhesProfessor(id);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Ficha do Docente'),
        actions: [
          Obx(() {
            final prof = controller.professorSelecionado.value;
            if (prof == null) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (opcao) {
                if (opcao == 'editar') {
                  controller.prepararEdicao(prof);
                  Get.toNamed(RotasApp.ADMIN_NOVO_PROFESSOR);
                } else if (opcao == 'status') {
                  final novoStatus = prof.estaAtivo ? 'inativo' : 'ativo';
                  controller.alterarStatusProfessor(prof.id, novoStatus);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20, color: Colors.blueGrey),
                      SizedBox(width: 10),
                      Text('Editar Dados'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'status',
                  child: Row(
                    children: [
                      Icon(
                        prof.estaAtivo ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                        size: 20,
                        color: prof.estaAtivo ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Text(prof.estaAtivo ? 'Desativar Docente' : 'Reativar Docente'),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.carregandoDetalhes.value && controller.professorSelecionado.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final prof = controller.professorSelecionado.value;
        if (prof == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Professor não encontrado.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Voltar à lista'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card de Apresentação do Professor
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
                        prof.nome.isNotEmpty ? prof.nome.substring(0, 1).toUpperCase() : 'P',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: tema.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      prof.nome,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prof.departamento ?? 'Docente',
                      style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
                    ),
                    const SizedBox(height: 10),
                    CrachaStatus(status: prof.status),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dados Institucionais e Contato
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dados de Acesso e Contato',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263238),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ItemInfoLinha(
                      icone: Icons.email_outlined,
                      rotulo: 'E-mail',
                      valor: prof.email,
                    ),
                    _ItemInfoLinha(
                      icone: Icons.badge_outlined,
                      rotulo: 'Matrícula',
                      valor: prof.matricula ?? 'Não informada',
                    ),
                    _ItemInfoLinha(
                      icone: Icons.phone_outlined,
                      rotulo: 'Telefone',
                      valor: prof.telefone ?? 'Não informado',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Relação de Bens Sob a Guarda do Docente (RN04)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bens Sob Sua Guarda (${controller.patrimoniosDoProfessor.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (controller.patrimoniosDoProfessor.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 36, color: Colors.blueGrey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          'Nenhum patrimônio sob a guarda deste professor no momento.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.patrimoniosDoProfessor.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final bem = controller.patrimoniosDoProfessor[index];
                    return CardPatrimonio(
                      patrimonio: bem,
                      aoTocar: () {
                        Get.toNamed(
                          RotasApp.ADMIN_DETALHES_PATRIMONIO,
                          arguments: bem.id,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _ItemInfoLinha extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const _ItemInfoLinha({
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icone, size: 18, color: Colors.blueGrey.shade500),
          const SizedBox(width: 10),
          Text(
            '$rotulo: ',
            style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A202C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
