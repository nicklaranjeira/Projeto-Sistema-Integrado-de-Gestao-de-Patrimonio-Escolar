import 'package:get/get.dart';
import '../service/professores.dart';

class ProfessoresController extends GetxController {
  final ProfessoresService service = ProfessoresService();

  var carregando = false.obs;
  var professores = [].obs;

  Future<void> listarProfessores() async {
    carregando.value = true;

    final resposta = await service.listarProfessores();

    if (resposta.isOk) {
      professores.value = resposta.body;
    }

    carregando.value = false;
  }
}