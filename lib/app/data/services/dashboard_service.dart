import 'package:get/get.dart';
import 'api_service.dart';

/// Serviço para obter métricas, indicadores e estatísticas gerais (Admin)
class DashboardService {
  final ApiService _api = Get.find<ApiService>();

  /// [GET] /api/admin/stats - Métricas gerais de usuários, patrimônios e sessões
  Future<Response> getStats() async {
    return await _api.get('/admin/stats');
  }

  /// [GET] /api/health - Health check da API
  Future<Response> checkHealth() async {
    return await _api.get('/health');
  }
}
