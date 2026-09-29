Filter by tag
Autenticação
Fluxo de auto-cadastro do Administrador, login unificado (Admin e Professor), renovação de token e logout.



POST
/api/auth/register
Auto-cadastro de Administrador (Coordenador)



POST
/api/auth/login
Login unificado (Admin e Professor)



POST
/api/auth/refresh
Renovar JWT Access Token



POST
/api/auth/logout
Encerrar sessão (Logout)


Patrimônios Escolares
Consulta e gestão de bens materiais escolares. O professor tem permissão APENAS DE LEITURA e vê somente seus bens. O Admin possui gestão total.


Gestão de Professores (Admin)
Rotas exclusivas do Coordenador/Admin para cadastrar docentes e acompanhar a quantidade de patrimônios vinculados a cada um.



GET
/api/admin/professores
Listar professores e quantidade de bens (Exclusivo Admin)




POST
/api/admin/professores
Cadastrar professor no sistema (Exclusivo Admin)




GET
/api/admin/professores/{id}
Ver professor e seus bens atribuídos (Exclusivo Admin)



Perfil
Consulta e atualização cadastral do usuário logado (Admin ou Professor). Permite alterar telefone, departamento e trocar a senha.



GET
/api/profile
Consultar perfil autenticado




PUT
/api/profile
Atualizar dados do perfil e/ou alterar senha



Recuperação de Senha
Redefinição de senha com código aleatório de 6 dígitos gerado e impresso no console do servidor.



POST
/api/auth/forgot-password
Solicitar código de recuperação de senha



POST
/api/auth/verify-code
Validar código de confirmação de 6 dígitos



POST
/api/auth/reset-password
Redefinir senha com o código de confirmação


Administração Geral
Gestão de usuários, alteração de permissões e métricas gerais do sistema (Exclusivo Admin).



GET
/api/admin/users
Listar todos os usuários do sistema (Exclusivo Admin)




PATCH
/api/admin/users/{id}/role
Alterar papel do usuário (admin / professor / user)




GET
/api/admin/stats
Métricas gerais de usuários e sessões

Sistema
Health check e integridade do servidor.

GET
/api/health
Health Check da API

## 1. Visão Geral do Projeto

A instituição de ensino demandou o desenvolvimento de uma solução **Mobile** oficial para a gestão e acompanhamento de seus patrimônios escolares.

O **Backend** da aplicação já se encontra implementado em **Go (Golang)**, oferecendo uma API REST robusta, documentada via **Swagger/OpenAPI** e pronta para consumo por meio do binário executável fornecido (`api.exe`).

A missão da equipe é projetar e construir o **aplicativo móvel em Flutter**, integrando-o aos serviços da API e respeitando os padrões de engenharia de software, a arquitetura recomendada e as regras de negócio do domínio escolar.

---

## 2. Diretrizes Técnicas e Padrões de Projeto

Para garantir manutenibilidade, desacoplamento e escalabilidade do aplicativo móvel, a equipe deverá estruturar o projeto sob as seguintes diretrizes:

- **Framework:** **Flutter** (Dart).
- **Padrão Arquitetural:** **MVC (Model - View - Controller)**.
- **Gerenciamento de Estado, Dependências e Rotas:**
    - Gerenciamento de estado reativo (ex.: GetX ou equivalente abordado em aula).
    - Navegação nomeada e transições de tela estruturadas.
    - Injeção de dependências desacoplada da interface.
- **Padrão de Projeto - Componentização:**
    - Decomposição da interface em **Widgets modulares e reutilizáveis** (botões personalizados, cards de patrimônio, badges de status, inputs padronizados), evitando repetição de código.

---

## 3. Atores do Sistema e Níveis de Acesso (RBAC)

O sistema possui dois perfis operacionais com responsabilidades distintas:

```
                            ┌────────────────────────────────────┐
                            │        SISTEMA DE PATRIMÔNIO       │
                            └────────────────────────────────────┘
                                               │
                      ┌────────────────────────┴────────────────────────┐
                      ▼                                                 ▼
       ┌─────────────────────────────┐                   ┌─────────────────────────────┐
       │   COORDENADOR (ADMIN)       │                   │    PROFESSOR (DOCENTE)      │
       ├─────────────────────────────┤                   ├─────────────────────────────┤
       │ • Cadastro da instituição   │                   │ • Cadastrado pelo admin     │
       │ • Gestão de docentes        │                   │ • Consulta SEUS patrimônios │
       │ • Cadastro de patrimônios   │                   │ • Permissão APENAS LEITURA  │
       │ • Atribuição e Devolução    │                   │ • Atualiza seu perfil       │
       │ • Dashboard de métricas     │                   │ • Redefine sua senha        │
       └─────────────────────────────┘                   └─────────────────────────────┘
```

> [!NOTE]
Os alunos da escola **não são operadores do sistema**. Os equipamentos escolares (computadores, projetores, instrumentos laboratoriais) ficam sob a guarda e custódia dos docentes ou no almoxarifado sob a gestão da coordenação.
> 

---

## 4. Regras de Negócio (RN)

- **[RN01] Auto-Cadastro Restrito a Administradores:**
    
    O fluxo de cadastro inicial do app cria **exclusivamente Coordenadores/Admins** (`role: "admin"`). O perfil docente não possui cadastro público aberto.
    
- **[RN02] Cadastro Centralizado de Professores:**
    
    Novos professores são inseridos no sistema unicamente pelo Coordenador autenticado. O coordenador fornece os dados institucionais (matrícula, departamento, contato) e define a senha provisória de acesso.
    
- **[RN03] Permissão Estrita de Apenas Leitura para o Docente:**
    
    O professor tem acesso **exclusivamente de consulta** aos patrimônios vinculados a si.
    
    - O aplicativo não deve disponibilizar ações de criação, edição ou exclusão de bens para o docente.
    - Qualquer requisição indevida de escrita disparada por um professor recebe bloqueio com código `403 Forbidden` pelo backend.
- **[RN04] Multiplicidade de Patrimônios:**
    
    Um mesmo professor pode ser responsável por múltiplos bens simultaneamente (ex.: um professor pode ter a tutela de um microscópio, um notebook e um projetor ao mesmo tempo).
    
- **[RN05] Ciclo de Vida: Atribuição e Devolução:**
    - A atribuição associa o bem ao professor e altera seu status para `em_uso`.
    - A devolução retorna o bem ao status `disponivel` (estoque escolar), retirando-o da visão do docente e registrando a ocorrência no histórico.
- **[RN06] Autonomia do Perfil Docente:**
    
    O professor pode atualizar suas informações cadastrais (telefones de contato) e alterar sua senha de acesso a qualquer momento.
    
- **[RN07] Isolamento Multi-Tenant:**
    
    Cada Coordenador gerencia estritamente o ecossistema de sua própria escola. Dados de docentes e patrimônios de diferentes administrações não se cruzam nem são expostos entre si.
    

---

## 5. Requisitos Funcionais do Aplicativo (RF)

### 🔑 Módulo 1: Autenticação e Sessão (Escopo Base)

- **[RF01] Tela de Login:** Autenticação por e-mail e senha. Armazenamento seguro do token JWT e roteamento condicional conforme a `role` do usuário logado (`admin` ou `professor`).
- **[RF02] Cadastro de Coordenador:** Formulário para inserção dos dados do novo gestor escolar.
- **[RF03] Recuperação de Senha:** Interface para solicitação de código de validação e definição de nova senha.
- **[RF04] Logout:** Encerramento seguro da sessão local e limpeza do token.

---

### Módulo 2: Painel do Coordenador (Visão Administrativa)

- **[RF05] Dashboard de Indicadores:** Visualização resumida da situação patrimonial da escola (total de bens, itens em uso, itens disponíveis, manutenções e categorias).
- **[RF06] Gestão de Professores:**
    - Listagem de docentes com indicador da quantidade de bens sob a responsabilidade de cada um.
    - Formulário para cadastro de novos professores.
    - Visualização detalhada do professor com a relação de bens vinculados a ele.
- **[RF07] Gestão de Patrimônios:**
    - Listagem com busca e filtros por status (`em_uso`, `disponivel`, `em_manutencao`) e categoria.
    - Cadastro de novos bens escolares (tombamento, descrição, categoria, marca, número de série).
    - Fluxo de **Atribuição**: seleção de um professor cadastrado para entrega do bem.
    - Fluxo de **Devolução**: desvinculação do docente com registro de motivo.
    - Visualização do **Histórico / Linha do Tempo** do patrimônio.

---

### Módulo 3: Painel do Professor (Visão do Docente)

- **[RF08] Consulta dos Meus Patrimônios:**
Interface em cards mobile exibindo os equipamentos vinculados ao professor autenticado (tombamento, data de atribuição, localização e detalhes). Interface estritamente informativa (sem ações de mutação).
- **[RF09] Gerenciamento de Perfil:**
Tela para consulta de dados cadastrais, atualização de telefone de contato e redefinição da senha pessoal.

---

## 6. Requisitos Não Funcionais (RNF)

- **[RNF01] Experiência de Uso Mobile (UX/UI):** Interface fluida, ergonomia pensada para dispositivos móveis, transições suaves e feedback imediato de toques e ações.
- **[RNF02] Tratamento de Estados Assíncronos:** O aplicativo deve apresentar claramente estados de *Loading* (Shimmer/Skeletons ou indicadores de progresso), estados vazios (*Empty States*) e mensagens amigáveis em cenários de erro ou falha de rede.
- **[RNF03] Comunicação com a API:**
    - Envio automático do cabeçalho `Authorization: Bearer <token>` em rotas protegidas.
    - Tratamento adequado de respostas HTTP (`401 Unauthorized`, `403 Forbidden`, `404 Not Found`).
- **[RNF04] Componentização e Reusabilidade:**
Decomposição da interface em widgets reutilizáveis e coesos, evitando duplicações e código monolítico.

---

## 7. Guia de Integração com o Backend

### Execução do Servidor

O backend é fornecido como executável pré-compilado:

1. Execute o arquivo **`api.exe`** em uma máquina Windows.
2. O servidor ficará ativo ouvindo na porta **`8081`**.
3. A documentação interativa Swagger estará acessível em:
👉 **`http://localhost:8081/swagger/`**

> [!TIP]
**Dica de Conexão no Mobile:**
> 
> - No **Emulador Android Oficial**, utilize `http://10.0.2.2:8081/api` para alcançar a máquina local.
> - No **Simulador iOS**, utilize `http://localhost:8081/api`.
> - Em **Dispositivos Físicos (Wi-Fi)**, utilize o IP da sua máquina na rede local: `http://192.168.x.x:8081/api`.

---

## 8. Dinâmica de Equipe e Governança no GitHub

O projeto deve ser conduzido de forma **colaborativa em equipe**, aplicando as práticas contemporâneas de desenvolvimento de software e controle de versão:

- **Repositório Centralizado:** A equipe manterá um único repositório Git no GitHub para o código do app Flutter.
- **Rastreabilidade e Colaboração:**
A participação e a entrega de cada integrante do grupo devem ser **claramente evidenciadas por meio do histórico de contribuição no GitHub**.
    - A divisão dos módulos, telas e controllers da aplicação deve refletir o trabalho individual dos membros.
    - Espera-se a utilização de **Pull Requests (PRs)** integrados à branch principal (`main`), demonstrando a autoria das funcionalidades entregues, a revisão de código e a evolução contínua da base do projeto.
- **Organização do Repositório:** O repositório deve conter um `README.md` bem estruturado, com instruções de instalação, arquitetura adotada, prints do app em funcionamento e a identificação de cada membro com as respectivas responsabilidades assumidas.

---

## 9. Entregáveis e Critérios de Avaliação

### 📋 O que a equipe deve entregar:

1. **Código-fonte da Aplicação no GitHub:**
    - Link do repositório contendo todo o projeto Flutter.
    - Histórico de *commits* e *Pull Requests* comprovando a participação ativa e individual de cada integrante da equipe.
2. **Protótipo de Alta Fidelidade:**
    - O grupo deve apresentar o protótipo visual das telas do aplicativo.
    - **Uso de IA no Design:** É permitido e encorajado o uso de ferramentas de Inteligência Artificial para auxílio no design (ex.: IA do Figma, Stitch, v0, Lovable ou o plugin *HTML to Design* para converter interfaces geradas por IA em pranchetas no Figma).

---

### Política de Arguição e Domínio do Código:

> [!CAUTION]
**Arguição Presencial Obrigatória:**
> 
> 
> Na data de entrega, o professor passará pelas mesas de cada equipe realizando **perguntas técnicas diretas aos integrantes sobre o código-fonte** (arquitetura, fluxo de dados, lógica dos controllers e consumo da API).
> 
> Todos os membros do grupo devem ter **pleno domínio do código entregue**. Caso seja constatado o uso de ferramentas de IA para gerar código que os alunos **não saibam explicar ou justificar**, a equipe/aluno **receberá nota ZERO**. Ferramentas de assistência são bem-vindas no processo de aprendizagem, mas o entendimento conceitual e técnico é inegociável.
> 

---

### Escopo Flexível e Pontuação:

Não é obrigatório implementar 100% de todos os endpoints disponíveis na API para obter aprovação. O trabalho possui uma régua de pontuação progressiva:

| Escopo Implementado | Pontuação Máxima | Detalhes |
| --- | --- | --- |
| **Escopo Base (Módulo 1: Autenticação)** | **50 Pontos** | Implementação sólida de Login, validações, persistência de sessão (JWT), tratamento de erros e redirecionamento por perfil (`admin` vs `professor`). |
| **Escopo Avançado (Módulos 1 + 2 + 3 Trabalho em equipe, Domínio do código)** | **Até 100 Pontos** | Entrega completa contendo Autenticação, Painel do Coordenador (gestão de patrimônios e professores), Painel do Docente (leitura estrita dos bens) e Perfil. |

fluxo projeto thiago gerenciamento de patrimonios:
[ Tela (View) ]  ◄──(ouve com Obx)──►  [ Controller ]  ◄────►  [ Service ]  ◄────►  [ API Backend ]
  Exibe botões,                         Guarda o Estado           Faz as requisições
  listas e inputs                       e regras de tela          HTTP (GetConnect)

  O Service apenas busca e entrega os dados brutos da rede.
O Controller é o "cérebro" da tela: ele guarda os dados, controla o carregamento (loading) e trata o sucesso ou erro.