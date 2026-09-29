import 'package:get/get.dart';
import '../service/api_servico.dart';
import '../service/autenticacao_servico.dart';
import '../service/painel_servico.dart';
import '../service/patrimonio_servico.dart';
import '../service/professor_servico.dart';
import '../service/perfil_servico.dart';
import '../controller/autenticacao_controlador.dart';

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
