import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'armazenamento_servico.dart';

class ApiServico extends GetConnect {
  final ArmazenamentoServico _armazenamento = Get.find<ArmazenamentoServico>();

  @override
  void onInit() {
    httpClient.baseUrl = _armazenamento.obterUrlBase();
    httpClient.timeout = const Duration(seconds: 15);

    httpClient.addRequestModifier<dynamic>((Request request) {
      final token = _armazenamento.obterToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      return request;
    });

    super.onInit();
  }

  String tratarErro(Response resposta) {
    if (resposta.hasError) {
      try {
        final corpo = resposta.body;
        if (corpo is Map && corpo['message'] != null) {
          return corpo['message'].toString();
        } else if (corpo is Map && corpo['error'] != null) {
          return corpo['error'].toString();
        } else if (corpo is String && corpo.isNotEmpty) {
          final decodificado = jsonDecode(corpo);
          if (decodificado is Map && decodificado['message'] != null) {
            return decodificado['message'].toString();
          }
        }
      } catch (_) {}

      switch (resposta.statusCode) {
        case 400:
          return 'Dados inválidos enviados. Verifique os campos preenchidos.';
        case 401:
          return 'Sessão expirada ou não autorizada. Faça login novamente.';
        case 403:
          return 'Acesso negado: você não possui permissão para realizar esta ação.';
        case 404:
          return 'Registro não encontrado no servidor.';
        case 409:
          return 'Conflito de dados. Verifique se as informações já existem.';
        case 500:
          return 'Erro interno do servidor. Tente novamente mais tarde.';
        default:
          return resposta.statusText ?? 'Falha na comunicação com o servidor.';
      }
    }
    return 'Erro desconhecido.';
  }
}
