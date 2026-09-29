import 'package:get/get.dart';
import '../controller/painel_controlador.dart';

class PainelVinculacao extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PainelControlador>(() => PainelControlador());
  }
}
