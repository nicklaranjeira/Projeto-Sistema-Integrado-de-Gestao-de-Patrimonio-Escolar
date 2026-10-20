import 'package:get/get.dart';
import '../controller/professor_controlador.dart';

/// [ProfessorVinculacao] injeta o controlador para gerenciamento de docentes pelo coordenador.
///
/// Associada às rotas de professores (`/admin/professores`, `/admin/professores/novo`, `/admin/professores/detalhes`),
/// carrega sob demanda o [ProfessorControlador] para controlar listagem, cadastro, edição e consulta de docentes.
class ProfessorVinculacao extends Bindings {
  @override
  void dependencies() {
    // Injeta sob demanda o controlador de professores
    Get.lazyPut<ProfessorControlador>(() => ProfessorControlador());
  }
}

