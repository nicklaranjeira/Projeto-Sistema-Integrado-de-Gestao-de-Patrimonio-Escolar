import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../model/patrimonios.dart';
import '../model/atribuicoes.dart';
import '../model/devolucao.dart';

/// Service responsável pela comunicação com a API REST de Patrimônios.
/// Segue a arquitetura MVC + Service utilizando GetConnect do GetX.
class PatrimoniosService extends GetConnect {
  String? _customBaseUrl;

  PatrimoniosService({String? baseUrl, String? token}) {
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

  /// Configuração de URL base dinâmica, timeouts e headers
  void _configurar() {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      httpClient.baseUrl = _customBaseUrl;
    } else {
      // No Android Emulator usa 10.0.2.2. No Web, Desktop e iOS usa localhost
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

  /// Atualiza dinamicamente a URL base da API
  void atualizarBaseUrl(String novaUrl) {
    _customBaseUrl = novaUrl;
    httpClient.baseUrl = novaUrl;
  }

  /// Tenta a requisição no endpoint e faz fallback caso retorne 404
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
      final rotaAlt = endpoint.contains('/api/v1')
          ? endpoint.replaceFirst('/api/v1', '/api')
          : endpoint.replaceFirst('/api', '/api/v1');

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

  /// GET /api/patrimonios - Recupera a lista completa de patrimônios
  Future<Response<List<Patrimonios>>> listarPatrimonios() async {
    final response = await _requisicaoComFallback(
      metodo: 'GET',
      endpoint: '/api/patrimonios',
    );
    return _parseListResponse(response);
  }

  /// GET /api/patrimonios/meus - Recupera patrimônios atribuídos ao usuário logado
  Future<Response<List<Patrimonios>>> listarMeusPatrimonios() async {
    final response = await _requisicaoComFallback(
      metodo: 'GET',
      endpoint: '/api/patrimonios/meus',
    );
    return _parseListResponse(response);
  }

  /// GET /api/patrimonios?q={termo} - Pesquisa patrimônios por termo
  Future<Response<List<Patrimonios>>> pesquisarPatrimonios(String termo) async {
    final response = await _requisicaoComFallback(
      metodo: 'GET',
      endpoint: '/api/patrimonios',
      query: {'q': termo},
    );
    return _parseListResponse(response);
  }

  /// GET /api/patrimonios/{codigo} - Obtém os detalhes de um patrimônio
  Future<Response<Patrimonios>> buscarPorCodigo(String codigo) async {
    final response = await _requisicaoComFallback(
      metodo: 'GET',
      endpoint: '/api/patrimonios/$codigo',
    );
    return _parseSingleResponse(response);
  }

  /// Alias para obter detalhes
  Future<Response<Patrimonios>> obterPatrimonio(String codigo) =>
      buscarPorCodigo(codigo);

  /// POST /api/admin/patrimonios - Cadastra um novo patrimônio
  Future<Response<Patrimonios>> cadastrarPatrimonio(
    Patrimonios patrimonio,
  ) async {
    final response = await _requisicaoComFallback(
      metodo: 'POST',
      endpoint: '/api/admin/patrimonios',
      corpo: patrimonio.toJson(),
    );
    return _parseSingleResponse(response);
  }

  /// PUT /api/admin/patrimonios/{codigo} - Atualiza um patrimônio existente
  Future<Response<Patrimonios>> atualizarPatrimonio(
    String codigo,
    Patrimonios patrimonio,
  ) async {
    final response = await _requisicaoComFallback(
      metodo: 'PUT',
      endpoint: '/api/admin/patrimonios/$codigo',
      corpo: patrimonio.toJson(),
    );
    return _parseSingleResponse(response);
  }

  /// DELETE /api/admin/patrimonios/{codigo} - Remove um patrimônio
  Future<Response> excluirPatrimonio(String codigo) async {
    return await _requisicaoComFallback(
      metodo: 'DELETE',
      endpoint: '/api/admin/patrimonios/$codigo',
    );
  }

  /// POST /api/admin/patrimonios/{codigo}/atribuir - Vincula o patrimônio a um professor
  Future<Response> atribuirPatrimonio(
    String codigo,
    AtribuicaoPatrimonio atribuicao,
  ) async {
    final response = await _requisicaoComFallback(
      metodo: 'POST',
      endpoint: '/api/admin/patrimonios/$codigo/atribuir',
      corpo: atribuicao.toJson(),
    );
    return response;
  }

  /// POST /api/admin/patrimonios/{codigo}/devolver - Registra a devolução do patrimônio
  Future<Response> devolverPatrimonio(
    String codigo,
    DevolucaoPatrimonio devolucao,
  ) async {
    final response = await _requisicaoComFallback(
      metodo: 'POST',
      endpoint: '/api/admin/patrimonios/$codigo/devolver',
      corpo: devolucao.toJson(),
    );
    return response;
  }

  /// Decodifica respostas de lista tratando possíveis envelopes (ex: {"data": {"patrimonios": [...]}})
  Response<List<Patrimonios>> _parseListResponse(Response response) {
    if (!response.isOk || response.body == null) {
      return Response<List<Patrimonios>>(
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
      if (data is Map && data['patrimonios'] is List) {
        listaJson = data['patrimonios'] as List<dynamic>;
      } else if (data is List) {
        listaJson = data;
      } else if (body['patrimonios'] is List) {
        listaJson = body['patrimonios'] as List<dynamic>;
      }
    }

    final lista = <Patrimonios>[];
    if (listaJson != null) {
      for (final item in listaJson) {
        try {
          if (item is Map) {
            lista.add(Patrimonios.fromJson(Map<String, dynamic>.from(item)));
          }
        } catch (_) {}
      }
    }

    return Response<List<Patrimonios>>(
      statusCode: response.statusCode,
      statusText: response.statusText,
      headers: response.headers,
      body: lista,
    );
  }

  /// Decodifica resposta de único objeto tratando envelopes (ex: {"data": {...}})
  Response<Patrimonios> _parseSingleResponse(Response response) {
    if (!response.isOk || response.body == null) {
      return Response<Patrimonios>(
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

    Patrimonios? patrimonio;
    if (itemMap != null) {
      try {
        patrimonio = Patrimonios.fromJson(itemMap);
      } catch (_) {}
    }

    return Response<Patrimonios>(
      statusCode: response.statusCode,
      statusText: response.statusText,
      headers: response.headers,
      body: patrimonio,
    );
  }
}

/// Alias para manter compatibilidade com nomes alternativos
typedef PatrimoniosApi = PatrimoniosService;
typedef PatrimonioService = PatrimoniosService;

