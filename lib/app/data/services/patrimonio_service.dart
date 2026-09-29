import 'package:get/get.dart';
import 'api_service.dart';

/// Serviço para gestão e consulta de patrimônios escolares
class PatrimonioService {
  final ApiService _api = Get.find<ApiService>();

  /// [GET] /api/patrimonios - Listar patrimônios com suporte a filtros e busca
  Future<Response> getPatrimonios({
    String? status,
    String? categoria,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'todos') {
      queryParams['status'] = status;
    }
    if (categoria != null && categoria.isNotEmpty && categoria != 'todas') {
      queryParams['categoria'] = categoria;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    return await _api.get('/patrimonios', query: queryParams);
  }

  /// [GET] /api/patrimonios/{id} - Buscar patrimônio por ID
  Future<Response> getPatrimonioById(int id) async {
    return await _api.get('/patrimonios/$id');
  }

  /// [POST] /api/patrimonios - Cadastrar novo bem escolar (Admin)
  Future<Response> createPatrimonio(Map<String, dynamic> data) async {
    return await _api.post('/patrimonios', data);
  }

  /// [PUT] /api/patrimonios/{id} - Atualizar dados do patrimônio (Admin)
  Future<Response> updatePatrimonio(int id, Map<String, dynamic> data) async {
    return await _api.put('/patrimonios/$id', data);
  }

  /// [DELETE] /api/patrimonios/{id} - Excluir ou inativar patrimônio (Admin)
  Future<Response> deletePatrimonio(int id) async {
    return await _api.delete('/patrimonios/$id');
  }

  /// [POST] /api/patrimonios/{id}/atribuir - Atribuir bem ao professor (muda status para 'em_uso')
  Future<Response> atribuirPatrimonio(int patrimonioId, int professorId, {String? observacao}) async {
    return await _api.post('/patrimonios/$patrimonioId/atribuir', {
      'professor_id': professorId,
      if (observacao != null && observacao.isNotEmpty) 'observacao': observacao,
    });
  }

  /// [POST] /api/patrimonios/{id}/devolver - Devolver bem (muda status para 'disponivel' e registra motivo)
  Future<Response> devolverPatrimonio(int patrimonioId, {required String motivo}) async {
    return await _api.post('/patrimonios/$patrimonioId/devolver', {
      'motivo': motivo.trim(),
    });
  }

  /// [GET] /api/patrimonios/{id}/historico - Obter histórico / linha do tempo de movimentações
  Future<Response> getHistoricoPatrimonio(int patrimonioId) async {
    return await _api.get('/patrimonios/$patrimonioId/historico');
  }
}
