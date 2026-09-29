/// Constantes de Rotas Nomeadas do Sistema
abstract class AppRoutes {
  static const INITIAL = '/';
  
  // Módulo 1: Autenticação e Recuperação de Senha
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const VERIFY_CODE = '/verify-code';
  static const RESET_PASSWORD = '/reset-password';

  // Módulo 2: Painel do Coordenador (Admin)
  static const ADMIN_DASHBOARD = '/admin/dashboard';
  static const ADMIN_PATRIMONIOS = '/admin/patrimonios';
  static const ADMIN_NOVO_PATRIMONIO = '/admin/patrimonios/novo';
  static const ADMIN_EDITAR_PATRIMONIO = '/admin/patrimonios/editar';
  static const ADMIN_DETALHES_PATRIMONIO = '/admin/patrimonios/detalhes';
  static const ADMIN_PROFESSORES = '/admin/professores';
  static const ADMIN_NOVO_PROFESSOR = '/admin/professores/novo';
  static const ADMIN_DETALHES_PROFESSOR = '/admin/professores/detalhes';

  // Módulo 3: Painel do Professor (Docente)
  static const DOCENTE_MEUS_PATRIMONIOS = '/docente/meus-patrimonios';

  // Perfil e Configurações (Comum a Admin e Docente)
  static const PROFILE = '/profile';
  static const EDITAR_PERFIL = '/profile/editar';
  static const ALTERAR_SENHA = '/profile/alterar-senha';
}
