import 'package:get/get.dart';
import '../controladores/meus_patrimonios_controlador.dart';

class MeusPatrimoniosVinculacao extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeusPatrimoniosControlador>(() => MeusPatrimoniosControlador());
  }
}
