import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bindings/auth_binding.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/meus_patrimonios_binding.dart';
import '../bindings/patrimonio_binding.dart';
import '../bindings/professor_binding.dart';
import '../bindings/profile_binding.dart';
import 'app_routes.dart';

/// Mapeamento central de Páginas, Rotas, Transições e Bindings do Sistema
class AppPages {
  static const INITIAL = AppRoutes.LOGIN;

  static final routes = [
    // ---------------------------------------------------------------------------
    // Módulo 1: Autenticação e Sessão
    // ---------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const _PlaceholderView(title: 'Login Unificado'),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const _PlaceholderView(title: 'Cadastro de Coordenador'),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const _PlaceholderView(title: 'Recuperação de Senha'),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.VERIFY_CODE,
      page: () => const _PlaceholderView(title: 'Validação de Código'),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.RESET_PASSWORD,
      page: () => const _PlaceholderView(title: 'Redefinição de Senha'),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),

    // ---------------------------------------------------------------------------
    // Módulo 2: Painel do Coordenador (Admin)
    // ---------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.ADMIN_DASHBOARD,
      page: () => const _PlaceholderView(title: 'Dashboard do Coordenador'),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.ADMIN_PATRIMONIOS,
      page: () => const _PlaceholderView(title: 'Gestão de Patrimônios'),
      binding: PatrimonioBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ADMIN_NOVO_PATRIMONIO,
      page: () => const _PlaceholderView(title: 'Cadastrar Patrimônio'),
      binding: PatrimonioBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ADMIN_DETALHES_PATRIMONIO,
      page: () => const _PlaceholderView(title: 'Detalhes do Patrimônio & Histórico'),
      binding: PatrimonioBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ADMIN_PROFESSORES,
      page: () => const _PlaceholderView(title: 'Gestão de Professores'),
      binding: ProfessorBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ADMIN_NOVO_PROFESSOR,
      page: () => const _PlaceholderView(title: 'Cadastrar Professor'),
      binding: ProfessorBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ADMIN_DETALHES_PROFESSOR,
      page: () => const _PlaceholderView(title: 'Bens sob Tutela do Professor'),
      binding: ProfessorBinding(),
      transition: Transition.rightToLeft,
    ),

    // ---------------------------------------------------------------------------
    // Módulo 3: Painel do Professor (Docente)
    // ---------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.DOCENTE_MEUS_PATRIMONIOS,
      page: () => const _PlaceholderView(title: 'Meus Patrimônios (Leitura)'),
      binding: MeusPatrimoniosBinding(),
      transition: Transition.fadeIn,
    ),

    // ---------------------------------------------------------------------------
    // Perfil e Configurações de Conta
    // ---------------------------------------------------------------------------
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const _PlaceholderView(title: 'Meu Perfil'),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}

/// Widget temporário de visualização enquanto as Views definitivas são integradas pela equipe
class _PlaceholderView extends StatelessWidget {
  final String title;
  const _PlaceholderView({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Tela: $title\n(Aguardando composição da View)'),
      ),
    );
  }
}
