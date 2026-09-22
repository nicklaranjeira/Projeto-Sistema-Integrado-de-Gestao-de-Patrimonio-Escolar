import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../model/patrimonios.dart';
import '../model/atribuicoes.dart';
import '../model/devolucao.dart';

/// Service responsável pela comunicação com a API REST de Patrimônios.
/// Segue a arquitetura MVC + Service utilizando GetConnect do GetX.
class PatrimoniosService extends GetConnect {
  String? _customBaseUrl;

  PatrimoniosService({String? baseUrl}) {
    _customBaseUrl = baseUrl;
    _configurar();
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

  /// Atualiza dinamicamente a URL base da API
  void atualizarBaseUrl(String novaUrl) {
    _customBaseUrl = novaUrl;
    httpClient.baseUrl = novaUrl;
  }

  /// Tenta a requisição na rota principal (/api/v1/...) e, se der 404, faz fallback para rota sem prefixo
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

  /// GET /api/v1/patrimonios - Recupera a lista completa de patrimônios
  Future<Response<List<Patrimonios>>> listarPatrimonios() async {
    final response = await _requisicaoComFallback(
      metodo: 'GET',
      rotaPrincipal: '/api/v1/patrimonios',
    );
    return _parseListResponse(response);
  }

  /// GET /api/v1/patrimonios?q={termo} - Pesquisa patrimônios por termo
  Future<Response<List<Patrimonios>>> pesquisarPatrimonios(String termo) async {
    final response = await _requisicaoComFallback(
      metodo: 'GET',
      rotaPrincipal: '/api/v1/patrimonios',
      query: {'q': termo},
    );
    return _parseListResponse(response);
  }

  /// GET /api/v1/patrimonios/{codigo} - Obtém os detalhes de um patrimônio
  Future<Response<Patrimonios>> buscarPorCodigo(String codigo) async {
    final response = await _requisicaoComFallback(
      metodo: 'GET',
      rotaPrincipal: '/api/v1/patrimonios/$codigo',
    );
    return _parseSingleResponse(response);
  }

  /// Alias para obter detalhes
  Future<Response<Patrimonios>> obterPatrimonio(String codigo) =>
      buscarPorCodigo(codigo);

  /// POST /api/v1/patrimonios - Cadastra um novo patrimônio
  Future<Response<Patrimonios>> cadastrarPatrimonio(
    Patrimonios patrimonio,
  ) async {
    final response = await _requisicaoComFallback(
      metodo: 'POST',
      rotaPrincipal: '/api/v1/patrimonios',
      corpo: patrimonio.toJson(),
    );
    return _parseSingleResponse(response);
  }

  /// PUT /api/v1/patrimonios/{codigo} - Atualiza um patrimônio existente
  Future<Response<Patrimonios>> atualizarPatrimonio(
    String codigo,
    Patrimonios patrimonio,
  ) async {
    final response = await _requisicaoComFallback(
      metodo: 'PUT',
      rotaPrincipal: '/api/v1/patrimonios/$codigo',
      corpo: patrimonio.toJson(),
    );
    return _parseSingleResponse(response);
  }

  /// DELETE /api/v1/patrimonios/{codigo} - Remove um patrimônio
  Future<Response> excluirPatrimonio(String codigo) async {
    return await _requisicaoComFallback(
      metodo: 'DELETE',
      rotaPrincipal: '/api/v1/patrimonios/$codigo',
    );
  }

  /// POST /api/v1/patrimonios/{codigo}/atribuir - Vincula o patrimônio a um professor
  Future<Response> atribuirPatrimonio(
    String codigo,
    AtribuicaoPatrimonio atribuicao,
  ) async {
    return await _requisicaoComFallback(
      metodo: 'POST',
      rotaPrincipal: '/api/v1/patrimonios/$codigo/atribuir',
      corpo: atribuicao.toJson(),
    );
  }

  /// POST /api/v1/patrimonios/{codigo}/devolver - Registra a devolução do patrimônio
  Future<Response> devolverPatrimonio(
    String codigo,
    DevolucaoPatrimonio devolucao,
  ) async {
    return await _requisicaoComFallback(
      metodo: 'POST',
      rotaPrincipal: '/api/v1/patrimonios/$codigo/devolver',
      corpo: devolucao.toJson(),
    );
  }

  /// Decodifica respostas de lista tratando possíveis envelopes (ex: {"data": {"patrimonios": [...]}})
  Response<List<Patrimonios>> _parseListResponse(Response response) {
    if (!response.isOk || response.body == null) {
      return Response<List<Patrimonios>>(
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
      if (body['data'] is Map && body['data']['patrimonios'] is List) {
        listaJson = body['data']['patrimonios'] as List<dynamic>;
      } else if (body['data'] is List) {
        listaJson = body['data'] as List<dynamic>;
      } else if (body['patrimonios'] is List) {
        listaJson = body['patrimonios'] as List<dynamic>;
      }
    }

    final lista = listaJson
            ?.map((item) =>
                Patrimonios.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList() ??
        [];

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

    Patrimonios? patrimonio;
    if (itemMap != null) {
      patrimonio = Patrimonios.fromJson(itemMap);
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
