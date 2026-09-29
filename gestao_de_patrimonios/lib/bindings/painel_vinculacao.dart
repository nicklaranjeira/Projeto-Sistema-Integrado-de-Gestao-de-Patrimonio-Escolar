import 'package:get/get.dart';
import '../controllers/painel_controlador.dart';

class PainelVinculacao extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PainelControlador>(() => PainelControlador());
  }
}
