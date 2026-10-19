import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/patrimonio_modelo.dart';
import '../model/usuario_modelo.dart';
import '../service/api_servico.dart';
import '../service/armazenamento_servico.dart';
import '../service/patrimonio_servico.dart';
import '../service/professor_servico.dart';
import '../model/estatisticas_painel_modelo.dart';
import '../model/historico_movimentacao_modelo.dart';
import 'painel_controlador.dart';
import 'patrimonio_controlador.dart';
import 'professor_controlador.dart';
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

  bool usuarioEhResponsavel(PatrimonioModelo item) {
    final usuario = usuarioLogado.value;
    if (usuario == null) return false;

    // Se for administrador ou coordenador, possui acesso amplo
    if (usuario.ehAdministrador) return true;

    // 1. Verificação por ID do docente responsável
    if (item.professorResponsavelId != null) {
      if (usuario.professorId != null && item.professorResponsavelId == usuario.professorId) {
        return true;
      }
      if (usuario.id != 0 && item.professorResponsavelId == usuario.id) {
        return true;
      }
    }

    // 2. Verificação por Nome do docente responsável
    if (item.professorResponsavelNome != null && item.professorResponsavelNome!.isNotEmpty && usuario.nome.isNotEmpty) {
      final nomeItem = item.professorResponsavelNome!.toLowerCase().trim();
      final nomeDocente = usuario.nome.toLowerCase().trim();
      if (nomeItem == nomeDocente || nomeItem.contains(nomeDocente) || nomeDocente.contains(nomeItem)) {
        return true;
      }
    }

    return false;
  }

  void sincronizarNovoItemAtribuido(PatrimonioModelo item) {
    if (usuarioEhResponsavel(item)) {
      final index = listaMeusPatrimonios.indexWhere((p) => p.id == item.id);
      if (index != -1) {
        listaMeusPatrimonios[index] = item;
      } else {
        listaMeusPatrimonios.insert(0, item);
      }
      aplicarFiltros();
    }
  }

  Future<void> carregarMeusPatrimonios() async {
    carregando.value = true;
    try {
      final usuario = _armazenamento.obterUsuario();
      if (usuario == null) {
        Get.offAllNamed(RotasApp.LOGIN);
        return;
      }

      Response resposta = await _patrimonioServico.listarPatrimonios();
      if (!resposta.isOk && usuario.professorId != null) {
        resposta = await _professorServico.obterPatrimoniosDoProfessor(usuario.professorId!);
      }

      if (resposta.isOk && resposta.body != null) {
        final List dados = resposta.body is List
            ? resposta.body
            : (resposta.body['items'] ?? resposta.body['patrimonios'] ?? resposta.body['data'] ?? []);
        final patrimonios = dados
            .map((e) => PatrimonioModelo.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((p) => usuarioEhResponsavel(p))
            .toList();

        listaMeusPatrimonios.assignAll(patrimonios);
        aplicarFiltros();
      } else {
        listaMeusPatrimonios.clear();
        aplicarFiltros();
      }
    } catch (_) {
      listaMeusPatrimonios.clear();
      aplicarFiltros();
    } finally {
      carregando.value = false;
    }
  }

  Future<void> devolverEquipamento(PatrimonioModelo item, String? observacoes) async {
    if (!usuarioEhResponsavel(item)) {
      Get.snackbar(
        'Acesso Negado',
        'Você só pode realizar a devolução de patrimônios registrados sob seu próprio nome.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return;
    }

    carregando.value = true;
    try {
      final res = await _patrimonioServico.devolverPatrimonio(
        patrimonioId: item.id,
        observacoes: observacoes,
      );

      if (!res.isOk) {
        throw Exception(_api.tratarErro(res));
      }

      listaMeusPatrimonios.removeWhere((p) => p.id == item.id);
      aplicarFiltros();
      _sincronizarStatusComCoordenador(item, observacoes);

      Get.back();
      Get.snackbar(
        'Devolução Concluída',
        'O equipamento ${item.nome} foi devolvido com sucesso.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Falha na Devolução',
        'Não foi possível registrar a devolução: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      carregando.value = false;
    }
  }

  void _sincronizarStatusComCoordenador(PatrimonioModelo item, String? observacoes) {
    // 1. Atualiza lista de patrimônios e ficha de detalhes do coordenador
    if (Get.isRegistered<PatrimonioControlador>()) {
      Get.find<PatrimonioControlador>().notificarDevolucaoItem(
        item.id,
        motivo: observacoes,
        professorNome: usuarioLogado.value?.nome,
      );
    }

    // 2. Atualiza indicadores e movimentações recentes do painel do coordenador
    if (Get.isRegistered<PainelControlador>()) {
      final painel = Get.find<PainelControlador>();
      final stats = painel.estatisticas.value;
      if (stats.totalAlocados > 0) {
        painel.estatisticas.value = EstatisticasPainelModelo(
          totalPatrimonios: stats.totalPatrimonios,
          totalDisponiveis: stats.totalDisponiveis + 1,
          totalAlocados: stats.totalAlocados - 1,
          totalManutencao: stats.totalManutencao,
          totalBaixados: stats.totalBaixados,
          totalProfessores: stats.totalProfessores,
          totalProfessoresAtivos: stats.totalProfessoresAtivos,
          contagemPorCategoria: stats.contagemPorCategoria,
        );
      }
      painel.ultimasMovimentacoes.insert(
        0,
        HistoricoMovimentacaoModelo(
          id: DateTime.now().millisecondsSinceEpoch,
          patrimonioId: item.id,
          patrimonioNome: item.nome,
          tipoMovimentacao: 'devolucao',
          professorNome: usuarioLogado.value?.nome ?? 'Docente',
          observacoes: observacoes ?? 'Devolução realizada pelo professor',
          dataHora: DateTime.now(),
        ),
      );
    }

    // 3. Atualiza listagem de professores para decrementar contagem de bens
    if (Get.isRegistered<ProfessorControlador>()) {
      Get.find<ProfessorControlador>().listarProfessores();
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
