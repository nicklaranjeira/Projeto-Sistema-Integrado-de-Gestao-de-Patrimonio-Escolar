import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/patrimonio_controlador.dart';
import '../../widgets/botao_personalizado.dart';
import '../../widgets/campo_texto_personalizado.dart';

/// Visão de Formulário de Patrimônio (RF07) - Cadastro e Edição de bens escolares.
class FormularioPatrimonioView extends GetView<PatrimonioControlador> {
  const FormularioPatrimonioView({super.key});

  @override
  Widget build(BuildContext context) {
    final ehEdicao = controller.patrimonioSelecionado.value != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(ehEdicao ? 'Editar Patrimônio' : 'Novo Patrimônio'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: controller.formularioChave,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cartão com os dados principais do bem
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Identificação do Equipamento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Nome do Bem
                      CampoTextoPersonalizado(
                        controlador: controller.nomeController,
                        rotulo: 'Nome / Título do Patrimônio *',
                        dica: 'Ex: Notebook Dell Latitude 3420',
                        iconePrefixo: Icons.laptop_rounded,
                        validador: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe o nome do equipamento';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Número do Tombo
                      CampoTextoPersonalizado(
                        controlador: controller.numeroTomboController,
                        rotulo: 'Número de Tombamento (Patrimônio) *',
                        dica: 'Ex: PAT-INFO-0042',
                        iconePrefixo: Icons.qr_code_rounded,
                        validador: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe o código de tombamento';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Número de Série
                      CampoTextoPersonalizado(
                        controlador: controller.numeroSerieController,
                        rotulo: 'Número de Série do Fabricante',
                        dica: 'Ex: SN-889977ABC',
                        iconePrefixo: Icons.tag_rounded,
                      ),
                      const SizedBox(height: 16),

                      // Categoria (com seleção rápida ou texto)
                      Text(
                        'Categoria do Bem',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: controller.categoriaController.text.isNotEmpty &&
                                controller.categoriasDisponiveis.contains(controller.categoriaController.text)
                            ? controller.categoriaController.text
                            : null,
                        hint: Text(
                          controller.categoriaController.text.isNotEmpty
                              ? controller.categoriaController.text
                              : 'Selecione a categoria',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.category_outlined, color: Theme.of(context).colorScheme.primary),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        items: controller.categoriasDisponiveis.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.categoriaController.text = val;
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Localização
                      CampoTextoPersonalizado(
                        controlador: controller.localizacaoController,
                        rotulo: 'Localização Escolar / Armazenamento',
                        dica: 'Ex: Laboratório de Informática 01, Almoxarifado Central',
                        iconePrefixo: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Descrição detalhada
                      CampoTextoPersonalizado(
                        controlador: controller.descricaoController,
                        rotulo: 'Observações / Especificações',
                        dica: 'Detalhes de conservação, acessórios inclusos (cabos, fontes, capas)...',
                        iconePrefixo: Icons.notes_rounded,
                        maxLinhas: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botão de salvar
                Obx(
                  () => BotaoPersonalizado(
                    texto: ehEdicao ? 'Salvar Alterações' : 'Cadastrar Patrimônio',
                    icone: Icons.check_circle_outline_rounded,
                    carregando: controller.salvando.value,
                    aoPressionar: controller.salvarPatrimonio,
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
