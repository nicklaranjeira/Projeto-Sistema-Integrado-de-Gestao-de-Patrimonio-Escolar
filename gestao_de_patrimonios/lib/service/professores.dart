import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../model/professores.dart';

/// Service responsável pela comunicação com os endpoints de Professores.
class ProfessoresService extends GetConnect {
  String? _customBaseUrl;

  ProfessoresService({String? baseUrl, String? token}) {
    _customBaseUrl = baseUrl;
    _configurar();
    if (token != null && token.isNotEmpty) {
      definirToken(token);
    }
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

  /// Define o token JWT para requisições autenticadas
  void definirToken(String token) {
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Authorization'] = 'Bearer $token';
      return request;
    });
  }

  Future<Response> _requisicaoComFallback({
    required String metodo,
    required String endpoint,
    dynamic corpo,
    Map<String, dynamic>? query,
  }) async {
    Response res;
    switch (metodo.toUpperCase()) {
      case 'GET':
        res = await get(endpoint, query: query);
        break;
      case 'POST':
        res = await post(endpoint, corpo);
        break;
      case 'PUT':
        res = await put(endpoint, corpo);
        break;
      case 'DELETE':
        res = await delete(endpoint);
        break;
      default:
        res = await get(endpoint, query: query);
    }

    if (res.statusCode == 404) {
      // Fallback para alternativas: /api/professores ou /api/v1/professores
      final rotaAlt = endpoint.contains('/admin/')
          ? endpoint.replaceFirst('/admin/', '/')
          : endpoint.replaceFirst('/api/', '/api/v1/');

      switch (metodo.toUpperCase()) {
        case 'GET':
          final resAlt = await get(rotaAlt, query: query);
          if (resAlt.isOk) return resAlt;
          break;
        case 'POST':
          final resAlt = await post(rotaAlt, corpo);
          if (resAlt.isOk) return resAlt;
          break;
        case 'PUT':
          final resAlt = await put(rotaAlt, corpo);
          if (resAlt.isOk) return resAlt;
          break;
        case 'DELETE':
          final resAlt = await delete(rotaAlt);
          if (resAlt.isOk) return resAlt;
          break;
      }
    }
    return res;
  }

  /// GET /api/admin/professores - Lista todos os professores
  Future<Response<List<Professores>>> listarProfessores() async {
    final response = await _requisicaoComFallback(
      metodo: 'GET',
      endpoint: '/api/admin/professores',
    );
    return _parseListResponse(response);
  }

  /// GET /api/admin/professores/{matricula} - Detalhes do professor por matrícula ou ID
  Future<Response<Professores>> buscarPorMatricula(String matricula) async {
    final response = await _requisicaoComFallback(
      metodo: 'GET',
      endpoint: '/api/admin/professores/$matricula',
    );
    return _parseSingleResponse(response);
  }

  /// POST /api/admin/professores - Cadastra um novo professor
  Future<Response<Professores>> cadastrarProfessor(Professores professor) async {
    final response = await _requisicaoComFallback(
      metodo: 'POST',
      endpoint: '/api/admin/professores',
      corpo: professor.toJson(),
    );
    return _parseSingleResponse(response);
  }

  /// PUT /api/admin/professores/{matricula} - Atualiza dados do professor
  Future<Response<Professores>> atualizarProfessor(
    String matricula,
    Professores professor,
  ) async {
    final response = await _requisicaoComFallback(
      metodo: 'PUT',
      endpoint: '/api/admin/professores/$matricula',
      corpo: professor.toJson(),
    );
    return _parseSingleResponse(response);
  }

  /// DELETE /api/admin/professores/{matricula} - Exclui um professor
  Future<Response> excluirProfessor(String matricula) async {
    return await _requisicaoComFallback(
      metodo: 'DELETE',
      endpoint: '/api/admin/professores/$matricula',
    );
  }

  Response<List<Professores>> _parseListResponse(Response response) {
    if (!response.isOk || response.body == null) {
      return Response<List<Professores>>(
        statusCode: response.statusCode,
        statusText: response.statusText,
        headers: response.headers,
        body: null,
      );
    }

    final body = response.body;
    List<dynamic>? listaJson;

    if (body is List) {
      listaJson = body;
    } else if (body is Map) {
      final data = body['data'];
      if (data is Map && data['professores'] is List) {
        listaJson = data['professores'] as List<dynamic>;
      } else if (data is List) {
        listaJson = data;
      } else if (body['professores'] is List) {
        listaJson = body['professores'] as List<dynamic>;
      }
    }

    final lista = <Professores>[];
    if (listaJson != null) {
      for (final item in listaJson) {
        try {
          if (item is Map) {
            lista.add(Professores.fromJson(Map<String, dynamic>.from(item)));
          }
        } catch (_) {}
      }
    }

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
        body: null,
      );
    }

    final body = response.body;
    Map<String, dynamic>? itemMap;

    if (body is Map) {
      final data = body['data'];
      if (data is Map) {
        itemMap = Map<String, dynamic>.from(data);
      } else {
        itemMap = Map<String, dynamic>.from(body);
      }
    }

    Professores? professor;
    if (itemMap != null) {
      try {
        professor = Professores.fromJson(itemMap);
      } catch (_) {}
    }

    return Response<Professores>(
      statusCode: response.statusCode,
      statusText: response.statusText,
      headers: response.headers,
      body: professor,
    );
  }
}

