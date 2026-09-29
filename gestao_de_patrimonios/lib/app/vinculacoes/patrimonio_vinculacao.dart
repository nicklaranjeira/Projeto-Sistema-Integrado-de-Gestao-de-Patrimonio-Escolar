import 'package:get/get.dart';
import '../controladores/patrimonio_controlador.dart';
import '../controladores/professor_controlador.dart';

class PatrimonioVinculacao extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatrimonioControlador>(() => PatrimonioControlador());
    Get.lazyPut<ProfessorControlador>(() => ProfessorControlador());
  }
}
