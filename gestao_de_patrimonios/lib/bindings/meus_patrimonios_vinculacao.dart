import 'package:get/get.dart';
import '../controller/meus_patrimonios_controlador.dart';

/// [MeusPatrimoniosVinculacao] gerencia a injeção do controlador da visão do docente.
///
/// É acionada na rota `/docente/meus-patrimonios` e carrega o [MeusPatrimoniosControlador]
/// somente quando o professor acessar a lista de bens sob sua custódia.
class MeusPatrimoniosVinculacao extends Bindings {
  @override
  void dependencies() {
    // Injeta sob demanda o controlador que busca e filtra os patrimônios do professor logado
    Get.lazyPut<MeusPatrimoniosControlador>(() => MeusPatrimoniosControlador());
  }
}

