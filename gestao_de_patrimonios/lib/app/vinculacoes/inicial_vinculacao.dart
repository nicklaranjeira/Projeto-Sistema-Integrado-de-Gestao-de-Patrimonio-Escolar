import 'package:get/get.dart';
import '../dados/servicos/api_servico.dart';
import '../dados/servicos/armazenamento_servico.dart';
import '../dados/servicos/autenticacao_servico.dart';
import '../dados/servicos/painel_servico.dart';
import '../dados/servicos/patrimonio_servico.dart';
import '../dados/servicos/professor_servico.dart';
import '../dados/servicos/perfil_servico.dart';
import '../controladores/autenticacao_controlador.dart';

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
