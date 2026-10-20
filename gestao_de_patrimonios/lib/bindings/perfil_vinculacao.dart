import 'package:get/get.dart';
import '../controller/perfil_controlador.dart';

/// [PerfilVinculacao] injeta o controlador da tela de perfil do usuário conectado.
///
/// Associada à rota `/perfil`, carrega o [PerfilControlador] para consulta e atualização
/// de dados cadastrais como nome, e-mail, telefone, departamento e senha.
class PerfilVinculacao extends Bindings {
  @override
  void dependencies() {
    // Injeta sob demanda o controlador de gerenciamento do perfil pessoal
    Get.lazyPut<PerfilControlador>(() => PerfilControlador());
  }
}

