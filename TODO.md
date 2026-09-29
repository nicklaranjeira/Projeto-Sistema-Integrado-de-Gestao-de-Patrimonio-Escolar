# Checklist de Requisitos e Tarefas (TODO.md)

Este documento detalha o status de implementação do **Sistema Integrado de Gestão de Patrimônio Escolar**, comparando os requisitos especificados com o código entregue e apontando as etapas pendentes para a finalização do projeto.

---

## 1. Status Geral dos Requisitos

| Requisito | Descrição | Camada de Controle & Lógica | Interface / View (Telas) | Status Geral |
| :--- | :--- | :---: | :---: | :---: |
| **[RF01]** | Tela de Login unificado (Admin e Docente) | Concluído (`AutenticacaoControlador`) | Pendente (Composição visual dos widgets) | **Em Andamento** |
| **[RF02]** | Auto-Cadastro de Coordenador (Admin) | Concluído (`AutenticacaoControlador`) | Pendente (Composição visual dos widgets) | **Em Andamento** |
| **[RF03]** | Recuperação de Senha em 3 etapas | Concluído (`AutenticacaoControlador`) | Pendente (Composição visual dos widgets) | **Em Andamento** |
| **[RF04]** | Logout e limpeza de sessão local | Concluído (`AutenticacaoControlador`) | Concluído (Lógica e redirecionamento) | **Concluído** |
| **[RF05]** | Dashboard com Indicadores do Coordenador | Concluído (`PainelControlador`) | Pendente (Cards e gráficos visuais) | **Em Andamento** |
| **[RF06]** | Gestão de Professores e Bens Vinculados | Concluído (`ProfessorControlador`) | Pendente (Listagem e formulário visual) | **Em Andamento** |
| **[RF07]** | Gestão de Patrimônios (CRUD, Atribuição, Devolução, Histórico) | Concluído (`PatrimonioControlador`) | Pendente (Listagem, filtros e modais visuais) | **Em Andamento** |
| **[RF08]** | Meus Patrimônios (Visão Estrita de Leitura do Docente) | Concluído (`MeusPatrimoniosControlador`) | Pendente (Cards informativos de leitura) | **Em Andamento** |
| **[RF09]** | Perfil do Usuário e Atualização Cadastral | Concluído (`PerfilControlador`) | Pendente (Formulários visuais de edição) | **Em Andamento** |

---

## 2. O Que Já Foi Concluído (Entregue e Funcionando)

### Camada de Arquitetura, Controle e Negócio (`gestao_de_patrimonios/lib/`)
- [x] **Configuração do Projeto (`gestao_de_patrimonios/pubspec.yaml`):** Configurado com `get` (GetX), `get_storage` (persistência local) e `http`.
- [x] **Modelos de Dados (`gestao_de_patrimonios/lib/model/`):**
  - [x] `usuario_modelo.dart` (dados do usuário, perfil `ehAdministrador` / `ehDocente`, JWT e Refresh Token).
  - [x] `patrimonio_modelo.dart` (dados completos do bem, status `disponivel`/`alocado`/`manutencao`/`baixado`, tombo, série e professor responsável).
  - [x] `professor_modelo.dart` (matrícula, departamento, telefone, status `ativo`/`inativo` e contagem de bens).
  - [x] `historico_movimentacao_modelo.dart` (rastreabilidade, tipo de movimentação, professor e observações).
  - [x] `estatisticas_painel_modelo.dart` (métricas consolidadas para os cards do dashboard).
  - [x] Modelos complementares: `atribuicoes.dart`, `autentificacao.dart`, `cordenadores.dart`, `devolucao.dart`, `patrimonios.dart`, `professores.dart`, `redefinicao_de_senha.dart`.
- [x] **Camada de Serviços e Integração HTTP (`gestao_de_patrimonios/lib/service/`):**
  - [x] `armazenamento_servico.dart` (gerenciamento e persistência de sessão e tokens via `GetStorage`).
  - [x] `api_servico.dart` (cliente centralizado `GetConnect`, interceptores para inclusão do cabeçalho `Authorization: Bearer <token>`, tratamento de status HTTP 400, 401, 403, 404, 409, 500 e URLs dinâmicas para Android Emulator `10.0.2.2:8081` vs Desktop `localhost:8081`).
  - [x] `autenticacao_servico.dart` (endpoints de login, cadastro de coordenador, solicitação de código, validação de código, redefinição de senha, refresh e logout).
  - [x] `painel_servico.dart` (endpoint de métricas do dashboard `/api/dashboard/stats`).
  - [x] `patrimonio_servico.dart` (endpoints de listagem, busca, criação, edição, atribuição, devolução, histórico e desativação).
  - [x] `professor_servico.dart` (endpoints de listagem, busca, cadastro, alteração de status e bens sob tutela).
  - [x] `perfil_servico.dart` (endpoints de consulta e atualização de perfil do usuário logado).
- [x] **Controladores do Sistema (`gestao_de_patrimonios/lib/controller/`):**
  - [x] `autenticacao_controlador.dart` (gerenciamento completo dos fluxos de login, cadastro de coordenador, recuperação em 3 passos, logout e redirecionamento inteligente por papel).
  - [x] `painel_controlador.dart` (carregamento reativo das métricas do painel e atalhos de navegação).
  - [x] `patrimonio_controlador.dart` (listagem, filtros por status/categoria, busca textual, salvar/editar bem, modal de alocação para docente, modal de devolução com motivo e histórico).
  - [x] `professor_controlador.dart` (listagem de docentes, filtros, cadastro de professor com senha provisória, alteração de status e listagem de bens sob tutela).
  - [x] `meus_patrimonios_controlador.dart` (visão estrita de leitura do professor logado, respeitando estritamente a regra `[RN03]`).
  - [x] `perfil_controlador.dart` (carregamento e atualização dos dados cadastrais do perfil).
- [x] **Injeção de Dependências (`gestao_de_patrimonios/lib/bindings/`):**
  - [x] `inicial_vinculacao.dart` (injeção singleton de todos os serviços de API e armazenamento na inicialização).
  - [x] Vinculações específicas por fluxo: `autenticacao_vinculacao.dart`, `painel_vinculacao.dart`, `patrimonio_vinculacao.dart`, `professor_vinculacao.dart`, `meus_patrimonios_vinculacao.dart`, `perfil_vinculacao.dart`.
- [x] **Roteamento Centralizado (`gestao_de_patrimonios/lib/routes/`):**
  - [x] `rotas_app.dart` (definição de constantes de rotas para todas as telas do sistema).
  - [x] `paginas_app.dart` (mapeamento completo com transições GetX e vinculações associadas).
- [x] **Testes Automatizados (`gestao_de_patrimonios/test/`):**
  - [x] `rf01_login_teste.dart` a `rf09_gerenciamento_perfil_teste.dart` cobrindo todos os requisitos funcionais.
  - [x] `service_test.dart` e `widget_test.dart`.
- [x] **Governança do Código:**
  - [x] 100% dos comentários removidos do código Dart.
  - [x] Arquivos e identificadores nomeados em português.
  - [x] Eliminação de todas as pastas e arquivos duplicados do repositório.

---

## 3. O Que Falta Fazer (Próximos Passos)

### Fase 1: Telas Visuais (Views Definitivas em `gestao_de_patrimonios/lib/view/`)
- [ ] **Módulo de Autenticação:**
  - [ ] Tela de Login com campos de e-mail e senha, botão de login e links para "Cadastrar Coordenador" e "Esqueci minha senha" conectados ao `AutenticacaoControlador`.
  - [ ] Tela de Cadastro de Coordenador com validação de senha e formulário completo.
  - [ ] Telas de Recuperação de Senha:
    - [ ] Solicitar código (campo de e-mail).
    - [ ] Validar código (campo para os 6 dígitos).
    - [ ] Redefinir senha (campos de nova senha e confirmação).
- [ ] **Módulo do Coordenador (Administrador):**
  - [ ] Tela de Dashboard (`painel_visao.dart`) exibindo cards reativos com totais de bens, alocados, disponíveis, em manutenção e atalhos rápidos.
  - [ ] Tela de Gestão de Patrimônios (`patrimonios_visao.dart`) com barra de pesquisa, chips de filtro por status e categoria, e botão flutuante de novo patrimônio.
  - [ ] Modal/Tela de Formulário para cadastro e edição de patrimônio.
  - [ ] Modal de Atribuição (seleção de docente ativo para alocação).
  - [ ] Modal de Devolução (campo obrigatório de motivo/observações).
  - [ ] Tela/Aba de Detalhes do Patrimônio com exibição da linha do tempo/histórico de movimentações.
  - [ ] Tela de Gestão de Professores (`professores_visao.dart`) com listagem, busca e formulário de cadastro com senha provisória.
  - [ ] Tela de Detalhes do Professor com listagem dos itens sob sua responsabilidade.
- [ ] **Módulo do Professor (Docente):**
  - [ ] Tela "Meus Patrimônios" (`meus_patrimonios_visao.dart`) com listagem em cards informativos de leitura (tombamento, descrição, categoria, localização) sem botões de alteração/exclusão.
- [ ] **Módulo de Perfil:**
  - [ ] Tela de visualização e edição de dados cadastrais (`perfil_visao.dart`).

---

### Fase 2: Componentes Reutilizáveis (Design System)
- [ ] Criar componentes visuais padronizados na pasta `view/` ou `widgets/`:
  - [ ] `campo_texto_personalizado.dart` (inputs com ícones e validação).
  - [ ] `botao_primario.dart` (botão com feedback de carregamento).
  - [ ] `card_patrimonio.dart` (card com badge colorido por status).
  - [ ] `badge_status.dart` (verde para `disponivel`, azul para `alocado`, amarelo/laranja para `manutencao`, cinza/vermelho para `baixado`).

---

### Fase 3: Validação de Integração com o Backend Local
- [ ] Executar o binário `api.exe` na porta 8081.
- [ ] Executar o aplicativo Flutter (`flutter run`) e realizar o fluxo completo de teste de ponta a ponta:
  1. Auto-cadastro de Coordenador.
  2. Login como Coordenador.
  3. Cadastro de Docente com senha provisória.
  4. Cadastro de novo Patrimônio.
  5. Atribuição do Patrimônio ao Docente cadastrado.
  6. Login como Docente e conferência do bem na tela "Meus Patrimônios".
  7. Devolução do Patrimônio como Coordenador com registro de motivo.
  8. Verificação do histórico de movimentações atualizado.
