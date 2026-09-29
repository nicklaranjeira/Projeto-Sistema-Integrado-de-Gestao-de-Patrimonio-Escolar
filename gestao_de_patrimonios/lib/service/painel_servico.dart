import 'package:get/get.dart';
import 'api_servico.dart';

class PainelServico extends GetxService {
  final ApiServico _api = Get.find<ApiServico>();

  Future<Response> obterEstatisticas() async {
    Response res = await _api.get('/api/dashboard/stats');
    if (res.statusCode == 404) {
      res = await _api.get('/api/dashboard');
    }
    return res;
  }
}
