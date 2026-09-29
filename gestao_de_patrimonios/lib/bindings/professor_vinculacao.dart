import 'package:get/get.dart';
import '../controller/professor_controlador.dart';

class ProfessorVinculacao extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfessorControlador>(() => ProfessorControlador());
  }
}
