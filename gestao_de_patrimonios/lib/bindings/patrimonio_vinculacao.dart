import 'package:get/get.dart';
import '../controller/patrimonio_controlador.dart';
import '../controller/professor_controlador.dart';

class PatrimonioVinculacao extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatrimonioControlador>(() => PatrimonioControlador());
    Get.lazyPut<ProfessorControlador>(() => ProfessorControlador());
  }
}
