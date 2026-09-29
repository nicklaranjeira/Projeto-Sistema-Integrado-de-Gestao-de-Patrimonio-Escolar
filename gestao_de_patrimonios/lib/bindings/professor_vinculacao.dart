import 'package:get/get.dart';
import '../controllers/professor_controlador.dart';

class ProfessorVinculacao extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfessorControlador>(() => ProfessorControlador());
  }
}
