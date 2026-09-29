import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/dashboard_service.dart';
import '../data/services/patrimonio_service.dart';
import '../data/services/professor_service.dart';
import '../data/services/profile_service.dart';
import '../data/services/storage_service.dart';
import '../controllers/auth_controller.dart';

/// Binding inicial que registra serviços e dependências globais permanentes
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Serviços Globais (Singleton)
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<PatrimonioService>(PatrimonioService(), permanent: true);
    Get.put<ProfessorService>(ProfessorService(), permanent: true);
    Get.put<ProfileService>(ProfileService(), permanent: true);
    Get.put<DashboardService>(DashboardService(), permanent: true);

    // AuthController permanente para controle global de sessão
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
