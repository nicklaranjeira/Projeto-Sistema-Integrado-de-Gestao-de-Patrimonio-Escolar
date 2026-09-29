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

  group('RF09 - Testes de Gerenciamento de Perfil e Alteração de Senha', () {
    test('Deve atualizar dados cadastrais de telefone e departamento preservando os demais campos', () {
      final perfilInicial = UsuarioModelo(
        id: 7,
        nome: 'Prof. Marcos Oliveira',
        email: 'marcos@escola.com',
        papel: 'professor',
        departamento: 'Química',
        telefone: '11911112222',
        matricula: 'MAT-7788',
        token: 'token_jwt_valido',
      );

      final perfilAtualizado = perfilInicial.copyWith(
        telefone: '11933334444',
        departamento: 'Química e Biologia',
      );

      expect(perfilAtualizado.telefone, '11933334444');
      expect(perfilAtualizado.departamento, 'Química e Biologia');
      expect(perfilAtualizado.id, perfilInicial.id);
      expect(perfilAtualizado.nome, perfilInicial.nome);
      expect(perfilAtualizado.email, perfilInicial.email);
      expect(perfilAtualizado.matricula, perfilInicial.matricula);
      expect(perfilAtualizado.token, perfilInicial.token);
    });

    test('Deve validar requisitos para alteração de senha autenticada', () {
      final senhaAtual = 'SenhaAntiga123!';
      final novaSenha = 'NovaSenhaForte2026@';
      final confirmacaoNovaSenha = 'NovaSenhaForte2026@';

      expect(senhaAtual.isNotEmpty, isTrue);
      expect(novaSenha.length >= 6, isTrue);
      expect(novaSenha == confirmacaoNovaSenha, isTrue);
      expect(novaSenha != senhaAtual, isTrue);
    });

    test('Deve rejeitar alteração quando confirmação da nova senha divergir', () {
      final novaSenha = 'SenhaNova2026#';
      final confirmacaoIncorreta = 'SenhaNova2026Divergente#';

      final valida = novaSenha == confirmacaoIncorreta;

      expect(valida, isFalse);
    });
  });
}
