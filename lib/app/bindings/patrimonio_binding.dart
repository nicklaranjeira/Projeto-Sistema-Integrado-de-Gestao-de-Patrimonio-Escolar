import 'package:get/get.dart';
import '../controllers/patrimonio_controller.dart';
import '../controllers/professor_controller.dart';

class PatrimonioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatrimonioController>(() => PatrimonioController());
    // Disponibiliza também o ProfessorController caso precise selecionar um docente no fluxo de atribuição
    Get.lazyPut<ProfessorController>(() => ProfessorController());
  }
}
