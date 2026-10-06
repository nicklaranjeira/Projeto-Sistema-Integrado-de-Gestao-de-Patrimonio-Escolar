import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/painel_controlador.dart';
import '../../routes/rotas_app.dart';
import '../widgets/card_estatistica.dart';
import '../widgets/card_patrimonio.dart';

/// Visão do Painel do Coordenador (RF05) - Dashboard de indicadores patrimoniais e ações rápidas.
class PainelCoordenadorView extends GetView<PainelControlador> {
  const PainelCoordenadorView({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Painel do Coordenador',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Gestão de Patrimônio Escolar',
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
      body: Obx(() {
        if (controller.carregando.value && controller.estatisticas.value.totalPatrimonios == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = controller.estatisticas.value;

        return RefreshIndicator(
          onRefresh: controller.atualizar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Boas-vindas amigáveis
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tema.colorScheme.primary,
                        const Color(0xFF1565C0),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: tema.colorScheme.primary.withOpacity(0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.dashboard_customize_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Visão Geral do Inventário',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Acompanhe a disponibilidade e o uso dos bens da sua escola em tempo real.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Grid de Indicadores Patrimoniais (RF05)
                const Text(
                  'Indicadores Patrimoniais',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final larguraCard = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: larguraCard,
                          child: CardEstatistica(
                            titulo: 'Total de Bens',
                            valor: stats.totalPatrimonios.toString(),
                            icone: Icons.inventory_2_rounded,
                            corTema: const Color(0xFF1E88E5),
                            aoTocar: controller.navegarParaPatrimonios,
                          ),
                        ),
                        SizedBox(
                          width: larguraCard,
                          child: CardEstatistica(
                            titulo: 'Em Uso',
                            valor: stats.totalAlocados.toString(),
                            icone: Icons.assignment_ind_rounded,
                            corTema: const Color(0xFF0D47A1),
                            aoTocar: controller.navegarParaPatrimonios,
                          ),
                        ),
                        SizedBox(
                          width: larguraCard,
                          child: CardEstatistica(
                            titulo: 'Disponíveis',
                            valor: stats.totalDisponiveis.toString(),
                            icone: Icons.check_circle_rounded,
                            corTema: const Color(0xFF2E7D32),
                            aoTocar: controller.navegarParaPatrimonios,
                          ),
                        ),
                        SizedBox(
                          width: larguraCard,
                          child: CardEstatistica(
                            titulo: 'Em Manutenção',
                            valor: stats.totalManutencao.toString(),
                            icone: Icons.build_circle_rounded,
                            corTema: const Color(0xFFEF6C00),
                            aoTocar: controller.navegarParaPatrimonios,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Card de Professores Cadastrados
                CardEstatistica(
                  titulo: 'Professores Cadastrados na Instituição',
                  valor: stats.totalProfessores.toString(),
                  icone: Icons.school_rounded,
                  corTema: const Color(0xFF6A1B9A),
                  aoTocar: controller.navegarParaProfessores,
                ),
                const SizedBox(height: 24),

                // Atalhos de Ação Rápida
                const Text(
                  'Ações Rápidas de Gestão',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _BotaoAtalhoRapido(
                        icone: Icons.add_box_rounded,
                        rotulo: 'Cadastrar\nPatrimônio',
                        cor: const Color(0xFF1E88E5),
                        aoPressionar: controller.navegarParaNovoPatrimonio,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _BotaoAtalhoRapido(
                        icone: Icons.person_add_alt_1_rounded,
                        rotulo: 'Cadastrar\nProfessor',
                        cor: const Color(0xFF26A69A),
                        aoPressionar: controller.navegarParaNovoProfessor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _BotaoAtalhoRapido(
                        icone: Icons.list_alt_rounded,
                        rotulo: 'Consultar\nInventário',
                        cor: const Color(0xFF5C6BC0),
                        aoPressionar: controller.navegarParaPatrimonios,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Distribuição por Categoria
                if (stats.contagemPorCategoria.isNotEmpty) ...[
                  const Text(
                    'Distribuição por Categoria',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: stats.contagemPorCategoria.entries.map((item) {
                        final proporcao = stats.totalPatrimonios > 0
                            ? item.value / stats.totalPatrimonios
                            : 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${item.value} item(ns)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: tema.colorScheme.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: proporcao,
                                  backgroundColor: Colors.grey.shade200,
                                  color: tema.colorScheme.primary,
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Últimos Patrimônios Cadastrados
                if (controller.ultimosPatrimonios.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Itens Recentes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263238),
                        ),
                      ),
                      TextButton(
                        onPressed: controller.navegarParaPatrimonios,
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.ultimosPatrimonios.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = controller.ultimosPatrimonios[index];
                      return CardPatrimonio(
                        patrimonio: item,
                        aoTocar: () {
                          Get.toNamed(
                            RotasApp.ADMIN_DETALHES_PATRIMONIO,
                            arguments: item.id,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _BotaoAtalhoRapido extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final Color cor;
  final VoidCallback aoPressionar;

  const _BotaoAtalhoRapido({
    required this.icone,
    required this.rotulo,
    required this.cor,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: aoPressionar,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: cor, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                rotulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
