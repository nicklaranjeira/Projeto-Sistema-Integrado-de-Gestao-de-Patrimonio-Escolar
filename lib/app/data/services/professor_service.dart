import 'package:get/get.dart';
import 'api_service.dart';

/// Serviço exclusivo do Coordenador para gestão de professores
class ProfessorService {
  final ApiService _api = Get.find<ApiService>();

  /// [GET] /api/admin/professores - Listar professores e quantidade de bens (Exclusivo Admin)
  Future<Response> getProfessores() async {
    return await _api.get('/admin/professores');
  }

  /// [POST] /api/admin/professores - Cadastrar professor com senha provisória (Exclusivo Admin)
  Future<Response> createProfessor({
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

  /// [GET] /api/admin/professores/{id} - Ver professor e seus bens atribuídos (Exclusivo Admin)
  Future<Response> getProfessorById(int id) async {
    return await _api.get('/admin/professores/$id');
  }
}
