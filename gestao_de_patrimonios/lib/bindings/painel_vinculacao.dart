import 'package:get/get.dart';
import '../controller/painel_controlador.dart';

/// [PainelVinculacao] injeta o controlador responsável pelas estatísticas e métricas do dashboard.
///
/// É associada à rota `/admin/painel` e carrega o [PainelControlador] sob demanda (`lazyPut`).
class PainelVinculacao extends Bindings {
  @override
  void dependencies() {
    // Injeta sob demanda o controlador com dados do resumo estatístico e atividades recentes
    Get.lazyPut<PainelControlador>(() => PainelControlador());
  }
}

