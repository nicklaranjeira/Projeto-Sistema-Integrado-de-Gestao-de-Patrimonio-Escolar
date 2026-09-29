import 'package:get/get.dart';
import 'api_servico.dart';

class AutenticacaoServico {
  final ApiServico _api = Get.find<ApiServico>();

  Future<Response> login(String email, String senha) async {
    return await _api.post('/auth/login', {
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
    return await _api.post('/auth/register', {
      'nome': nome.trim(),
      'email': email.trim(),
      'password': senha,
      'role': 'admin',
      if (departamento != null && departamento.isNotEmpty) 'departamento': departamento.trim(),
      if (telefone != null && telefone.isNotEmpty) 'telefone': telefone.trim(),
    });
  }

  Future<Response> renovarToken(String refreshToken) async {
    return await _api.post('/auth/refresh', {
      'refresh_token': refreshToken,
    });
  }

  Future<Response> encerrarSessao() async {
    return await _api.post('/auth/logout', {});
  }

  Future<Response> solicitarRecuperacaoSenha(String email) async {
    return await _api.post('/auth/forgot-password', {
      'email': email.trim(),
    });
  }

  Future<Response> validarCodigoRecuperacao(String email, String codigo) async {
    return await _api.post('/auth/verify-code', {
      'email': email.trim(),
      'code': codigo.trim(),
    });
  }

  Future<Response> redefinirSenha({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {
    return await _api.post('/auth/reset-password', {
      'email': email.trim(),
      'code': codigo.trim(),
      'new_password': novaSenha,
    });
  }
}
