import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/professor_controlador.dart';
import '../../../routes/rotas_app.dart';
import '../../widgets/cracha_status.dart';
import '../../widgets/estado_vazio.dart';

/// Visão de Gestão de Professores (RF06) - Listagem de docentes com indicador de bens sob responsabilidade.
class GestaoProfessoresView extends GetView<ProfessorControlador> {
  const GestaoProfessoresView({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Corpo Docente'),
        actions: [
          IconButton(
            tooltip: 'Atualizar Lista',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.listarProfessores,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.prepararCadastro();
          Get.toNamed(RotasApp.ADMIN_NOVO_PROFESSOR);
        },
        backgroundColor: tema.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Novo Professor'),
      ),
      body: Column(
        children: [
          // Barra de Busca
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                TextField(
                  onChanged: controller.buscar,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, matrícula, departamento...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: tema.colorScheme.primary),
                    suffixIcon: Obx(() {
                      if (controller.buscaTexto.value.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () => controller.buscar(''),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Filtros de status (Todos, Ativo, Inativo)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() {
                    final statusAtual = controller.filtroStatus.value;
                    return Row(
                      children: [
                        FilterChip(
                          label: const Text('Todos'),
                          selected: statusAtual.isEmpty,
                          onSelected: (_) => controller.definirFiltroStatus(''),
                          selectedColor: tema.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: statusAtual.isEmpty ? Colors.white : Colors.blueGrey.shade800,
                            fontWeight: statusAtual.isEmpty ? FontWeight.bold : FontWeight.w500,
                          ),
                          showCheckmark: false,
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Ativos'),
                          selected: statusAtual == 'ativo',
                          onSelected: (_) => controller.definirFiltroStatus('ativo'),
                          selectedColor: tema.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: statusAtual == 'ativo' ? Colors.white : Colors.blueGrey.shade800,
                            fontWeight: statusAtual == 'ativo' ? FontWeight.bold : FontWeight.w500,
                          ),
                          showCheckmark: false,
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Inativos'),
                          selected: statusAtual == 'inativo',
                          onSelected: (_) => controller.definirFiltroStatus('inativo'),
                          selectedColor: tema.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: statusAtual == 'inativo' ? Colors.white : Colors.blueGrey.shade800,
                            fontWeight: statusAtual == 'inativo' ? FontWeight.bold : FontWeight.w500,
                          ),
                          showCheckmark: false,
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Lista de Professores
          Expanded(
            child: Obx(() {
              if (controller.carregando.value && controller.listaProfessores.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.listaFiltrada.isEmpty) {
                return EstadoVazio(
                  icone: Icons.school_outlined,
                  titulo: 'Nenhum professor encontrado',
                  mensagem: controller.buscaTexto.value.isNotEmpty
                      ? 'Nenhum docente corresponde ao termo de busca.'
                      : 'Nenhum professor cadastrado ainda no sistema escolar.',
                  textoAcao: controller.buscaTexto.value.isNotEmpty ? 'Limpar Busca' : 'Atualizar',
                  aoPressionarAcao: controller.buscaTexto.value.isNotEmpty
                      ? controller.limparFiltros
                      : controller.listarProfessores,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.listarProfessores,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: controller.listaFiltrada.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final professor = controller.listaFiltrada[index];

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 1,
                      shadowColor: Colors.black12,
                      child: InkWell(
                        onTap: () {
                          controller.carregarDetalhesProfessor(professor.id);
                          Get.toNamed(
                            RotasApp.ADMIN_DETALHES_PROFESSOR,
                            arguments: professor.id,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              // Avatar do Professor
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: tema.colorScheme.primary.withOpacity(0.12),
                                child: Text(
                                  professor.nome.isNotEmpty
                                      ? professor.nome.trim().substring(0, 1).toUpperCase()
                                      : 'P',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: tema.colorScheme.primary,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Dados do Professor
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            professor.nome,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1A202C),
                                            ),
                                          ),
                                        ),
                                        CrachaStatus(
                                          status: professor.status,
                                          formatoPequeno: true,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${professor.matricula ?? 'S/ Matrícula'} • ${professor.departamento ?? 'Geral'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blueGrey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Indicador da quantidade de bens sob responsabilidade (RF06)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.inventory_2_outlined,
                                            size: 14,
                                            color: Colors.blue.shade800,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${professor.totalPatrimoniosAlocados} patrimônio(s) sob tutela',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
