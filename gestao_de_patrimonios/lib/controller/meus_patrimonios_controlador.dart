import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/patrimonio_modelo.dart';
import '../model/usuario_modelo.dart';
import '../service/api_servico.dart';
import '../service/armazenamento_servico.dart';
import '../service/patrimonio_servico.dart';
import '../service/professor_servico.dart';
import '../routes/rotas_app.dart';

class MeusPatrimoniosControlador extends GetxController {
  final PatrimonioServico _patrimonioServico = Get.find<PatrimonioServico>();
  final ProfessorServico _professorServico = Get.find<ProfessorServico>();
  final ArmazenamentoServico _armazenamento = Get.find<ArmazenamentoServico>();
  final ApiServico _api = Get.find<ApiServico>();

  final RxBool carregando = false.obs;
  final RxList<PatrimonioModelo> listaMeusPatrimonios = <PatrimonioModelo>[].obs;
  final RxList<PatrimonioModelo> listaFiltrada = <PatrimonioModelo>[].obs;
  final Rx<UsuarioModelo?> usuarioLogado = Rx<UsuarioModelo?>(null);

  final RxString buscaTexto = ''.obs;
  final RxString filtroCategoria = ''.obs;

  @override
  void onInit() {
    super.onInit();
    usuarioLogado.value = _armazenamento.obterUsuario();
    carregarMeusPatrimonios();
  }

  Future<void> carregarMeusPatrimonios() async {
    carregando.value = true;
    try {
      final usuario = _armazenamento.obterUsuario();
      if (usuario == null) {
        Get.offAllNamed(RotasApp.LOGIN);
        return;
      }

      Response resposta;
      if (usuario.professorId != null) {
        resposta = await _professorServico.obterPatrimoniosDoProfessor(usuario.professorId!);
      } else {
        resposta = await _patrimonioServico.listarPatrimonios(status: 'alocado');
      }

      if (resposta.isOk && resposta.body != null) {
        final List dados = resposta.body is List ? resposta.body : (resposta.body['data'] ?? []);
        final patrimonios = dados
            .map((e) => PatrimonioModelo.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

        listaMeusPatrimonios.assignAll(patrimonios);
        aplicarFiltros();
      } else {
        final erro = _api.tratarErro(resposta);
        Get.snackbar(
          'Erro ao Carregar',
          erro,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro de Conexão',
        'Não foi possível carregar os itens sob sua responsabilidade.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      carregando.value = false;
    }
  }

  void aplicarFiltros() {
    List<PatrimonioModelo> resultado = List.from(listaMeusPatrimonios);

    if (buscaTexto.value.isNotEmpty) {
      final busca = buscaTexto.value.toLowerCase();
      resultado = resultado.where((p) {
        return p.nome.toLowerCase().contains(busca) ||
            p.numeroTombo.toLowerCase().contains(busca) ||
            (p.localizacao?.toLowerCase().contains(busca) ?? false);
      }).toList();
    }

    if (filtroCategoria.value.isNotEmpty) {
      resultado = resultado.where((p) => (p.categoria ?? '').toLowerCase() == filtroCategoria.value.toLowerCase()).toList();
    }

    listaFiltrada.assignAll(resultado);
  }

  void buscar(String texto) {
    buscaTexto.value = texto;
    aplicarFiltros();
  }

  void definirFiltroCategoria(String? categoria) {
    filtroCategoria.value = categoria ?? '';
    aplicarFiltros();
  }

  void limparFiltros() {
    buscaTexto.value = '';
    filtroCategoria.value = '';
    aplicarFiltros();
  }

  void navegarParaPerfil() => Get.toNamed(RotasApp.PERFIL);
}
