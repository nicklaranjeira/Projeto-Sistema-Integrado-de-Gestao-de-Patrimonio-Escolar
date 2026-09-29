import 'package:get/get.dart';
import '../services/api_servico.dart';
import '../services/armazenamento_servico.dart';
import '../services/autenticacao_servico.dart';
import '../services/painel_servico.dart';
import '../services/patrimonio_servico.dart';
import '../services/professor_servico.dart';
import '../services/perfil_servico.dart';
import '../controllers/autenticacao_controlador.dart';

class InicialVinculacao extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiServico>(ApiServico(), permanent: true);
    Get.put<AutenticacaoServico>(AutenticacaoServico(), permanent: true);
    Get.put<PatrimonioServico>(PatrimonioServico(), permanent: true);
    Get.put<ProfessorServico>(ProfessorServico(), permanent: true);
    Get.put<PerfilServico>(PerfilServico(), permanent: true);
    Get.put<PainelServico>(PainelServico(), permanent: true);

    Get.put<AutenticacaoControlador>(AutenticacaoControlador(), permanent: true);
  }
}
