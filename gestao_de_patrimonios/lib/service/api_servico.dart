import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'armazenamento_servico.dart';

class ApiServico extends GetConnect {
  late final ArmazenamentoServico _armazenamento;

  static String obterUrlPadrao() {
    if (kIsWeb) return 'http://localhost:8081';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8081';
    return 'http://localhost:8081';
  }

  @override
  void onInit() {
    super.onInit();
    _armazenamento = Get.find<ArmazenamentoServico>();

    httpClient.baseUrl = obterUrlPadrao();
    httpClient.timeout = const Duration(seconds: 15);

    httpClient.addRequestModifier<dynamic>((request) {
      final token = _armazenamento.obterToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {
        _armazenamento.limparTudo();
      }
      return response;
    });
  }

  String tratarErro(Response resposta) {
    if (resposta.status.connectionError) {
      return 'Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.';
    }

    if (resposta.body != null) {
      if (resposta.body is Map) {
        final corpo = resposta.body as Map;
        if (corpo.containsKey('error') && corpo['error'] != null) {
          return corpo['error'].toString();
        }
        if (corpo.containsKey('message') && corpo['message'] != null) {
          return corpo['message'].toString();
        }
        if (corpo.containsKey('mensagem') && corpo['mensagem'] != null) {
          return corpo['mensagem'].toString();
        }
      }
      if (resposta.body is String && (resposta.body as String).isNotEmpty) {
        return resposta.body as String;
      }
    }

    switch (resposta.statusCode) {
      case 400:
        return 'Requisição inválida. Verifique os dados enviados.';
      case 401:
        return 'Sessão expirada ou credenciais inválidas. Faça login novamente.';
      case 403:
        return 'Acesso negado. Você não tem permissão para realizar esta ação.';
      case 404:
        return 'Recurso não encontrado.';
      case 409:
        return 'Conflito com registro existente (e-mail, tombo ou matrícula já cadastrados).';
      case 422:
        return 'Erro de validação nos dados fornecidos.';
      case 500:
        return 'Erro interno do servidor. Tente novamente mais tarde.';
      default:
        return 'Ocorreu um erro inesperado (${resposta.statusCode ?? "sem código"}).';
    }
  }
}
