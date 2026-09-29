import 'package:get/get.dart';
import 'api_servico.dart';

class PerfilServico extends GetxService {
  final ApiServico _api = Get.find<ApiServico>();

  Future<Response> obterPerfil() async {
    Response res = await _api.get('/api/users/me');
    if (res.statusCode == 404) {
      res = await _api.get('/api/profile');
    }
    return res;
  }

  Future<Response> atualizarPerfil(Map<String, dynamic> dados) async {
    Response res = await _api.put('/api/users/me', dados);
    if (res.statusCode == 404) {
      res = await _api.put('/api/profile', dados);
    }
    return res;
  }
}
