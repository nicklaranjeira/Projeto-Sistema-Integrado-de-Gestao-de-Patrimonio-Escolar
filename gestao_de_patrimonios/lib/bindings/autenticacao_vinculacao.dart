import 'package:get/get.dart';
import '../controllers/autenticacao_controlador.dart';

class AutenticacaoVinculacao extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AutenticacaoControlador>(() => AutenticacaoControlador());
  }
}
