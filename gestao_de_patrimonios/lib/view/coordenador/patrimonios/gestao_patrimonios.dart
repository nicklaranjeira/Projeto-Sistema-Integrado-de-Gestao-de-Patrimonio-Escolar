import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/patrimonio_controlador.dart';
import '../../../routes/rotas_app.dart';
import '../../widgets/card_patrimonio.dart';
import '../../widgets/estado_vazio.dart';

/// Visão de Gestão de Patrimônios (RF07) - Listagem com busca, filtros por status/categoria e acesso a novos cadastros.
class GestaoPatrimoniosView extends GetView<PatrimonioControlador> {
  const GestaoPatrimoniosView({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Inventário Escolar'),
        actions: [
          IconButton(
            tooltip: 'Atualizar Lista',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.listarPatrimonios,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.prepararCadastro();
          Get.toNamed(RotasApp.ADMIN_NOVO_PATRIMONIO);
        },
        backgroundColor: tema.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo Patrimônio'),
      ),
      body: Column(
        children: [
          // Barra de Pesquisa e Filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Campo de Busca
                TextField(
                  onChanged: controller.buscar,
                  decoration: InputDecoration(
                    hintText: 'Buscar por tombamento, nome, série...',
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

                // Filtros rápidos em Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() {
                    final statusAtual = controller.filtroStatus.value;
                    return Row(
                      children: [
                        _ChipFiltro(
                          rotulo: 'Todos',
                          selecionado: statusAtual.isEmpty,
                          aoSelecionar: (_) => controller.definirFiltroStatus(''),
                        ),
                        const SizedBox(width: 6),
                        _ChipFiltro(
                          rotulo: 'Disponíveis',
                          selecionado: statusAtual == 'disponivel',
                          aoSelecionar: (_) => controller.definirFiltroStatus('disponivel'),
                          corPonto: const Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 6),
                        _ChipFiltro(
                          rotulo: 'Em Uso',
                          selecionado: statusAtual == 'alocado' || statusAtual == 'em_uso',
                          aoSelecionar: (_) => controller.definirFiltroStatus('alocado'),
                          corPonto: const Color(0xFF0D47A1),
                        ),
                        const SizedBox(width: 6),
                        _ChipFiltro(
                          rotulo: 'Em Manutenção',
                          selecionado: statusAtual == 'manutencao' || statusAtual == 'em_manutencao',
                          aoSelecionar: (_) => controller.definirFiltroStatus('manutencao'),
                          corPonto: const Color(0xFFEF6C00),
                        ),
                        const SizedBox(width: 6),
                        _ChipFiltro(
                          rotulo: 'Baixados',
                          selecionado: statusAtual == 'baixado',
                          aoSelecionar: (_) => controller.definirFiltroStatus('baixado'),
                          corPonto: const Color(0xFFC62828),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Lista de Bens
          Expanded(
            child: Obx(() {
              if (controller.carregando.value && controller.listaPatrimonios.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.listaFiltrada.isEmpty) {
                return EstadoVazio(
                  icone: Icons.inventory_2_outlined,
                  titulo: 'Nenhum patrimônio localizado',
                  mensagem: controller.buscaTexto.value.isNotEmpty || controller.filtroStatus.value.isNotEmpty
                      ? 'Nenhum bem corresponde aos filtros atuais. Tente ajustar o termo de pesquisa.'
                      : 'Nenhum bem patrimonial cadastrado até o momento.',
                  textoAcao: controller.buscaTexto.value.isNotEmpty || controller.filtroStatus.value.isNotEmpty
                      ? 'Limpar Filtros'
                      : 'Atualizar',
                  aoPressionarAcao: controller.buscaTexto.value.isNotEmpty || controller.filtroStatus.value.isNotEmpty
                      ? controller.limparFiltros
                      : controller.listarPatrimonios,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.listarPatrimonios,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: controller.listaFiltrada.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = controller.listaFiltrada[index];
                    return CardPatrimonio(
                      patrimonio: item,
                      aoTocar: () {
                        controller.carregarDetalhesPatrimonio(item.id);
                        Get.toNamed(
                          RotasApp.ADMIN_DETALHES_PATRIMONIO,
                          arguments: item.id,
                        );
                      },
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

class _ChipFiltro extends StatelessWidget {
  final String rotulo;
  final bool selecionado;
  final ValueChanged<bool> aoSelecionar;
  final Color? corPonto;

  const _ChipFiltro({
    required this.rotulo,
    required this.selecionado,
    required this.aoSelecionar,
    this.corPonto,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (corPonto != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: corPonto, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(rotulo),
        ],
      ),
      selected: selecionado,
      onSelected: aoSelecionar,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selecionado ? FontWeight.bold : FontWeight.w500,
        color: selecionado ? Colors.white : Colors.blueGrey.shade800,
      ),
      selectedColor: tema.colorScheme.primary,
      backgroundColor: Colors.grey.shade100,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selecionado ? tema.colorScheme.primary : Colors.grey.shade300,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}
