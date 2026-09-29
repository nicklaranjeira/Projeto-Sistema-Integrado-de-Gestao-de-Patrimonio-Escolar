import 'package:get/get.dart';
import 'api_service.dart';
import '../models/user_model.dart';

/// Serviço que consome os endpoints de autenticação e recuperação de senha
class AuthService {
  final ApiService _api = Get.find<ApiService>();

  /// [POST] /api/auth/login - Login unificado (Admin e Professor)
  Future<Response> login(String email, String password) async {
    return await _api.post('/auth/login', {
      'email': email.trim(),
      'password': password,
    });
  }

  /// [POST] /api/auth/register - Auto-cadastro de Administrador (Coordenador)
  Future<Response> registerAdmin({
    required String nome,
    required String email,
    required String password,
    String? departamento,
    String? telefone,
  }) async {
    return await _api.post('/auth/register', {
      'nome': nome.trim(),
      'email': email.trim(),
      'password': password,
      'role': 'admin',
      if (departamento != null && departamento.isNotEmpty) 'departamento': departamento.trim(),
      if (telefone != null && telefone.isNotEmpty) 'telefone': telefone.trim(),
    });
  }

  /// [POST] /api/auth/refresh - Renovar JWT Access Token
  Future<Response> refreshToken(String refreshToken) async {
    return await _api.post('/auth/refresh', {
      'refresh_token': refreshToken,
    });
  }

  /// [POST] /api/auth/logout - Encerrar sessão
  Future<Response> logout() async {
    return await _api.post('/auth/logout', {});
  }

  /// [POST] /api/auth/forgot-password - Solicitar código de recuperação de 6 dígitos
  Future<Response> forgotPassword(String email) async {
    return await _api.post('/auth/forgot-password', {
      'email': email.trim(),
    });
  }

  /// [POST] /api/auth/verify-code - Validar código de confirmação de 6 dígitos
  Future<Response> verifyCode(String email, String code) async {
    return await _api.post('/auth/verify-code', {
      'email': email.trim(),
      'code': code.trim(),
    });
  }

  /// [POST] /api/auth/reset-password - Redefinir senha com o código validado
  Future<Response> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return await _api.post('/auth/reset-password', {
      'email': email.trim(),
      'code': code.trim(),
      'new_password': newPassword,
    });
  }
}
