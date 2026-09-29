import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../model/autentificacao.dart';
import '../model/redefinicao_de_senha.dart';

class AutenticacaoService extends GetConnect {
  String? _customBaseUrl;

  AutenticacaoService({String? baseUrl, String? token}) {
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
      final host = (GetPlatform.isAndroid && !kIsWeb)
          ? '10.0.2.2'
          : 'localhost';
      httpClient.baseUrl = 'http://$host:8000';
    }

    httpClient.timeout = const Duration(seconds: 10);
    httpClient.defaultContentType = 'application/json';
  }

  void definirToken(String token) {
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Authorization'] = 'Bearer $token';
      return request;
    });
  }

  Future<Response> _postComFallback(String endpoint, dynamic dados) async {
    Response res = await post(endpoint, dados);
    if (res.statusCode == 404) {
      final rotaAlt = endpoint.replaceFirst('/api/', '/api/v1/');
      res = await post(rotaAlt, dados);
      if (res.statusCode == 404) {
        final rotaSemPrefixo = endpoint.replaceFirst('/api', '');
        res = await post(rotaSemPrefixo, dados);
      }
    }
    return res;
  }

  Future<Response> cadastrarAdmin(Map<String, dynamic> dados) async {
    return await _postComFallback('/api/auth/register', dados);
  }

  Future<Response> login(Login dados) async {
    return await _postComFallback('/api/auth/login', dados.toJson());
  }

  Future<Response> renovarToken(RenovarToken dados) async {
    return await _postComFallback('/api/auth/refresh', dados.toJson());
  }

  Future<Response> encerrarSessao(EncerrarSessao dados) async {
    return await _postComFallback('/api/auth/logout', dados.toJson());
  }

  Future<Response> solicitarRecuperacaoSenha(ForgotPassword dados) async {
    return await _postComFallback('/api/auth/forgot-password', dados.toJson());
  }

  Future<Response> verificarCodigo(VerifyCode dados) async {
    return await _postComFallback('/api/auth/verify-code', dados.toJson());
  }

  Future<Response> redefinirSenha(ResetPassword dados) async {
    return await _postComFallback('/api/auth/reset-password', dados.toJson());
  }
}
