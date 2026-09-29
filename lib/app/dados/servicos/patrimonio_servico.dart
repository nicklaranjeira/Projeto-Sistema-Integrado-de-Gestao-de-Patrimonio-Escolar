import 'package:get/get.dart';
import 'api_servico.dart';

class PatrimonioServico {
  final ApiServico _api = Get.find<ApiServico>();

  Future<Response> obterPatrimonios({
    String? status,
    String? categoria,
    String? busca,
  }) async {
    final parametros = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'todos') {
      parametros['status'] = status;
    }
    if (categoria != null && categoria.isNotEmpty && categoria != 'todas') {
      parametros['categoria'] = categoria;
    }
    if (busca != null && busca.isNotEmpty) {
      parametros['search'] = busca;
    }

    return await _api.get('/patrimonios', query: parametros);
  }

  Future<Response> obterPatrimonioPorId(int id) async {
    return await _api.get('/patrimonios/$id');
  }

  Future<Response> criarPatrimonio(Map<String, dynamic> dados) async {
    return await _api.post('/patrimonios', dados);
  }

  Future<Response> atualizarPatrimonio(int id, Map<String, dynamic> dados) async {
    return await _api.put('/patrimonios/$id', dados);
  }

  Future<Response> excluirPatrimonio(int id) async {
    return await _api.delete('/patrimonios/$id');
  }

  Future<Response> atribuirPatrimonio(int patrimonioId, int professorId, {String? observacao}) async {
    return await _api.post('/patrimonios/$patrimonioId/atribuir', {
      'professor_id': professorId,
      if (observacao != null && observacao.isNotEmpty) 'observacao': observacao,
    });
  }

  Future<Response> devolverPatrimonio(int patrimonioId, {required String motivo}) async {
    return await _api.post('/patrimonios/$patrimonioId/devolver', {
      'motivo': motivo.trim(),
    });
  }

  Future<Response> obterHistoricoPatrimonio(int patrimonioId) async {
    return await _api.get('/patrimonios/$patrimonioId/historico');
  }
}
