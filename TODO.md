# Checklist de Requisitos e Tarefas (TODO.md)

Este documento detalha o status de implementação do **Sistema Integrado de Gestão de Patrimônio Escolar**, comparando os requisitos especificados com o código entregue e apontando as etapas pendentes para a finalização do projeto.

---

## 1. Status Geral dos Requisitos

| Requisito | Descrição | Camada de Controle & Lógica | Interface / View (Telas) | Status Geral |
| :--- | :--- | :---: | :---: | :---: |
| **[RF01]** | Tela de Login unificado (Admin e Docente) | Concluído (`AutenticacaoControlador`) | Pendente (Composição visual) | **Em Andamento** |
| **[RF02]** | Auto-Cadastro de Coordenador (Admin) | Concluído (`AutenticacaoControlador`) | Pendente (Composição visual) | **Em Andamento** |
| **[RF03]** | Recuperação de Senha em 3 etapas | Concluído (`AutenticacaoControlador`) | Pendente (Composição visual) | **Em Andamento** |
| **[RF04]** | Logout e limpeza de sessão local | Concluído (`AutenticacaoControlador`) | Concluído (Ação nos controladores) | **Concluído** |
| **[RF05]** | Dashboard com Indicadores do Coordenador | Concluído (`PainelControlador`) | Pendente (Cards/Gráficos) | **Em Andamento** |
| **[RF06]** | Gestão de Professores e Bens Vinculados | Concluído (`ProfessorControlador`) | Pendente (Listagem/Formulário) | **Em Andamento** |
| **[RF07]** | Gestão de Patrimônios (CRUD, Atribuição, Devolução, Histórico) | Concluído (`PatrimonioControlador`) | Pendente (Listagem/Filtros/Modais) | **Em Andamento** |
| **[RF08]** | Meus Patrimônios (Visão Estrita de Leitura do Docente) | Concluído (`MeusPatrimoniosControlador`) | Pendente (Cards Informativos) | **Em Andamento** |
| **[RF09]** | Perfil do Usuário e Alteração de Senha | Concluído (`PerfilControlador`) | Pendente (Formulários de Edição) | **Em Andamento** |

---

## 2. O Que Já Foi Concluído (Entregue)

### Camada de Arquitetura e Controle (Backend Integration)
- [x] **Configuração de Dependências (`pubspec.yaml`):** Inclusão do `get` (GetX), `get_storage` (persistência de sessão) e `http`.
- [x] **Modelos de Dados (`lib/app/dados/modelos/`):**
  - [x] `usuario_modelo.dart` (dados do usuário, token JWT e verificação de perfil `eAdmin` / `eProfessor`).
  - [x] `patrimonio_modelo.dart` (dados completos do bem material, status e vinculação a docentes).
  - [x] `professor_modelo.dart` (dados do docente e contagem de bens).
  - [x] `historico_movimentacao_modelo.dart` (linha do tempo e rastreabilidade de movimentações).
  - [x] `estatisticas_painel_modelo.dart` (indicadores consolidados para o dashboard).
- [x] **Camada de Serviços e Rede (`lib/app/dados/servicos/`):**
  - [x] `armazenamento_servico.dart` (gravação e recuperação segura de JWT, Refresh Token e dados do usuário logado via `GetStorage`).
  - [x] `api_servico.dart` (cliente HTTP centralizado com `GetConnect`, interceptor do cabeçalho `Authorization: Bearer <token>` e mapeamento de mensagens amigáveis de erro HTTP 400, 401, 403, 404, 500).
  - [x] `autenticacao_servico.dart` (login, cadastro, refresh, logout e recuperação de senha).
  - [x] `patrimonio_servico.dart` (listagem, filtros, criação, edição, exclusão, atribuição, devolução e histórico).
  - [x] `professor_servico.dart` (listagem, cadastro centralizado com senha provisória e detalhes).
  - [x] `perfil_servico.dart` (consulta e atualização cadastral e de senha).
  - [x] `painel_servico.dart` (indicadores e health check).
- [x] **Controladores do Sistema (`lib/app/controladores/`):**
  - [x] `autenticacao_controlador.dart` (fluxos completos de autenticação, validações, redirecionamento condicional por perfil e recuperação em 3 passos).
  - [x] `painel_controlador.dart` (obtenção reativa de métricas e atalhos de navegação).
  - [x] `patrimonio_controlador.dart` (gestão completa de inventário, busca textual em tempo real, filtros de status/categoria, atribuição, devolução e histórico).
  - [x] `professor_controlador.dart` (cadastro de docente com senha provisória e consulta de bens sob tutela).
  - [x] `meus_patrimonios_controlador.dart` (visão somente leitura do professor, sem ações de mutação para respeito estrito à regra `[RN03]`).
  - [x] `perfil_controlador.dart` (atualização de telefone, departamento e troca de senha).
- [x] **Injeção de Dependências (`lib/app/vinculacoes/`):** Criação das vinculações (`Bindings`) para carregamento sob demanda dos controladores e inicialização singleton de serviços globais no `inicial_vinculacao.dart`.
- [x] **Roteamento Centralizado (`lib/app/rotas/`):** Definição das rotas nomeadas (`rotas_app.dart`) e mapeamento de páginas com transições fluidas (`paginas_app.dart`).
- [x] **Inicialização da Aplicação (`lib/main.dart`):** Configuração do `GetMaterialApp` e injeção do armazenamento persistente na inicialização.
- [x] **Testes Unitários Automatizados (`test/`):**
  - [x] `rf01_login_teste.dart` (validação de credenciais, perfil admin/docente, imutabilidade e parsing).
  - [x] `rf02_cadastro_coordenador_teste.dart` (validação de campos de coordenador e confirmação de senha).
  - [x] `rf03_recuperacao_senha_teste.dart` (fluxo em 3 etapas com código de 6 dígitos e nova senha).
  - [x] `rf04_logout_teste.dart` (limpeza de estado de autenticação e cache de sessão).
  - [x] `rf05_dashboard_indicadores_teste.dart` (desserialização e consistência matemática dos indicadores).
  - [x] `rf06_gestao_professores_teste.dart` (gestão de docentes, contagem e bens sob tutela).
  - [x] `rf07_gestao_patrimonios_teste.dart` (CRUD, filtros, fluxo de atribuição, devolução e histórico).
  - [x] `rf08_meus_patrimonios_teste.dart` (visão estrita de leitura e busca de bens do professor).
  - [x] `rf09_gerenciamento_perfil_teste.dart` (atualização cadastral e alteração de senha autenticada).

---

## 3. O Que Falta Fazer (Próximos Passos)

### Fase 1: Construção das Telas e Componentes Visuais (Views)
- [ ] **Módulo 1 - Autenticação (`lib/app/visoes/autenticacao/`):**
  - [ ] Tela de Login com campos de e-mail, senha com alternador de visibilidade e botão de entrar conectado ao `AutenticacaoControlador.login()`.
  - [ ] Tela de Auto-Cadastro de Coordenador (`cadastro_visao.dart`).
  - [ ] Telas do fluxo de recuperação de senha:
    - [ ] `esqueci_senha_visao.dart` (solicitar código).
    - [ ] `validar_codigo_visao.dart` (inserir código de 6 dígitos).
    - [ ] `redefinir_senha_visao.dart` (digitar e confirmar nova senha).
- [ ] **Módulo 2 - Painel do Coordenador (`lib/app/visoes/painel/` e `lib/app/visoes/patrimonios/`):**
  - [ ] Tela do Dashboard com cards de indicadores reativos (`Obx` ouvindo `PainelControlador.estatisticas`).
  - [ ] Tela de listagem de patrimônios com barra de busca, chips de filtro por status/categoria e botão flutuante para novo cadastro.
  - [ ] Tela/Modal de cadastro e edição de patrimônio.
  - [ ] Tela de detalhes do patrimônio com exibição da linha do tempo/histórico de movimentações.
  - [ ] Modais de ação:
    - [ ] Modal de **Atribuição** (selecionar professor da lista).
    - [ ] Modal de **Devolução** (campo de texto obrigatório para o motivo).
  - [ ] Tela de listagem de professores com indicador de bens vinculados.
  - [ ] Tela de cadastro de novo professor com campo para senha provisória.
  - [ ] Tela de detalhes do professor com a lista dos equipamentos sob sua responsabilidade.
- [ ] **Módulo 3 - Painel do Professor (`lib/app/visoes/docente/`):**
  - [ ] Tela "Meus Patrimônios" com listagem em cards informativos (tombamento, descrição, categoria, marca, data de atribuição e localização).
  - [ ] Modal/Sheet para leitura detalhada do bem selecionado (sem botões de alteração/exclusão).
- [ ] **Módulo 4 - Perfil (`lib/app/visoes/perfil/`):**
  - [ ] Tela de visualização e edição de perfil (telefone e departamento).
  - [ ] Modal/Formulário de alteração de senha (senha atual, nova senha e confirmação).

---

### Fase 2: Componentização e Design System Reutilizável
- [ ] Criar pasta `lib/app/componentes/` (ou `widgets/`):
  - [ ] `campo_texto_personalizado.dart` (inputs com validação e ícones padronizados).
  - [ ] `botao_primario.dart` (botão com feedback de `carregando` automático).
  - [ ] `card_patrimonio.dart` (card reutilizável para listagens de bens com badge de status colorido).
  - [ ] `badge_status.dart` (etiqueta visual para `disponivel` verde, `em_uso` azul e `em_manutencao` laranja).
  - [ ] `estado_vazio.dart` (componente amigável para listas vazias).
  - [ ] `indicador_carregando.dart` (shimmer ou spinner personalizado).

---

### Fase 3: Protótipo de Alta Fidelidade e Governança no GitHub
- [ ] **Protótipo de Design no Figma:**
  - [ ] Desenhar telas de Coordenador e Professor conforme o fluxo planejado.
  - [ ] Exportar pranchetas ou gerar links para apresentação.
- [ ] **Histórico de Commits e Pull Requests:**
  - [ ] Divisão das telas entre os integrantes da equipe.
  - [ ] Envio das contribuições individuais por meio de branches e Pull Requests revisados.
- [ ] **Testes de Integração com o Backend Local:**
  - [ ] Executar o binário `api.exe` e validar todas as chamadas HTTP (Login, Atribuição, Devolução, Cadastro de Docente e Histórico).

---

## 4. Checklist para a Arguição Presencial

- [ ] Saber explicar o ciclo de dados: `View (Obx)` $\leftrightarrow$ `Controller (GetxController)` $\leftrightarrow$ `Service (GetConnect)` $\leftrightarrow$ `Backend Go (API)`.
- [ ] Demonstrar onde e como o token JWT é persistido e enviado automaticamente no cabeçalho `Authorization: Bearer <token>`.
- [ ] Explicar a regra **[RN03]** e mostrar como o `MeusPatrimoniosControlador` é estritamente de leitura.
- [ ] Demonstrar o fluxo de **Atribuição** (status vai para `em_uso`) e **Devolução** (status retorna para `disponivel` com motivo).
- [ ] Demonstrar a recuperação de senha com o código de 6 dígitos gerado pelo backend.
