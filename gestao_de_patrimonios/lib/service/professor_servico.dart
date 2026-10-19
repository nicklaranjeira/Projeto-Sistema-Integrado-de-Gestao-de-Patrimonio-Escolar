import 'package:get/get.dart';
import 'api_servico.dart';

class ProfessorServico extends GetxService {
  final ApiServico _api = Get.find<ApiServico>();

  Future<Response> listarProfessores({
    String? status,
    String? busca,
  }) async {
    final query = <String, dynamic>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (busca != null && busca.isNotEmpty) query['busca'] = busca;

    Response res = await _api.get('/api/admin/professores', query: query);
    if (res.statusCode == 404) {
      res = await _api.get('/api/professores', query: query);
    }
    return res;
  }

  Future<Response> obterProfessorPorId(int id) async {
    return await _api.get(
      '/api/admin/professores/$id',
    );
  }

  Future<Response> cadastrarProfessor(Map<String, dynamic> dados) async {
    Response res = await _api.post('/api/admin/professores', dados);
    if (res.statusCode == 404) {
      res = await _api.post('/api/professores', dados);
    }
    return res;
  }

  Future<Response> atualizarProfessor(int id, Map<String, dynamic> dados) async {
    return await _api.put('/api/professores/$id', dados);
  }

  Future<Response> alterarStatus(int id, String status) async {
    return await _api.patch('/api/professores/$id/status', {
      'status': status,
    });
  }

  Future<Response> obterPatrimoniosDoProfessor(int professorId) async {
    Response res = await _api.get('/api/professores/$professorId/patrimonios');
    if (res.statusCode == 404) {
      res = await _api.get('/api/professores/$professorId/itens');
    }
    return res;
  }
}
