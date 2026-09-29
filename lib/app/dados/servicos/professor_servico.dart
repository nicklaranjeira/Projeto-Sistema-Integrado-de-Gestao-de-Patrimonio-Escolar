import 'package:get/get.dart';
import 'api_servico.dart';

class ProfessorServico {
  final ApiServico _api = Get.find<ApiServico>();

  Future<Response> obterProfessores() async {
    return await _api.get('/admin/professores');
  }

  Future<Response> cadastrarProfessor({
    required String nome,
    required String email,
    required String matricula,
    required String departamento,
    String? telefone,
    required String senhaProvisoria,
  }) async {
    return await _api.post('/admin/professores', {
      'nome': nome.trim(),
      'email': email.trim(),
      'matricula': matricula.trim(),
      'departamento': departamento.trim(),
      if (telefone != null && telefone.isNotEmpty) 'telefone': telefone.trim(),
      'senha_provisoria': senhaProvisoria,
    });
  }

  Future<Response> obterProfessorPorId(int id) async {
    return await _api.get('/admin/professores/$id');
  }
}
