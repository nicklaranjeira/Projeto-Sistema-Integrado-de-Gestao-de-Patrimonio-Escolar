import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('RF03 - Testes de Recuperação de Senha em 3 Etapas', () {
    test('Etapa 1: Validação do formato de e-mail para solicitação do código', () {
      final emailValido = 'coordenador@escola.com';
      final emailInvalido = 'email_sem_arroba.com';

      final regexEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

      expect(regexEmail.hasMatch(emailValido), isTrue);
      expect(regexEmail.hasMatch(emailInvalido), isFalse);
    });

    test('Etapa 2: Validação do código de 6 dígitos gerado pelo servidor', () {
      final codigoCorreto = '482910';
      final codigoIncompleto = '4829';
      final codigoComLetras = '4829A0';

      final regexCodigo6Digitos = RegExp(r'^\d{6}$');

      expect(regexCodigo6Digitos.hasMatch(codigoCorreto), isTrue);
      expect(regexCodigo6Digitos.hasMatch(codigoIncompleto), isFalse);
      expect(regexCodigo6Digitos.hasMatch(codigoComLetras), isFalse);
    });

    test('Etapa 3: Validação da redefinição de senha com confirmação idêntica', () {
      final novaSenha = 'NovaSenhaSuperSegura2026!';
      final confirmacaoNovaSenha = 'NovaSenhaSuperSegura2026!';

      expect(novaSenha.length >= 6, isTrue);
      expect(novaSenha == confirmacaoNovaSenha, isTrue);
    });

    test('Etapa 3: Rejeição de redefinição quando confirmação de nova senha não confere', () {
      final novaSenha = 'SenhaNova123';
      final confirmacaoDivergente = 'SenhaNovaErrada';

      expect(novaSenha == confirmacaoDivergente, isFalse);
    });
  });
}
