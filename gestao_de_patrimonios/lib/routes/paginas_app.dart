import 'package:flutter/material.dart';
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
      page: () => const _VisualizacaoTemporaria(titulo: 'Login'),
      binding: AutenticacaoVinculacao(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RotasApp.CADASTRO,
      page: () => const _VisualizacaoTemporaria(titulo: 'Cadastro de Coordenador'),
      binding: AutenticacaoVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ESQUECI_SENHA,
      page: () => const _VisualizacaoTemporaria(titulo: 'Recuperação de Senha'),
      binding: AutenticacaoVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.VALIDAR_CODIGO,
      page: () => const _VisualizacaoTemporaria(titulo: 'Validação de Código'),
      binding: AutenticacaoVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.REDEFINIR_SENHA,
      page: () => const _VisualizacaoTemporaria(titulo: 'Redefinição de Senha'),
      binding: AutenticacaoVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ADMIN_PAINEL,
      page: () => const _VisualizacaoTemporaria(titulo: 'Painel do Coordenador'),
      binding: PainelVinculacao(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RotasApp.ADMIN_PATRIMONIOS,
      page: () => const _VisualizacaoTemporaria(titulo: 'Gestão de Patrimônios'),
      binding: PatrimonioVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ADMIN_NOVO_PATRIMONIO,
      page: () => const _VisualizacaoTemporaria(titulo: 'Cadastrar Patrimônio'),
      binding: PatrimonioVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ADMIN_DETALHES_PATRIMONIO,
      page: () => const _VisualizacaoTemporaria(titulo: 'Detalhes do Patrimônio e Histórico'),
      binding: PatrimonioVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ADMIN_PROFESSORES,
      page: () => const _VisualizacaoTemporaria(titulo: 'Gestão de Professores'),
      binding: ProfessorVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ADMIN_NOVO_PROFESSOR,
      page: () => const _VisualizacaoTemporaria(titulo: 'Cadastrar Professor'),
      binding: ProfessorVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.ADMIN_DETALHES_PROFESSOR,
      page: () => const _VisualizacaoTemporaria(titulo: 'Detalhes do Professor'),
      binding: ProfessorVinculacao(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RotasApp.DOCENTE_MEUS_PATRIMONIOS,
      page: () => const _VisualizacaoTemporaria(titulo: 'Meus Patrimônios'),
      binding: MeusPatrimoniosVinculacao(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RotasApp.PERFIL,
      page: () => const _VisualizacaoTemporaria(titulo: 'Meu Perfil'),
      binding: PerfilVinculacao(),
      transition: Transition.rightToLeft,
    ),
  ];
}

class _VisualizacaoTemporaria extends StatelessWidget {
  final String titulo;
  const _VisualizacaoTemporaria({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Text('Tela: $titulo'),
      ),
    );
  }
}
