import 'package:get/get.dart';
import 'api_service.dart';

/// Serviço para consulta e atualização de perfil do usuário logado (Admin e Professor)
class ProfileService {
  final ApiService _api = Get.find<ApiService>();

  /// [GET] /api/profile - Consultar perfil autenticado
  Future<Response> getProfile() async {
    return await _api.get('/profile');
  }

  /// [PUT] /api/profile - Atualizar dados do perfil e/ou alterar senha
  Future<Response> updateProfile({
    String? telefone,
    String? departamento,
    String? currentPassword,
    String? newPassword,
  }) async {
    final Map<String, dynamic> body = {};
    if (telefone != null) body['telefone'] = telefone.trim();
    if (departamento != null) body['departamento'] = departamento.trim();
    if (currentPassword != null && currentPassword.isNotEmpty) {
      body['current_password'] = currentPassword;
    }
    if (newPassword != null && newPassword.isNotEmpty) {
      body['new_password'] = newPassword;
    }

    return await _api.put('/profile', body);
  }
}
