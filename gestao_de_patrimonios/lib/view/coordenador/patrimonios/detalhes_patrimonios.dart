import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/patrimonio_controlador.dart';
import '../../../model/patrimonio_modelo.dart';
import '../../../model/professor_modelo.dart';
import '../../../routes/rotas_app.dart';
import '../../widgets/botao_personalizado.dart';
import '../../widgets/campo_texto_personalizado.dart';
import '../../widgets/cracha_status.dart';

/// Visão de Detalhes do Patrimônio (RF07) - Consulta aprofundada, Atribuição, Devolução e Linha do Tempo.
class DetalhesPatrimonioView extends GetView<PatrimonioControlador> {
  const DetalhesPatrimonioView({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    // Carrega detalhes se ID veio por parâmetro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final argumentoId = Get.arguments as int?;
      if (argumentoId != null &&
          (controller.patrimonioSelecionado.value == null ||
              controller.patrimonioSelecionado.value!.id != argumentoId)) {
        controller.carregarDetalhesPatrimonio(argumentoId);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Ficha do Patrimônio'),
        actions: [
          Obx(() {
            final bem = controller.patrimonioSelecionado.value;
            if (bem == null) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (opcao) {
                if (opcao == 'editar') {
                  controller.prepararEdicao(bem);
                  Get.toNamed(RotasApp.ADMIN_NOVO_PATRIMONIO);
                } else if (opcao == 'desativar') {
                  _exibirDialogoDesativar(context, bem);
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
                if (!bem.estaBaixado)
                  const PopupMenuItem(
                    value: 'desativar',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle_outline_rounded, size: 20, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Baixar / Desativar'),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.carregandoDetalhes.value && controller.patrimonioSelecionado.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final bem = controller.patrimonioSelecionado.value;
        if (bem == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Patrimônio não localizado.'),
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
              // Card de Destaque com Tombamento e Status
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: tema.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            bem.numeroTombo.isNotEmpty ? bem.numeroTombo : 'S/ TOMBO',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: tema.colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        CrachaStatus(status: bem.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      bem.nome,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    if (bem.categoria != null && bem.categoria!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        bem.categoria!,
                        style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Seção de Ações do Ciclo de Vida (RN05: Atribuição / Devolução)
              _construirAcoesCicloDeVida(context, bem),
              const SizedBox(height: 20),

              // Informações Técnicas e Cadastrais
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
                      'Informações Cadastrais',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263238),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ItemInfo(
                      icone: Icons.tag_rounded,
                      rotulo: 'Número de Série',
                      valor: bem.numeroSerie ?? 'Não informado',
                    ),
                    _ItemInfo(
                      icone: Icons.location_on_outlined,
                      rotulo: 'Localização Física',
                      valor: bem.localizacao ?? 'Não especificada',
                    ),
                    _ItemInfo(
                      icone: Icons.person_outline_rounded,
                      rotulo: 'Docente Responsável',
                      valor: bem.professorResponsavelNome ?? 'Em posse do almoxarifado escolar',
                      destaque: bem.professorResponsavelNome != null,
                    ),
                    if (bem.descricao != null && bem.descricao!.isNotEmpty)
                      _ItemInfo(
                        icone: Icons.notes_rounded,
                        rotulo: 'Observações / Conservação',
                        valor: bem.descricao!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Histórico de Movimentações (Linha do Tempo)
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
                    Row(
                      children: [
                        Icon(Icons.history_rounded, color: tema.colorScheme.primary, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'Linha do Tempo de Movimentações',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF263238),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (controller.historicoMovimentacoes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Nenhuma movimentação registrada no histórico.',
                          style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade400),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.historicoMovimentacoes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final h = controller.historicoMovimentacoes[index];
                          final ehAtribuicao = h.ehAlocacao ||
                              h.tipoMovimentacao.toLowerCase().contains('atribu');

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ehAtribuicao ? Colors.blue.shade100 : Colors.green.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    ehAtribuicao ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                    size: 16,
                                    color: ehAtribuicao ? Colors.blue.shade900 : Colors.green.shade900,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h.tipoMovimentacao.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: ehAtribuicao ? Colors.blue.shade800 : Colors.green.shade800,
                                        ),
                                      ),
                                      if (h.professorNome != null && h.professorNome!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Docente: ${h.professorNome}',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                      if (h.observacoes != null && h.observacoes!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Obs: ${h.observacoes}',
                                          style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade600),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        '${h.dataHora.day.toString().padLeft(2, '0')}/${h.dataHora.month.toString().padLeft(2, '0')}/${h.dataHora.year} às ${h.dataHora.hour.toString().padLeft(2, '0')}:${h.dataHora.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade400),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

  Widget _construirAcoesCicloDeVida(BuildContext context, PatrimonioModelo bem) {
    // Se o bem está disponível -> Exibir ação de Atribuição a professor
    if (bem.estaDisponivel) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_ind_rounded, color: Colors.green.shade800, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Item disponível no estoque escolar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BotaoPersonalizado(
              texto: 'Atribuir a um Professor',
              icone: Icons.person_add_alt_1_rounded,
              aoPressionar: () => _abrirModalAtribuicao(context, bem),
            ),
          ],
        ),
      );
    }

    // Se o bem está em uso (alocado) -> Exibir ação de Devolução
    if (bem.estaAlocado || bem.status.toLowerCase() == 'em_uso') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_turned_in_rounded, color: Colors.blue.shade800, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sob custódia do docente: ${bem.professorResponsavelNome ?? 'Docente vinculado'}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BotaoPersonalizado(
              texto: 'Registrar Devolução ao Estoque',
              icone: Icons.assignment_return_rounded,
              aoPressionar: () => _abrirModalDevolucao(context, bem),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _abrirModalAtribuicao(BuildContext context, PatrimonioModelo bem) {
    controller.carregarProfessoresParaAlocacao();
    controller.professorSelecionadoParaAlocacao.value = null;
    controller.observacoesAlocacaoController.clear();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Atribuir Patrimônio',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione o professor que receberá a custódia de: "${bem.nome}"',
                style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600),
              ),
              const SizedBox(height: 20),

              // Lista de Professores Ativos
              Obx(() {
                if (controller.carregandoProfessores.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.listaProfessoresAtivos.isEmpty) {
                  return const Text(
                    'Nenhum professor ativo encontrado para atribuição.',
                    style: TextStyle(color: Colors.red),
                  );
                }

                return DropdownButtonFormField<ProfessorModelo>(
                  value: controller.professorSelecionadoParaAlocacao.value,
                  hint: const Text('Selecione o professor responsável'),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.school_rounded),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: controller.listaProfessoresAtivos.map((p) {
                    return DropdownMenuItem<ProfessorModelo>(
                      value: p,
                      child: Text('${p.nome} (${p.departamento ?? 'Docente'})'),
                    );
                  }).toList(),
                  onChanged: (p) => controller.professorSelecionadoParaAlocacao.value = p,
                );
              }),
              const SizedBox(height: 16),

              // Observações de entrega
              CampoTextoPersonalizado(
                controlador: controller.observacoesAlocacaoController,
                rotulo: 'Observações de Entrega (Opcional)',
                dica: 'Ex: Entregue completo com carregador original e cabo HDMI',
                iconePrefixo: Icons.note_add_outlined,
                maxLinhas: 2,
              ),
              const SizedBox(height: 24),

              // Botão Confirmar
              Obx(
                () => BotaoPersonalizado(
                  texto: 'Confirmar Atribuição',
                  icone: Icons.check_rounded,
                  carregando: controller.salvando.value,
                  aoPressionar: () {
                    final prof = controller.professorSelecionadoParaAlocacao.value;
                    if (prof == null) {
                      Get.snackbar(
                        'Atenção',
                        'Selecione um professor antes de continuar.',
                        backgroundColor: Colors.orange.shade700,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    controller.alocarPatrimonio(
                      patrimonioId: bem.id,
                      professorId: prof.id,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _abrirModalDevolucao(BuildContext context, PatrimonioModelo bem) {
    controller.observacoesDevolucaoController.clear();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Registrar Devolução',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'O bem "${bem.nome}" retornará ao status de DISPONÍVEL no estoque escolar.',
                style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600),
              ),
              const SizedBox(height: 20),

              // Campo de motivo da devolução
              CampoTextoPersonalizado(
                controlador: controller.observacoesDevolucaoController,
                rotulo: 'Motivo da Devolução / Observação de Entrada *',
                dica: 'Ex: Fim do semestre letivo, devolução de rotina, troca...',
                iconePrefixo: Icons.description_outlined,
                maxLinhas: 3,
              ),
              const SizedBox(height: 24),

              // Botão Confirmar Devolução
              Obx(
                () => BotaoPersonalizado(
                  texto: 'Confirmar Devolução',
                  icone: Icons.assignment_return_rounded,
                  carregando: controller.salvando.value,
                  aoPressionar: () {
                    controller.devolverPatrimonio(patrimonioId: bem.id);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _exibirDialogoDesativar(BuildContext context, PatrimonioModelo bem) {
    final motivoCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Baixar Patrimônio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja dar baixa no patrimônio "${bem.nome}"? Esta ação registra o bem como inativo/baixado.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: motivoCtrl,
              decoration: const InputDecoration(
                labelText: 'Motivo da baixa (ex: sucata, quebra)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              Get.back();
              controller.desativarPatrimonio(bem.id, motivo: motivoCtrl.text.trim());
            },
            child: const Text('Confirmar Baixa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ItemInfo extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;
  final bool destaque;

  const _ItemInfo({
    required this.icone,
    required this.rotulo,
    required this.valor,
    this.destaque = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: destaque ? Colors.blue.shade700 : Colors.blueGrey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo,
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: destaque ? FontWeight.bold : FontWeight.w500,
                    color: destaque ? Colors.blue.shade900 : Colors.blueGrey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
