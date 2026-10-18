import 'package:get/get.dart';
import '../bindings/autenticacao_vinculacao.dart';
import '../bindings/meus_patrimonios_vinculacao.dart';
import '../bindings/painel_vinculacao.dart';
import '../bindings/patrimonio_vinculacao.dart';
import '../bindings/perfil_vinculacao.dart';
import '../bindings/professor_vinculacao.dart';
import 'rotas_app.dart';
import '../view/autentificacao/login.dart';
import '../view/autentificacao/cadastro_cordenador.dart';
import '../view/autentificacao/esqueci_senha.dart';
import '../view/autentificacao/redefinir_senha.dart';
import '../view/autentificacao/validacao.dart';
import '../view/coordenador/painel_controle.dart';
import '../view/coordenador/patrimonios/gestao_patrimonios.dart';
import '../view/coordenador/patrimonios/formularios_patrimonios.dart';
import '../view/coordenador/patrimonios/detalhes_patrimonios.dart';
import '../view/coordenador/professores/gestao_professores.dart';
import '../view/coordenador/professores/formulario_professores.dart';
import '../view/coordenador/professores/detalhes_professores.dart';
import '../view/professor/meus_patrimonios.dart';
import '../view/perfil/perfil.dart';

class PaginasApp {
  static const INICIAL = RotasApp.LOGIN;

  static final rotas = [
    GetPage(
      name: RotasApp.LOGIN,
      page: () => const LoginView(),
      binding: AutenticacaoVinculacao(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RotasApp.CADASTRO,
      page: () => const CadastroCoordenadorView(),
      binding: AutenticacaoVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ESQUECI_SENHA,
      page: () => const EsqueciSenhaView(),
      binding: AutenticacaoVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.VALIDAR_CODIGO,
      page: () => const ValidacaoView(),
      binding: AutenticacaoVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.REDEFINIR_SENHA,
      page: () => const RedefinirSenhaView(),
      binding: AutenticacaoVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ADMIN_PAINEL,
      page: () => const PainelCoordenadorView(),
      binding: PainelVinculacao(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RotasApp.ADMIN_PATRIMONIOS,
      page: () => const GestaoPatrimoniosView(),
      binding: PatrimonioVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ADMIN_NOVO_PATRIMONIO,
      page: () => const FormularioPatrimonioView(),
      binding: PatrimonioVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ADMIN_DETALHES_PATRIMONIO,
      page: () => const DetalhesPatrimonioView(),
      binding: PatrimonioVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ADMIN_PROFESSORES,
      page: () => const GestaoProfessoresView(),
      binding: ProfessorVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ADMIN_NOVO_PROFESSOR,
      page: () => const FormularioProfessorView(),
      binding: ProfessorVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ADMIN_DETALHES_PROFESSOR,
      page: () => const DetalhesProfessorView(),
      binding: ProfessorVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.DOCENTE_MEUS_PATRIMONIOS,
      page: () => const MeusPatrimoniosView(),
      binding: MeusPatrimoniosVinculacao(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RotasApp.PERFIL,
      page: () => const PerfilView(),
      binding: PerfilVinculacao(),
      transition: Transition.rightToLeft,
    ),
  ];
}
