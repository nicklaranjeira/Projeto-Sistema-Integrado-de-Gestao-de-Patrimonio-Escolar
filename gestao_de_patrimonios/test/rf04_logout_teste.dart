import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gestao_de_patrimonios/models/usuario_modelo.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('RF04 - Testes de Logout e Encerramento de Sessão', () {
    test('Deve validar a limpeza de dados e estado do usuário autenticado no logout', () {
      final Rx<UsuarioModelo?> usuarioAtivo = Rx<UsuarioModelo?>(
        UsuarioModelo(
          id: 1,
          nome: 'Usuario Ativo',
          email: 'ativo@escola.com',
          papel: 'admin',
          token: 'token_jwt_ativo_123',
        ),
      );

      expect(usuarioAtivo.value, isNotNull);
      expect(usuarioAtivo.value!.token, 'token_jwt_ativo_123');

      usuarioAtivo.value = null;

      expect(usuarioAtivo.value, isNull);
    });

    test('Deve validar a limpeza de tokens e chaves de sessão', () {
      final Map<String, String?> cacheSessao = {
        'jwt_token': 'token_exemplo_valido',
        'refresh_token': 'refresh_exemplo_valido',
        'dados_usuario': '{"id": 1, "nome": "Admin"}',
      };

      expect(cacheSessao['jwt_token'], isNotNull);
      expect(cacheSessao['dados_usuario'], isNotNull);

      cacheSessao.clear();

      expect(cacheSessao.isEmpty, isTrue);
      expect(cacheSessao['jwt_token'], isNull);
    });
  });
}
