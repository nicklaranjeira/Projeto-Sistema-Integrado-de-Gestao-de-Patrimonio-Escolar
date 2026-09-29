import 'package:get/get.dart';
import 'api_servico.dart';

class PainelServico {
  final ApiServico _api = Get.find<ApiServico>();

  Future<Response> obterEstatisticas() async {
    return await _api.get('/admin/stats');
  }

  Future<Response> verificarIntegridade() async {
    return await _api.get('/health');
  }
}
