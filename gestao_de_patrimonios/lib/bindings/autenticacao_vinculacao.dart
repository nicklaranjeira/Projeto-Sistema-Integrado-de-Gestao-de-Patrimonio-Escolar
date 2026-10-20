import 'package:get/get.dart';
import '../controller/autenticacao_controlador.dart';

/// [AutenticacaoVinculacao] gerencia a injeção do controlador de autenticação nas rotas de login e cadastro.
///
/// Utiliza [Get.lazyPut] para instanciar o [AutenticacaoControlador] apenas quando a tela for acessada,
/// evitando consumo desnecessário de memória quando o usuário não estiver em fluxos de autenticação.
class AutenticacaoVinculacao extends Bindings {
  @override
  void dependencies() {
    // Instancia o controlador de autenticação sob demanda ao abrir a rota
    Get.lazyPut<AutenticacaoControlador>(() => AutenticacaoControlador());
  }
}

