import 'package:get/get.dart';
import '../service/api_servico.dart';
import '../service/autenticacao_servico.dart';
import '../service/painel_servico.dart';
import '../service/patrimonio_servico.dart';
import '../service/professor_servico.dart';
import '../service/perfil_servico.dart';
import '../controller/autenticacao_controlador.dart';

/// [InicialVinculacao] é a binding raiz do aplicativo, carregada no arranque em `main.dart`.
/// 
/// O método [dependencies] registra instâncias fundamentais de serviços e controladores
/// que precisam ficar acessíveis durante todo o ciclo de vida do aplicativo (`permanent: true`).
/// Dessa forma, o GetX não descarta essas dependências da memória mesmo ao navegar entre rotas.
class InicialVinculacao extends Bindings {
  @override
  void dependencies() {
    // Registra o cliente HTTP base responsável pela comunicação com a API REST
    Get.put<ApiServico>(ApiServico(), permanent: true);

    // Registra os serviços de dados e regras de integração com o backend
    Get.put<AutenticacaoServico>(AutenticacaoServico(), permanent: true);
    Get.put<PatrimonioServico>(PatrimonioServico(), permanent: true);
    Get.put<ProfessorServico>(ProfessorServico(), permanent: true);
    Get.put<PerfilServico>(PerfilServico(), permanent: true);
    Get.put<PainelServico>(PainelServico(), permanent: true);

    // Registra o controlador de autenticação de forma permanente para monitorar
    // a sessão, estado do login e usuário logado em qualquer parte do sistema
    Get.put<AutenticacaoControlador>(AutenticacaoControlador(), permanent: true);
  }
}

