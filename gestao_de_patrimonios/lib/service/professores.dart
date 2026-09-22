import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../model/professores.dart';

/// Service responsável pela comunicação com os endpoints de Professores.
class ProfessoresService extends GetConnect {
  String? _customBaseUrl;

  ProfessoresService({String? baseUrl}) {
    _customBaseUrl = baseUrl;
    _configurar();
  }

  @override
  void onInit() {
    _configurar();
    super.onInit();
  }

  void _configurar() {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      httpClient.baseUrl = _customBaseUrl;
    } else {
      final host = (GetPlatform.isAndroid && !kIsWeb) ? '10.0.2.2' : 'localhost';
      httpClient.baseUrl = 'http://$host:8000';
    }

    httpClient.timeout = const Duration(seconds: 10);
    httpClient.defaultContentType = 'application/json';
  }

  Future<Response> _requisicaoComFallback({
    required String metodo,
    required String rotaPrincipal,
    dynamic corpo,
    Map<String, dynamic>? query,
  }) async {
    final rotaAlternativa = rotaPrincipal.replaceFirst('/api/v1', '');

    Response res;
    switch (metodo.toUpperCase()) {
      case 'GET':
        res = await get(rotaPrincipal, query: query);
        if (res.statusCode == 404) {
          res = await get(rotaAlternativa, query: query);
        }
        break;
      case 'POST':
        res = await post(rotaPrincipal, corpo);
        if (res.statusCode == 404) {
          res = await post(rotaAlternativa, corpo);
        }
        break;
      case 'PUT':
        res = await put(rotaPrincipal, corpo);
        if (res.statusCode == 404) {
          res = await put(rotaAlternativa, corpo);
        }
        break;
      case 'DELETE':
        res = await delete(rotaPrincipal);
        if (res.statusCode == 404) {
          res = await delete(rotaAlternativa);
        }
        break;
      default:
        res = await get(rotaPrincipal, query: query);
    }
    return res;
  }

  /// GET /api/v1/professores - Lista todos os professores
  Future<Response<List<Professores>>> listarProfessores() async {
    final response = await _requisicaoComFallback(
      metodo: 'GET',
      rotaPrincipal: '/api/v1/professores',
    );
    return _parseListResponse(response);
  }

  /// GET /api/v1/professores/{matricula} - Detalhes do professor por matrícula ou ID
  Future<Response<Professores>> buscarPorMatricula(String matricula) async {
    final response = await _requisicaoComFallback(
      metodo: 'GET',
      rotaPrincipal: '/api/v1/professores/$matricula',
    );
    return _parseSingleResponse(response);
  }

  /// POST /api/v1/professores - Cadastra um novo professor
  Future<Response<Professores>> cadastrarProfessor(Professores professor) async {
    final response = await _requisicaoComFallback(
      metodo: 'POST',
      rotaPrincipal: '/api/v1/professores',
      corpo: professor.toJson(),
    );
    return _parseSingleResponse(response);
  }

  /// PUT /api/v1/professores/{matricula} - Atualiza dados do professor
  Future<Response<Professores>> atualizarProfessor(
    String matricula,
    Professores professor,
  ) async {
    final response = await _requisicaoComFallback(
      metodo: 'PUT',
      rotaPrincipal: '/api/v1/professores/$matricula',
      corpo: professor.toJson(),
    );
    return _parseSingleResponse(response);
  }

  /// DELETE /api/v1/professores/{matricula} - Exclui um professor
  Future<Response> excluirProfessor(String matricula) async {
    return await _requisicaoComFallback(
      metodo: 'DELETE',
      rotaPrincipal: '/api/v1/professores/$matricula',
    );
  }

  Response<List<Professores>> _parseListResponse(Response response) {
    if (!response.isOk || response.body == null) {
      return Response<List<Professores>>(
        statusCode: response.statusCode,
        statusText: response.statusText,
        headers: response.headers,
        body: [],
      );
    }

    final body = response.body;
    List<dynamic>? listaJson;

    if (body is List) {
      listaJson = body;
    } else if (body is Map) {
      if (body['data'] is Map && body['data']['professores'] is List) {
        listaJson = body['data']['professores'] as List<dynamic>;
      } else if (body['data'] is List) {
        listaJson = body['data'] as List<dynamic>;
      } else if (body['professores'] is List) {
        listaJson = body['professores'] as List<dynamic>;
      }
    }

    final lista = listaJson
            ?.map((item) =>
                Professores.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList() ??
        [];

    return Response<List<Professores>>(
      statusCode: response.statusCode,
      statusText: response.statusText,
      headers: response.headers,
      body: lista,
    );
  }

  Response<Professores> _parseSingleResponse(Response response) {
    if (!response.isOk || response.body == null) {
      return Response<Professores>(
        statusCode: response.statusCode,
        statusText: response.statusText,
        headers: response.headers,
      );
    }

    final body = response.body;
    Map<String, dynamic>? itemMap;

    if (body is Map) {
      if (body['data'] is Map) {
        itemMap = Map<String, dynamic>.from(body['data'] as Map);
      } else {
        itemMap = Map<String, dynamic>.from(body);
      }
    }

    Professores? professor;
    if (itemMap != null) {
      professor = Professores.fromJson(itemMap);
    }

    return Response<Professores>(
      statusCode: response.statusCode,
      statusText: response.statusText,
      headers: response.headers,
      body: professor,
    );
  }
}
