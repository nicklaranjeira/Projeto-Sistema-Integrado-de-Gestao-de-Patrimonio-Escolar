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

  group('RF01 - Testes de Autenticação e Login Unificado', () {
    test('Deve criar UsuarioModelo com perfil de Administrador (Coordenador)', () {
      final jsonAdmin = {
        'id': 1,
        'nome': 'Coordenador Teste',
        'email': 'admin@escola.com',
        'role': 'admin',
        'departamento': 'Coordenação Geral',
        'token': 'jwt_token_admin_mock',
      };

      final usuario = UsuarioModelo.fromJson(jsonAdmin);

      expect(usuario.id, 1);
      expect(usuario.nome, 'Coordenador Teste');
      expect(usuario.email, 'admin@escola.com');
      expect(usuario.papel, 'admin');
      expect(usuario.eAdmin, isTrue);
      expect(usuario.eProfessor, isFalse);
      expect(usuario.token, 'jwt_token_admin_mock');
    });

    test('Deve criar UsuarioModelo com perfil de Docente (Professor)', () {
      final jsonProfessor = {
        'id': 2,
        'nome': 'Prof. Carlos Silva',
        'email': 'carlos@escola.com',
        'role': 'professor',
        'departamento': 'Ciências',
        'matricula': 'MAT-2026-001',
        'token': 'jwt_token_professor_mock',
      };

      final usuario = UsuarioModelo.fromJson(jsonProfessor);

      expect(usuario.id, 2);
      expect(usuario.nome, 'Prof. Carlos Silva');
      expect(usuario.email, 'carlos@escola.com');
      expect(usuario.papel, 'professor');
      expect(usuario.eProfessor, isTrue);
      expect(usuario.eAdmin, isFalse);
      expect(usuario.matricula, 'MAT-2026-001');
    });

    test('Deve validar cópia imutável com novo token de autenticação', () {
      final usuarioOriginal = UsuarioModelo(
        id: 1,
        nome: 'Usuario Original',
        email: 'user@escola.com',
        papel: 'admin',
      );

      final usuarioComToken = usuarioOriginal.copyWith(
        token: 'novo_token_jwt_valido',
        refreshToken: 'novo_refresh_token',
      );

      expect(usuarioComToken.token, 'novo_token_jwt_valido');
      expect(usuarioComToken.refreshToken, 'novo_refresh_token');
      expect(usuarioComToken.nome, usuarioOriginal.nome);
      expect(usuarioComToken.email, usuarioOriginal.email);
    });

    test('Deve serializar UsuarioModelo corretamente para JSON', () {
      final usuario = UsuarioModelo(
        id: 10,
        nome: 'Gestor Escolar',
        email: 'gestor@escola.com',
        papel: 'admin',
        departamento: 'Diretoria',
        telefone: '11999998888',
        matricula: 'DIR-01',
        token: 'token123',
        refreshToken: 'refresh123',
      );

      final json = usuario.toJson();

      expect(json['id'], 10);
      expect(json['nome'], 'Gestor Escolar');
      expect(json['email'], 'gestor@escola.com');
      expect(json['role'], 'admin');
      expect(json['departamento'], 'Diretoria');
      expect(json['telefone'], '11999998888');
      expect(json['matricula'], 'DIR-01');
      expect(json['token'], 'token123');
      expect(json['refresh_token'], 'refresh123');
    });
  });
}
