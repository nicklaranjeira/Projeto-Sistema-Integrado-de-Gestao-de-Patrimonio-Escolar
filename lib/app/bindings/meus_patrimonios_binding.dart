import 'package:get/get.dart';
import '../controllers/meus_patrimonios_controller.dart';

class MeusPatrimoniosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeusPatrimoniosController>(() => MeusPatrimoniosController());
  }
}
