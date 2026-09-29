import 'package:get/get.dart';
import '../controllers/professor_controller.dart';

class ProfessorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfessorController>(() => ProfessorController());
  }
}
