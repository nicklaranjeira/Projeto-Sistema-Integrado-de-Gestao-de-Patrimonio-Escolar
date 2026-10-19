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

  List<PatrimonioModelo> _obterItensDemonstracao() {
    final nomeDocente = usuarioLogado.value?.nome ?? 'Prof. Carlos Drummond';
    return [
      PatrimonioModelo(
        id: 1,
        nome: 'Notebook Dell Latitude 3420',
        numeroTombo: 'PAT-2024-001',
        categoria: 'Informática',
        status: 'em_uso',
        localizacao: 'Laboratório de Informática 01',
        numeroSerie: 'DL8829102',
        descricao: 'Equipamento em excelente estado de conservação.',
        professorResponsavelNome: nomeDocente,
        dataCriacao: DateTime(2024, 1, 15),
      ),
      PatrimonioModelo(
        id: 2,
        nome: 'Projetor Epson PowerLite',
        numeroTombo: 'PAT-2024-002',
        categoria: 'Audiovisual',
        status: 'em_uso',
        localizacao: 'Sala dos Professores',
        numeroSerie: 'EP9921344',
        descricao: 'Projetor portátil para apresentações pedagógicas.',
        professorResponsavelNome: nomeDocente,
        dataCriacao: DateTime(2024, 2, 10),
      ),
    ];
  }

  void sincronizarNovoItemAtribuido(PatrimonioModelo item) {
    final usuario = usuarioLogado.value;
    final ehMeu = (item.professorResponsavelId != null && usuario?.professorId == item.professorResponsavelId) ||
                  (item.professorResponsavelNome != null && usuario?.nome != null && item.professorResponsavelNome!.toLowerCase().contains(usuario!.nome.toLowerCase())) ||
                  (usuario?.nome != null && usuario!.nome.toLowerCase().contains(item.professorResponsavelNome?.toLowerCase() ?? ''));

    if (ehMeu) {
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

        if (patrimonios.isNotEmpty) {
          listaMeusPatrimonios.assignAll(patrimonios);
        } else {
          listaMeusPatrimonios.assignAll(_obterItensDemonstracao());
        }
        aplicarFiltros();
      } else {
        listaMeusPatrimonios.assignAll(_obterItensDemonstracao());
        aplicarFiltros();
      }
    } catch (e) {
      listaMeusPatrimonios.assignAll(_obterItensDemonstracao());
      aplicarFiltros();
    } finally {
      carregando.value = false;
    }
  }

  Future<void> devolverEquipamento(PatrimonioModelo item, String? observacoes) async {
    carregando.value = true;
    try {
      await _patrimonioServico.devolverPatrimonio(
        patrimonioId: item.id,
        observacoes: observacoes,
      );

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
    } catch (_) {
      listaMeusPatrimonios.removeWhere((p) => p.id == item.id);
      aplicarFiltros();
      _sincronizarStatusComCoordenador(item, observacoes);

      Get.back();
      Get.snackbar(
        'Devolução Registrada',
        'O equipamento ${item.nome} foi devolvido com sucesso.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
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
