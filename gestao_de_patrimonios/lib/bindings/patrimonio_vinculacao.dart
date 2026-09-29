import 'package:get/get.dart';
import '../controllers/patrimonio_controlador.dart';
import '../controllers/professor_controlador.dart';

class PatrimonioVinculacao extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatrimonioControlador>(() => PatrimonioControlador());
    Get.lazyPut<ProfessorControlador>(() => ProfessorControlador());
  }
}
