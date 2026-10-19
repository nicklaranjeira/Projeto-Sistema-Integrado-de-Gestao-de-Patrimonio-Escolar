import 'dart:convert';

/// Utilitário para decodificação e inspeção de tokens JWT (RFC 7519).
/// Permite extrair o papel (role), usuário e validade diretamente do payload Base64Url
/// emitido pela API backend em Go (api.exe), sem necessidade de chave secreta no cliente.
class JwtServico {
  /// Decodifica o payload (claims) contido no token JWT
  static Map<String, dynamic> decodificarClaims(String token) {
    try {
      final partes = token.split('.');
      if (partes.length < 2) return {};

      String payload = partes[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final bytes = base64Decode(payload);
      final jsonString = utf8.decode(bytes);
      final dados = jsonDecode(jsonString);
      return dados is Map<String, dynamic>
          ? dados
          : Map<String, dynamic>.from(dados as Map);
    } catch (_) {
      return {};
    }
  }

  /// Extrai o papel de acesso (role/papel) do usuário a partir das claims do JWT.
  /// Retorna 'admin' (coordenador) ou 'docente' (professor).
  static String extrairRole(String token) {
    final claims = decodificarClaims(token);
    final role = claims['role'] ?? claims['papel'] ?? claims['user_role'] ?? claims['perfil'];
    if (role != null) return role.toString().toLowerCase();

    // Fallback caso a claim esteja aninhada no objeto 'user'
    if (claims['user'] is Map) {
      final userRole = claims['user']['role'] ?? claims['user']['papel'];
      if (userRole != null) return userRole.toString().toLowerCase();
    }
    return 'docente';
  }

  /// Verifica se o token confere privilégios de Administrador / Coordenador
  static bool ehAdmin(String token) {
    final role = extrairRole(token);
    return role == 'admin' || role == 'coordenador';
  }

  /// Verifica se o token confere privilégios de Professor / Docente
  static bool ehDocente(String token) {
    final role = extrairRole(token);
    return role == 'docente' || role == 'professor';
  }

  /// Valida se o token JWT ainda se encontra dentro do período de validade (claim 'exp')
  static bool estaExpirado(String token) {
    final claims = decodificarClaims(token);
    final exp = claims['exp'];
    if (exp is int) {
      final dataExpiracao = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(dataExpiracao);
    }
    return false;
  }

  /// Gera um token JWT formatado para testes e modo de demonstração local
  static String gerarTokenDemonstracao({
    required String email,
    required String papel,
    required String nome,
    int? userId,
  }) {
    final header = base64Url.encode(utf8.encode(jsonEncode({
      'alg': 'HS256',
      'typ': 'JWT',
    }))).replaceAll('=', '');

    final payload = base64Url.encode(utf8.encode(jsonEncode({
      'sub': userId?.toString() ?? '1',
      'user_id': userId ?? 1,
      'email': email,
      'name': nome,
      'nome': nome,
      'role': papel == 'coordenador' ? 'admin' : (papel == 'professor' ? 'docente' : papel),
      'papel': papel == 'coordenador' ? 'admin' : (papel == 'professor' ? 'docente' : papel),
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 86400,
    }))).replaceAll('=', '');

    final signature = base64Url.encode(utf8.encode('assinatura_valida_api_mock')).replaceAll('=', '');

    return '$header.$payload.$signature';
  }
}
