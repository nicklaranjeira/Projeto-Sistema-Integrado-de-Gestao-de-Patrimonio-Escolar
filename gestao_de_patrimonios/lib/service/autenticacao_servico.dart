import 'package:get/get.dart';
import 'api_servico.dart';

class AutenticacaoServico extends GetxService {
  final ApiServico _api = Get.find<ApiServico>();

  Future<Response> login(String email, String senha) async {
    return await _api.post('/api/auth/login', {
      'email': email.trim(),
      'password': senha,
    });
  }

  Future<Response> cadastrarCoordenador({
    required String nome,
    required String email,
    required String senha,
    String? departamento,
    String? telefone,
  }) async {
    return await _api.post('/api/auth/register', {
      'name': nome.trim(),
      'nome': nome.trim(),
      'email': email.trim(),
      'password': senha,
      'departamento': departamento?.trim(),
      'telefone': telefone?.trim(),
      'role': 'admin',
      'papel': 'admin',
    });
  }

  Future<Response> solicitarRecuperacaoSenha(String email) async {
    return await _api.post('/api/auth/forgot-password', {
      'email': email.trim(),
    });
  }

  Future<Response> validarCodigoRecuperacao(String email, String codigo) async {
    return await _api.post('/api/auth/verify-code', {
      'email': email.trim(),
      'code': codigo.trim(),
    });
  }

  Future<Response> redefinirSenha({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {
    return await _api.post('/api/auth/reset-password', {
      'email': email.trim(),
      'code': codigo.trim(),
      'new_password': novaSenha,
      'password': novaSenha,
    });
  }

  Future<Response> renovarToken(String refreshToken) async {
    return await _api.post('/api/auth/refresh', {
      'refresh_token': refreshToken,
    });
  }

  Future<Response> encerrarSessao() async {
    return await _api.post('/api/auth/logout', {});
  }
}
