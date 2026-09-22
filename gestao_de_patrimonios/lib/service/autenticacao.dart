import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../model/autentificacao.dart';
import '../model/redefinição_de_senha.dart';

/// Service responsável pela comunicação com os endpoints de autenticação e recuperação de senha.
class AutenticacaoService extends GetConnect {
  String? _customBaseUrl;

  AutenticacaoService({String? baseUrl}) {
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

  /// POST /api/v1/auth/login ou /auth/login - Realiza login
  Future<Response> login(Login dados) async {
    final res = await post('/api/v1/auth/login', dados.toJson());
    if (res.statusCode == 404) {
      return await post('/auth/login', dados.toJson());
    }
    return res;
  }

  /// POST /api/v1/auth/refresh ou /auth/refresh - Renova o token de acesso
  Future<Response> renovarToken(RenovarToken dados) async {
    final res = await post('/api/v1/auth/refresh', dados.toJson());
    if (res.statusCode == 404) {
      return await post('/auth/refresh', dados.toJson());
    }
    return res;
  }

  /// POST /api/v1/auth/logout ou /auth/logout - Encerra a sessão ativa
  Future<Response> encerrarSessao(EncerrarSessao dados) async {
    final res = await post('/api/v1/auth/logout', dados.toJson());
    if (res.statusCode == 404) {
      return await post('/auth/logout', dados.toJson());
    }
    return res;
  }

  /// POST /api/v1/auth/forgot-password - Solicita envio de código de recuperação de senha
  Future<Response> solicitarRecuperacaoSenha(ForgotPassword dados) async {
    final res = await post('/api/v1/auth/forgot-password', dados.toJson());
    if (res.statusCode == 404) {
      return await post('/auth/forgot-password', dados.toJson());
    }
    return res;
  }

  /// POST /api/v1/auth/verify-code - Verifica código de validação
  Future<Response> verificarCodigo(VerifyCode dados) async {
    final res = await post('/api/v1/auth/verify-code', dados.toJson());
    if (res.statusCode == 404) {
      return await post('/auth/verify-code', dados.toJson());
    }
    return res;
  }

  /// POST /api/v1/auth/reset-password - Redefine a senha do usuário
  Future<Response> redefinirSenha(ResetPassword dados) async {
    final res = await post('/api/v1/auth/reset-password', dados.toJson());
    if (res.statusCode == 404) {
      return await post('/auth/reset-password', dados.toJson());
    }
    return res;
  }
}
