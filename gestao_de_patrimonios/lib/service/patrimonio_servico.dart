import 'package:get/get.dart';
import 'api_servico.dart';

class PatrimonioServico extends GetxService {
  final ApiServico _api = Get.find<ApiServico>();

  Future<Response> listarPatrimonios({
    String? status,
    String? categoria,
    String? busca,
  }) async {
    final query = <String, dynamic>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (categoria != null && categoria.isNotEmpty) query['categoria'] = categoria;
    if (busca != null && busca.isNotEmpty) query['busca'] = busca;

    return await _api.get('/api/patrimonios', query: query);
  }

  Future<Response> obterPatrimonioPorId(int id) async {
    return await _api.get('/api/patrimonios/$id');
  }

  Future<Response> cadastrarPatrimonio(
  Map<String, dynamic> dados,
) async {
  return await _api.post(
    '/api/admin/patrimonios',
    dados,
  );
}

  Future<Response> atualizarPatrimonio(int id, Map<String, dynamic> dados) async {
    return await _api.put('/api/patrimonios/$id', dados);
  }

  Future<Response> alocarPatrimonio({
    required int patrimonioId,
    required int professorId,
    String? observacoes,
  }) async {
    return await _api.post('/api/patrimonios/$patrimonioId/atribuir', {
      'professor_id': professorId,
      'observacoes': observacoes,
    });
  }

  Future<Response> devolverPatrimonio({
    required int patrimonioId,
    String? observacoes,
  }) async {
    return await _api.post('/api/patrimonios/$patrimonioId/devolver', {
      'observacoes': observacoes,
    });
  }

  Future<Response> obterHistoricoMovimentacoes(int patrimonioId) async {
    Response res = await _api.get('/api/patrimonios/$patrimonioId/historico');
    if (res.statusCode == 404) {
      res = await _api.get('/api/patrimonios/$patrimonioId/movimentacoes');
    }
    return res;
  }

  Future<Response> desativarPatrimonio(int patrimonioId, {String? motivo}) async {
    return await _api.post('/api/patrimonios/$patrimonioId/desativar', {
      'motivo': motivo,
    });
  }
}
