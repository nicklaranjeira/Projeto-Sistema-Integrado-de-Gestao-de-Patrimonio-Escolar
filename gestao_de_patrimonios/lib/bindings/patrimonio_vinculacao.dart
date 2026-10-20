import 'package:get/get.dart';
import '../controller/patrimonio_controlador.dart';
import '../controller/professor_controlador.dart';

/// [PatrimonioVinculacao] injeta os controladores necessários para o gerenciamento de patrimônios.
///
/// É utilizada nas rotas de listagem, cadastro e detalhes de patrimônios:
/// - Injeta [PatrimonioControlador] para o CRUD, filtros e movimentações de bens.
/// - Injeta [ProfessorControlador] porque os formulários de cadastro e alocação precisam
///   listar os professores disponíveis para seleção.
class PatrimonioVinculacao extends Bindings {
  @override
  void dependencies() {
    // Injeta sob demanda o controlador de bens patrimoniais
    Get.lazyPut<PatrimonioControlador>(() => PatrimonioControlador());

    // Injeta sob demanda o controlador de professores para seleção nos formulários de alocação
    Get.lazyPut<ProfessorControlador>(() => ProfessorControlador());
  }
}

