import 'package:get/get.dart';
import '../service/patrimonios.dart';

class PatrimoniosController extends GetxController {
  final PatrimoniosService service = PatrimoniosService();

  var carregando = false.obs;
  var patrimonio = Rxn();

  Future<void> buscarPatrimonio(int id) async {
    carregando.value = true;

    final resposta = await service.buscarPatrimonio(id);

    if (resposta.isOk) {
      patrimonio.value = resposta.body;
    }

    carregando.value = false;
  }
}
