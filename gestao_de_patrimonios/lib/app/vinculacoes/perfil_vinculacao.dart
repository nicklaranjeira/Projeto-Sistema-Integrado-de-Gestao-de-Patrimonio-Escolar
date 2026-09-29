import 'package:get/get.dart';
import '../controladores/perfil_controlador.dart';

class PerfilVinculacao extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PerfilControlador>(() => PerfilControlador());
  }
}
