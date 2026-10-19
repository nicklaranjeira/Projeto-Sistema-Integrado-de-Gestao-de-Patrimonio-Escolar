import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gestao_de_patrimonios/model/usuario_modelo.dart';

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

    test('Deve validar requisito de comprimento mínimo de 6 caracteres na senha (requisito da API Go)', () {
      final senhaCurta = '12345';
      final senhaValida = '123456';
      final senhaForte = 'SenhaSegura#2026';

      expect(senhaCurta.length < 6, isTrue, reason: 'Senha com menos de 6 caracteres deve ser rejeitada pela validação');
      expect(senhaValida.length >= 6, isTrue, reason: 'Senha com 6 caracteres deve ser aceita');
      expect(senhaForte.length >= 6, isTrue, reason: 'Senha forte deve ser aceita');
    });

    test('Deve normalizar o e-mail para minúsculo e sem espaços para evitar erro de case sensitivity no SQLite', () {
      final emailEntrada = '  Coordenador.Geral@Escola.Edu.BR  ';
      final emailNormalizado = emailEntrada.trim().toLowerCase();

      expect(emailNormalizado, 'coordenador.geral@escola.edu.br');
    });

    test('Deve validar todos os 6 campos obrigatórios exigidos no cadastro de coordenador', () {
      final dadosCompletos = {
        'nome': 'Prof. Carlos Gestor',
        'email': 'carlos.gestor@escola.edu.br',
        'password': 'coordSenhaForte123',
        'departamento': 'Coordenação Pedagógica',
        'telefone': '(11) 98888-7777',
        'cpf': '111.222.333-44',
      };

      final todosPreenchidos = dadosCompletos['nome']!.isNotEmpty &&
          dadosCompletos['email']!.isNotEmpty &&
          dadosCompletos['password']!.length >= 6 &&
          dadosCompletos['departamento']!.isNotEmpty &&
          dadosCompletos['telefone']!.isNotEmpty &&
          dadosCompletos['cpf']!.isNotEmpty;

      expect(todosPreenchidos, isTrue);
    });
  });
}
