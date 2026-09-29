import 'package:get/get.dart';
import 'api_servico.dart';

class PerfilServico {
  final ApiServico _api = Get.find<ApiServico>();

  Future<Response> obterPerfil() async {
    return await _api.get('/profile');
  }

  Future<Response> atualizarPerfil({
    String? telefone,
    String? departamento,
    String? senhaAtual,
    String? novaSenha,
  }) async {
    final Map<String, dynamic> corpo = {};
    if (telefone != null) corpo['telefone'] = telefone.trim();
    if (departamento != null) corpo['departamento'] = departamento.trim();
    if (senhaAtual != null && senhaAtual.isNotEmpty) {
      corpo['current_password'] = senhaAtual;
    }
    if (novaSenha != null && novaSenha.isNotEmpty) {
      corpo['new_password'] = novaSenha;
    }

    return await _api.put('/profile', corpo);
  }
}
