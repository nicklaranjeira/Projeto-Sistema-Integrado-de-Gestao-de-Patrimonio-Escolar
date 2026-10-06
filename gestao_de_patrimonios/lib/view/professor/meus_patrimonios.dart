import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/meus_patrimonios_controlador.dart';
import '../../model/patrimonio_modelo.dart';
import '../widgets/card_patrimonio.dart';
import '../widgets/cracha_status.dart';
import '../widgets/estado_vazio.dart';

/// Visão de Meus Patrimônios (RF08 / RN03) - Painel do Docente com acesso estritamente informativo (apenas leitura).
class MeusPatrimoniosView extends GetView<MeusPatrimoniosControlador> {
  const MeusPatrimoniosView({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Meus Patrimônios',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Equipamentos sob sua guarda',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey.shade600,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Meu Perfil',
            icon: CircleAvatar(
              radius: 17,
              backgroundColor: tema.colorScheme.primary.withOpacity(0.12),
              child: Icon(
                Icons.person_rounded,
                size: 20,
                color: tema.colorScheme.primary,
              ),
            ),
            onPressed: controller.navegarParaPerfil,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Banner de Boas-Vindas e Acolhimento do Docente
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() {
                  final nomeUsuario = controller.usuarioLogado.value?.nome ?? 'Docente';
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          tema.colorScheme.primary.withOpacity(0.9),
                          const Color(0xFF1565C0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Olá, $nomeUsuario!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Confira abaixo os bens escolares vinculados à sua responsabilidade.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),

                // Campo de Busca
                TextField(
                  onChanged: controller.buscar,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por tombamento, nome, sala...',
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
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Lista de Bens
          Expanded(
            child: Obx(() {
              if (controller.carregando.value && controller.listaMeusPatrimonios.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.listaFiltrada.isEmpty) {
                return EstadoVazio(
                  icone: Icons.assignment_turned_in_outlined,
                  titulo: 'Nenhum equipamento vinculado',
                  mensagem: controller.buscaTexto.value.isNotEmpty
                      ? 'Nenhum equipamento sob sua tutela corresponde à busca.'
                      : 'No momento, você não possui bens escolares vinculados à sua responsabilidade.',
                  textoAcao: controller.buscaTexto.value.isNotEmpty ? 'Limpar Busca' : 'Atualizar',
                  aoPressionarAcao: controller.buscaTexto.value.isNotEmpty
                      ? controller.limparFiltros
                      : controller.carregarMeusPatrimonios,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.carregarMeusPatrimonios,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: controller.listaFiltrada.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = controller.listaFiltrada[index];
                    return CardPatrimonio(
                      patrimonio: item,
                      // Permite visualizar modal puramente informativo sem ações de escrita
                      aoTocar: () => _exibirDetalhesInformativos(context, item),
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

  /// Exibe modal puramente informativo com os detalhes do patrimônio (RN03 - Apenas Leitura).
  void _exibirDetalhesInformativos(BuildContext context, PatrimonioModelo item) {
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nome,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tombamento: ${item.numeroTombo}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CrachaStatus(status: item.status),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 12),

              _LinhaDetalheDocente(rotulo: 'Categoria', valor: item.categoria ?? 'Geral'),
              _LinhaDetalheDocente(rotulo: 'Número de Série', valor: item.numeroSerie ?? 'Não informado'),
              _LinhaDetalheDocente(rotulo: 'Localização Registrada', valor: item.localizacao ?? 'Não especificada'),
              if (item.descricao != null && item.descricao!.isNotEmpty)
                _LinhaDetalheDocente(rotulo: 'Observações de Conservação', valor: item.descricao!),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_clock_outlined, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Perfil docente em modo apenas leitura. Para solicitar manutenção ou devolução deste item, procure a coordenação da escola.',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size.fromHeight(46),
                ),
                child: const Text('Fechar Informações'),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _LinhaDetalheDocente extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _LinhaDetalheDocente({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              rotulo,
              style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade500),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A202C)),
            ),
          ),
        ],
      ),
    );
  }
}
