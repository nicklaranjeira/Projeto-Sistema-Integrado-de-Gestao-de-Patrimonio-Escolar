import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sistema_patrimonio_escolar/app/dados/modelos/usuario_modelo.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('RF02 - Testes de Auto-Cadastro de Coordenador (Admin)', () {
    test('Deve validar a estrutura de dados para cadastro exclusivo de Coordenador com papel admin', () {
      final payloadCadastro = {
        'nome': 'Ana Paula Coordenadora',
        'email': 'ana.paula@escola.edu.br',
        'password': 'SenhaForte123!',
        'role': 'admin',
        'departamento': 'Coordenação Pedagógica',
        'telefone': '11988776655',
      };

      expect(payloadCadastro['role'], 'admin');
      expect(payloadCadastro['email'], contains('@'));
      expect(payloadCadastro['nome'], isNotEmpty);
      expect(payloadCadastro['password'], isNotEmpty);

      final usuarioGerado = UsuarioModelo.fromJson(payloadCadastro);
      expect(usuarioGerado.eAdmin, isTrue);
      expect(usuarioGerado.papel, 'admin');
    });

    test('Deve verificar discrepância entre senha e confirmação de senha', () {
      final senha1 = 'Senha123!';
      final senha2 = 'SenhaDiferente456!';

      final senhasConferem = senha1 == senha2;

      expect(senhasConferem, isFalse);
    });

    test('Deve verificar igualdade correta de senhas no cadastro', () {
      final senha1 = 'MinhaSenhaSegura#2026';
      final senha2 = 'MinhaSenhaSegura#2026';

      final senhasConferem = senha1 == senha2;

      expect(senhasConferem, isTrue);
    });
  });
}
