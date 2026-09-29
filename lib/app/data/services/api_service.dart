import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'storage_service.dart';

/// Cliente HTTP Base construído com GetConnect
/// Gerencia baseUrl, interceptors de cabeçalho Bearer Token e tratamento unificado de erros
class ApiService extends GetConnect {
  final StorageService _storage = Get.find<StorageService>();

  @override
  void onInit() {
    httpClient.baseUrl = _storage.getBaseUrl();
    httpClient.timeout = const Duration(seconds: 15);

    // Request Interceptor: Anexa o Bearer Token nas rotas protegidas
    httpClient.addRequestModifier<dynamic>((Request request) {
      final token = _storage.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      return request;
    });

    // Response Interceptor: Trata expiração de token e erros globais
    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {
        // Sessão expirada ou inválida
        // Pode acionar refresh token ou logout
      }
      return response;
    });

    super.onInit();
  }

  /// Extrai mensagem de erro amigável da resposta do backend
  String handleError(Response response) {
    if (response.hasError) {
      try {
        final body = response.body;
        if (body is Map && body['message'] != null) {
          return body['message'].toString();
        } else if (body is Map && body['error'] != null) {
          return body['error'].toString();
        } else if (body is String && body.isNotEmpty) {
          final decoded = jsonDecode(body);
          if (decoded is Map && decoded['message'] != null) {
            return decoded['message'].toString();
          }
        }
      } catch (_) {}

      switch (response.statusCode) {
        case 400:
          return 'Dados inválidos enviados. Verifique os campos.';
        case 401:
          return 'Não autorizado. Faça login novamente.';
        case 403:
          return 'Acesso negado: você não tem permissão para realizar esta ação.';
        case 404:
          return 'Recurso não encontrado.';
        case 409:
          return 'Conflito de dados (ex: e-mail ou tombamento já cadastrado).';
        case 500:
          return 'Erro interno do servidor. Tente novamente mais tarde.';
        default:
          return response.statusText ?? 'Falha na comunicação com o servidor.';
      }
    }
    return 'Erro desconhecido.';
  }
}
