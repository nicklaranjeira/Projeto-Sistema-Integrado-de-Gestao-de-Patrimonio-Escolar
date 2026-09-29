import 'package:get/get.dart';
import '../controladores/professor_controlador.dart';

class ProfessorVinculacao extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfessorControlador>(() => ProfessorControlador());
  }
}
