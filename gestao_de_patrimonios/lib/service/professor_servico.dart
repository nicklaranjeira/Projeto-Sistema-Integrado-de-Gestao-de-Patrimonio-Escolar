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

    if (res.isOk && res.body != null) {
      List? listaOriginal;
      Map<String, dynamic>? corpoMapa;

      if (res.body is Map) {
        corpoMapa = Map<String, dynamic>.from(res.body as Map);
        if (corpoMapa['professores'] is List) {
          listaOriginal = corpoMapa['professores'] as List;
        } else if (corpoMapa['data'] is List) {
          listaOriginal = corpoMapa['data'] as List;
        } else if (corpoMapa['data'] is Map && (corpoMapa['data'] as Map)['professores'] is List) {
          listaOriginal = (corpoMapa['data'] as Map)['professores'] as List;
        }
      } else if (res.body is List) {
        listaOriginal = res.body as List;
      }

      if (listaOriginal != null) {
        final idsVistos = <dynamic>{};
        final emailsVistos = <String>{};
        final matriculasVistas = <String>{};
        final nomesVistos = <String>{};
        final listaDeduplicada = [];

        for (final item in listaOriginal) {
          if (item is Map) {
            final id = item['id'];
            final email = item['email']?.toString().trim().toLowerCase();
            final matricula = item['matricula']?.toString().trim();
            final nome = item['nome']?.toString().trim().toLowerCase();

            final ehDuplicado = (id != null && idsVistos.contains(id)) ||
                (email != null && email.isNotEmpty && emailsVistos.contains(email)) ||
                (matricula != null && matricula.isNotEmpty && matriculasVistas.contains(matricula)) ||
                (nome != null && nome.isNotEmpty && nomesVistos.contains(nome));

            if (ehDuplicado) continue;

            if (id != null) idsVistos.add(id);
            if (email != null && email.isNotEmpty) emailsVistos.add(email);
            if (matricula != null && matricula.isNotEmpty) matriculasVistas.add(matricula);
            if (nome != null && nome.isNotEmpty) nomesVistos.add(nome);

            listaDeduplicada.add(item);
          } else {
            listaDeduplicada.add(item);
          }
        }

        if (corpoMapa != null) {
          if (corpoMapa.containsKey('professores')) {
            corpoMapa['professores'] = listaDeduplicada;
          } else if (corpoMapa.containsKey('data')) {
            if (corpoMapa['data'] is List) {
              corpoMapa['data'] = listaDeduplicada;
            } else if (corpoMapa['data'] is Map) {
              final subData = Map<String, dynamic>.from(corpoMapa['data'] as Map);
              subData['professores'] = listaDeduplicada;
              corpoMapa['data'] = subData;
            }
          }
          if (corpoMapa.containsKey('total')) {
            corpoMapa['total'] = listaDeduplicada.length;
          }
          return Response(
            body: corpoMapa,
            statusCode: res.statusCode,
            statusText: res.statusText,
            headers: res.headers,
            request: res.request,
          );
        } else {
          return Response(
            body: listaDeduplicada,
            statusCode: res.statusCode,
            statusText: res.statusText,
            headers: res.headers,
            request: res.request,
          );
        }
      }
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
