document.addEventListener("DOMContentLoaded", function () {

/* =========================================
   TELAS
========================================= */

let papelUsuario = "coordenador"; // "coordenador" (01) ou "professor" (02)

let dadosUsuarioLogado = {
    email: "ana.paula@escola.edu.br",
    password: "••••••••",
    nome: "Coordenadora Ana Paula",
    departamento: "Coordenação Geral e Pedagógica",
    telefone: "(11) 98765-4321",
    cpf: "123.456.789-00",
    papel: "coordenador"
};

const PROFESSORES_PADRAO = [
    {
        id: "prof_carlos",
        nome: "Prof. Carlos Drummond",
        usuario: "Prof. Carlos Drummond",
        matricula: "PROF-2024-01",
        senha: "20240102",
        departamento: "Informática",
        email: "carlos@escola.edu.br",
        telefone: "(11) 91234-5678",
        cpf: "987.654.321-11",
        papel: "professor"
    },
    {
        id: "prof_maria",
        nome: "Profa. Maria Silva",
        usuario: "Profa. Maria Silva",
        matricula: "PROF-2024-02",
        senha: "20240202",
        departamento: "Ciências",
        email: "maria.silva@escola.edu.br",
        telefone: "(11) 97777-6666",
        cpf: "321.654.987-22",
        papel: "professor"
    },
    {
        id: "prof_joao",
        nome: "Prof. João Santos",
        usuario: "Prof. João Santos",
        matricula: "PROF-2024-03",
        senha: "20240302",
        departamento: "Matemática",
        email: "joao.santos@escola.edu.br",
        telefone: "(11) 96666-5555",
        cpf: "456.789.123-33",
        papel: "professor"
    }
];

function obterProfessoresCadastrados() {
    try {
        const salvos = JSON.parse(localStorage.getItem("professores_cadastrados") || "[]");
        return [...PROFESSORES_PADRAO, ...salvos];
    } catch (e) {
        return [...PROFESSORES_PADRAO];
    }
}

const telas = document.querySelectorAll(".tela");

function mostrarTela(numero) {

    // Restrição para perfil Professor: só pode acessar tela 0 (Login), tela 4 (Equipamento atribuído/Devolução) e tela 5 (Perfil)
    if (papelUsuario === "professor") {
        if (numero !== 0 && numero !== 4 && numero !== 5) {
            alert("Acesso restrito: Como Professor, você tem acesso apenas à tela do seu equipamento atribuído e ao seu perfil.");
            numero = 4;
        }
    }

    telas.forEach(function (tela, indice) {

        if (indice === numero) {
            tela.style.display = "block";
            // Atualiza classe 'ativo' nos itens do menu inferior da tela visível
            const menuItens = tela.querySelectorAll(".menu-item");
            menuItens.forEach(function (item) {
                const texto = item.textContent.trim();
                item.classList.remove("ativo");
                if (numero === 1 && texto.includes("Início")) item.classList.add("ativo");
                else if (numero === 2 && texto.includes("Patrimônios") && !texto.includes("Meus")) item.classList.add("ativo");
                else if (numero === 3 && texto.includes("Professores")) item.classList.add("ativo");
                else if (numero === 4 && (texto.includes("Meus bens") || texto.includes("Professores") || texto.includes("Patrimônios"))) item.classList.add("ativo");
                else if (numero === 5 && texto.includes("Perfil")) item.classList.add("ativo");
            });
        } else {
            tela.style.display = "none";
        }

    });

    window.scrollTo(0, 0);
}


/* =========================================
   APLICAÇÃO DE PERMISSÕES E DADOS DO PERFIL
========================================= */

function aplicarPermissoes(papel) {
    papelUsuario = papel;

    telas.forEach(function (tela) {
        // Ajusta itens do menu inferior
        const menuItens = tela.querySelectorAll(".menu-item");
        menuItens.forEach(function (item) {
            const texto = item.textContent.trim();
            if (papel === "professor") {
                if (texto.includes("Início") || (texto.includes("Patrimônios") && !texto.includes("Meus"))) {
                    item.style.display = "none";
                } else if (texto.includes("Professores") || texto.includes("Meus bens")) {
                    item.style.display = "flex";
                    item.innerHTML = '<span>▣</span> Meus bens';
                } else if (texto.includes("Perfil")) {
                    item.style.display = "flex";
                }
            } else {
                item.style.display = "flex";
                if (texto.includes("Meus bens")) {
                    item.innerHTML = '<span>♙</span> Professores';
                }
            }
        });

        // Ajusta botões flutuantes (professores não podem cadastrar)
        const botaoFlutuante = tela.querySelector(".botao-flutuante");
        if (botaoFlutuante) {
            if (papel === "professor") {
                botaoFlutuante.style.display = "none";
            } else {
                botaoFlutuante.style.display = "flex";
            }
        }
    });

    // Atualiza cabeçalho e dados visuais do Perfil (Tela 5)
    const subPerfil = document.querySelector("#perfil-cargo") || document.querySelector(".perfil p");
    const nomePerfil = document.querySelector("#perfil-nome") || document.querySelector(".perfil h1");
    const avatarPerfil = document.querySelector("#perfil-avatar") || document.querySelector(".perfil .avatar");

    const infoNome = document.querySelector("#info-nome");
    const infoEmail = document.querySelector("#info-email");
    const infoPassword = document.querySelector("#info-password");
    const infoDepartamento = document.querySelector("#info-departamento");
    const infoTelefone = document.querySelector("#info-telefone");
    const infoCpf = document.querySelector("#info-cpf");

    if (papel === "professor") {
        if (subPerfil) subPerfil.textContent = "Professor • Docente";
        if (nomePerfil) nomePerfil.textContent = dadosUsuarioLogado.nome;
        if (avatarPerfil) avatarPerfil.textContent = "CD";
    } else {
        if (subPerfil) subPerfil.textContent = "Coordenador Geral • Admin";
        if (nomePerfil) nomePerfil.textContent = dadosUsuarioLogado.nome;
        if (avatarPerfil) avatarPerfil.textContent = "AP";
    }

    // Exibe as 6 informações requisitadas: email, password, nome, departamento, telefone, cpf
    if (infoNome) infoNome.textContent = dadosUsuarioLogado.nome;
    if (infoEmail) infoEmail.textContent = dadosUsuarioLogado.email;
    if (infoPassword) {
        infoPassword.dataset.senhaReal = dadosUsuarioLogado.password;
        infoPassword.textContent = "••••••••";
    }
    if (infoDepartamento) infoDepartamento.textContent = dadosUsuarioLogado.departamento;
    if (infoTelefone) infoTelefone.textContent = dadosUsuarioLogado.telefone;
    if (infoCpf) infoCpf.textContent = dadosUsuarioLogado.cpf;

    // Sincroniza o status dos equipamentos em todas as telas
    sincronizarStatusGlobal();
}


/* =========================================
   SINCRONIZAÇÃO DE STATUS DO PATRIMÔNIO (COORDENADOR E PROFESSOR)
========================================= */

function sincronizarStatusGlobal() {
    const devolvido = localStorage.getItem("equipamentoDevolvido") === "true";
    let atribuido = null;
    try {
        atribuido = JSON.parse(localStorage.getItem("equipamentoAtribuido") || "null");
    } catch(e) {}

    const profNomeAtribuido = (atribuido && atribuido.professorNome) ? atribuido.professorNome : "Prof. Carlos Drummond";

    // 1. Atualiza Indicadores do Dashboard (Tela 1 - Coordenador)
    const contadorEmUso = document.querySelector("#contador-em-uso");
    const contadorDisponiveis = document.querySelector("#contador-disponiveis");
    const descMov = document.querySelector("#desc-movimentacao-notebook");
    const statusPatNotebook = document.querySelector("#status-pat-notebook");
    const qtdBensCarlos = document.querySelector("#qtd-bens-prof-carlos");
    const statusDetalhes = document.querySelector("#status-detalhes-pat");
    const responsavelDetalhes = document.querySelector("#responsavel-detalhes-pat");
    const btnAtribuir = document.querySelector("#btn-atribuir-patrimonio");
    const btnDevolver = document.querySelector("#btn-devolver-patrimonio");

    if (devolvido) {
        const motivo = localStorage.getItem("motivoDevolucao") || "Devolução realizada";
        if (contadorEmUso) contadorEmUso.textContent = "83";
        if (contadorDisponiveis) contadorDisponiveis.textContent = "33";
        if (descMov) {
            descMov.textContent = `Devolvido ao estoque por ${profNomeAtribuido} (${motivo})`;
        }

        if (statusPatNotebook) {
            statusPatNotebook.textContent = "Disponível";
            statusPatNotebook.className = "status disponivel";
            statusPatNotebook.style.backgroundColor = "#c6f6d5";
            statusPatNotebook.style.color = "#22543d";
        }

        if (qtdBensCarlos) {
            qtdBensCarlos.textContent = "3 bens";
        }

        if (statusDetalhes) {
            statusDetalhes.textContent = "Disponível";
            statusDetalhes.className = "status disponivel";
            statusDetalhes.style.backgroundColor = "#c6f6d5";
            statusDetalhes.style.color = "#22543d";
        }
        if (responsavelDetalhes) {
            responsavelDetalhes.textContent = "Nenhum (Disponível no estoque)";
        }

        if (papelUsuario === "professor") {
            if (btnAtribuir) btnAtribuir.style.display = "none";
            if (btnDevolver) {
                btnDevolver.style.display = "block";
                btnDevolver.textContent = "Equipamento devolvido ✓";
                btnDevolver.disabled = true;
                btnDevolver.style.backgroundColor = "#a0aec0";
                btnDevolver.style.cursor = "not-allowed";
            }
        } else {
            // Coordenador vê botão de atribuir equipamento
            if (btnAtribuir) {
                btnAtribuir.style.display = "block";
                btnAtribuir.textContent = "Atribuir equipamento";
                btnAtribuir.style.backgroundColor = "#2b6cb0";
            }
            if (btnDevolver) {
                btnDevolver.style.display = "none";
            }
        }
    } else {
        // Equipamento em uso / atribuído
        if (contadorEmUso) contadorEmUso.textContent = "84";
        if (contadorDisponiveis) contadorDisponiveis.textContent = "32";
        if (descMov) {
            descMov.textContent = `Atribuído para ${profNomeAtribuido}`;
        }

        if (statusPatNotebook) {
            statusPatNotebook.textContent = "Em uso";
            statusPatNotebook.className = "status em-uso";
            statusPatNotebook.style.backgroundColor = "#bee3f8";
            statusPatNotebook.style.color = "#2b6cb0";
        }

        if (qtdBensCarlos) {
            qtdBensCarlos.textContent = "4 bens";
        }

        if (statusDetalhes) {
            statusDetalhes.textContent = "Em uso";
            statusDetalhes.className = "status em-uso";
            statusDetalhes.style.backgroundColor = "#bee3f8";
            statusDetalhes.style.color = "#2b6cb0";
        }
        if (responsavelDetalhes) {
            responsavelDetalhes.textContent = profNomeAtribuido;
        }

        if (papelUsuario === "professor") {
            if (btnAtribuir) btnAtribuir.style.display = "none";
            if (btnDevolver) {
                btnDevolver.style.display = "block";
                btnDevolver.textContent = "Registrar devolução";
                btnDevolver.disabled = false;
                btnDevolver.style.backgroundColor = "#205988";
                btnDevolver.style.cursor = "pointer";
            }
        } else {
            // Coordenador pode reatribuir ou registrar devolução
            if (btnAtribuir) {
                btnAtribuir.style.display = "block";
                btnAtribuir.textContent = "Reatribuir equipamento";
                btnAtribuir.style.backgroundColor = "#2b6cb0";
            }
            if (btnDevolver) {
                btnDevolver.style.display = "block";
                btnDevolver.textContent = "Registrar devolução";
                btnDevolver.disabled = false;
                btnDevolver.style.backgroundColor = "#D96161";
                btnDevolver.style.cursor = "pointer";
            }
        }
    }
}


/* =========================================
   INÍCIO
========================================= */

sincronizarStatusGlobal();
mostrarTela(0);


/* =========================================
   SISTEMA DE TOKENS JWT
========================================= */

function gerarTokenJWT(email, papel, nome) {
    const cabecalho = {
        alg: "HS256",
        typ: "JWT"
    };

    const agora = Math.floor(Date.now() / 1000);
    const carga = {
        sub: email,
        nome: nome,
        role: papel === "coordenador" ? "admin" : "docente",
        papel: papel,
        iat: agora,
        exp: agora + (60 * 60 * 24) // 24h
    };

    function base64Url(str) {
        return btoa(unescape(encodeURIComponent(str)))
            .replace(/\+/g, "-")
            .replace(/\//g, "_")
            .replace(/=+$/, "");
    }

    const headerB64 = base64Url(JSON.stringify(cabecalho));
    const payloadB64 = base64Url(JSON.stringify(carga));
    const assinaturaB64 = base64Url("sig_" + email + "_" + papel + "_" + agora);

    return `${headerB64}.${payloadB64}.${assinaturaB64}`;
}


/* =========================================
   LOGIN COM IDENTIFICAÇÃO POR SENHA (01 / 02) E JWT
========================================= */

const botaoLogin = document.querySelector(
    ".login-container .botao-principal"
);

if (botaoLogin) {

    botaoLogin.addEventListener("click", function () {

        const email = document.querySelector("#email").value.trim();
        const senha = document.querySelector("#senha").value.trim();

        if (email === "" || senha === "") {
            alert("Preencha o e-mail e a senha.");
            return;
        }

        /*
         * Identificação do Papel e Emissão de Token JWT:
         * - Senha terminando com 01: COORDENADOR (Role admin, Acesso total)
         * - Senha terminando com 02: PROFESSOR (Role docente, Acesso a Professores e Perfil)
         */
        if (senha.endsWith("01")) {
            dadosUsuarioLogado = {
                email: email,
                password: senha,
                nome: "Coordenadora Ana Paula",
                departamento: "Coordenação Geral e Pedagógica",
                telefone: "(11) 98765-4321",
                cpf: "123.456.789-00",
                papel: "coordenador"
            };
            aplicarPermissoes("coordenador");

            const token = gerarTokenJWT(email, "coordenador", dadosUsuarioLogado.nome);
            localStorage.setItem("jwt_token", token);
            localStorage.setItem("jwt_refresh_token", "refresh_" + token.slice(-16));
            localStorage.setItem("dados_usuario", JSON.stringify({
                ...dadosUsuarioLogado,
                role: "admin",
                token: token
            }));
            console.log(">>> [JWT TOKEN GERADO - COORDENADOR]:", token);

            alert("Acesso autorizado como COORDENADOR!\nToken JWT emitido com sucesso (perfil: admin).");
            mostrarTela(1); // Dashboard do Coordenador
        } else if (senha.endsWith("02") || (senha.startsWith("02") && !senha.endsWith("01"))) {
            const listaProf = obterProfessoresCadastrados();
            const termoBusca = email.toLowerCase();
            const professorEncontrado = listaProf.find(function(p) {
                return (p.usuario && p.usuario.toLowerCase() === termoBusca) ||
                       (p.nome && p.nome.toLowerCase() === termoBusca) ||
                       (p.email && p.email.toLowerCase() === termoBusca) ||
                       (p.matricula && p.matricula.toLowerCase() === termoBusca);
            });

            if (professorEncontrado) {
                dadosUsuarioLogado = {
                    email: professorEncontrado.email || email,
                    password: senha,
                    nome: professorEncontrado.nome,
                    departamento: professorEncontrado.departamento || "Departamento Docente",
                    telefone: professorEncontrado.telefone || "(11) 91234-5678",
                    cpf: professorEncontrado.cpf || "987.654.321-11",
                    papel: "professor",
                    matricula: professorEncontrado.matricula,
                    usuario: professorEncontrado.usuario
                };
            } else {
                dadosUsuarioLogado = {
                    email: email.includes("@") ? email : `${email.toLowerCase().replace(/\s+/g, '.')}@escola.edu.br`,
                    password: senha,
                    nome: email.includes("@") ? "Prof. Carlos Drummond" : email,
                    departamento: "Departamento Docente",
                    telefone: "(11) 91234-5678",
                    cpf: "987.654.321-11",
                    papel: "professor",
                    usuario: email
                };
            }

            aplicarPermissoes("professor");

            const token = gerarTokenJWT(dadosUsuarioLogado.email, "professor", dadosUsuarioLogado.nome);
            localStorage.setItem("jwt_token", token);
            localStorage.setItem("jwt_refresh_token", "refresh_" + token.slice(-16));
            localStorage.setItem("dados_usuario", JSON.stringify({
                ...dadosUsuarioLogado,
                role: "docente",
                token: token
            }));
            console.log(">>> [JWT TOKEN GERADO - PROFESSOR]:", token);

            // Sincroniza o status do equipamento atribuído
            sincronizarStatusGlobal();

            alert(`Acesso autorizado como PROFESSOR!\nBem-vindo(a), ${dadosUsuarioLogado.nome}!\nToken JWT emitido com sucesso (perfil: docente).\nAcessando tela do equipamento atribuído.`);
            mostrarTela(4); // Substitui a tela de professores pela tela de equipamento com devolução
        } else {
            alert("Identificação de perfil necessária:\n• Senha terminada em '01': Acesso de Coordenador\n• Senha terminada em '02': Acesso de Professor");
            return;
        }

    });

}


/* =========================================
   LINKS DO LOGIN
========================================= */

const linksLogin = document.querySelectorAll(".login-container .link");

if (linksLogin.length >= 2) {

    /* Esqueci minha senha */

    linksLogin[0].addEventListener("click", function (event) {

        event.preventDefault();

        mostrarTela(11);

    });


    /* Criar conta */

    linksLogin[1].addEventListener("click", function (event) {

        event.preventDefault();

        alert("Tela de cadastro do coordenador.");

    });

}


/* =========================================
   MENU INFERIOR COM RESTRIÇÃO DE PAPEL
========================================= */

telas.forEach(function (tela, numeroTela) {

    const menuItens = tela.querySelectorAll(".menu-item");

    menuItens.forEach(function (item) {

        item.addEventListener("click", function (event) {

            event.preventDefault();

            const texto = item.textContent.trim();

            if (papelUsuario === "professor" && (texto.includes("Início") || (texto.includes("Patrimônios") && !texto.includes("Meus")))) {
                alert("Acesso restrito: Como Professor, você tem acesso apenas à tela do seu equipamento atribuído e ao seu perfil.");
                return;
            }

            if (texto.includes("Início")) {
                mostrarTela(1);
            }

            else if (texto.includes("Patrimônios") && !texto.includes("Meus")) {
                mostrarTela(2);
            }

            else if (texto.includes("Professores") || texto.includes("Meus bens")) {
                if (papelUsuario === "professor") {
                    mostrarTela(4); // Tela com o equipamento do professor e devolução
                } else {
                    mostrarTela(3); // Tela de gestão de professores para coordenador
                }
            }

            else if (texto.includes("Perfil")) {
                mostrarTela(5);
            }

        });

    });

});


/* =========================================
   BOTÕES + DE CADASTRO
========================================= */

const botoesFlutuantes = document.querySelectorAll(
    ".botao-flutuante"
);

botoesFlutuantes.forEach(function (botao, indice) {

    botao.addEventListener("click", function () {

        if (papelUsuario === "professor") {
            alert("Acesso restrito: Apenas o Coordenador tem permissão para cadastrar patrimônios ou professores.");
            return;
        }

        if (indice === 0) {
            abrirModalCadastroPatrimonio();
        } else {
            abrirModalCadastroProfessor();
        }

    });

});


/* =========================================
   FILTROS DE PATRIMÔNIO
========================================= */

const filtros = document.querySelectorAll(".filtro");

filtros.forEach(function (filtro) {

    filtro.addEventListener("click", function () {

        filtros.forEach(function (item) {
            item.classList.remove("ativo");
        });

        filtro.classList.add("ativo");

    });

});


/* =========================================
   PESQUISA DE PATRIMÔNIOS
========================================= */

const campoPesquisa = document.querySelector(
    ".campo-pesquisa"
);

const cardsPatrimonio = document.querySelectorAll(
    ".patrimonio"
);

if (campoPesquisa) {

    campoPesquisa.addEventListener("input", function () {

        const texto = campoPesquisa.value.toLowerCase();

        cardsPatrimonio.forEach(function (card) {

            const conteudo = card.textContent.toLowerCase();

            if (conteudo.includes(texto)) {
                card.style.display = "block";
            } else {
                card.style.display = "none";
            }

        });

    });

}


/* =========================================
   CARDS DE PATRIMÔNIO
========================================= */

cardsPatrimonio.forEach(function (card) {

    card.addEventListener("click", function () {

        mostrarTela(4);

    });

    card.style.cursor = "pointer";

});


/* =========================================
   CARDS DE PROFESSORES
========================================= */

const cardsProfessor = document.querySelectorAll(
    ".professor"
);

cardsProfessor.forEach(function (card) {

    card.addEventListener("click", function () {

        alert("Abrir detalhes do professor.");

    });

    card.style.cursor = "pointer";

});

function carregarProfessoresCadastradosNaTela() {
    try {
        const salvos = JSON.parse(localStorage.getItem("professores_cadastrados") || "[]");
        const telaProfessores = document.querySelectorAll(".tela")[3];
        if (!telaProfessores || salvos.length === 0) return;

        const campoBusca = telaProfessores.querySelector(".campo-pesquisa");
        salvos.forEach(function (prof) {
            const novoCard = document.createElement("article");
            novoCard.className = "card professor";
            novoCard.style.cursor = "pointer";
            novoCard.innerHTML = `
                <div>
                    <h3>${prof.nome}</h3>
                    <p>Matrícula: ${prof.matricula}</p>
                    <p>Departamento: ${prof.departamento}</p>
                </div>
                <span class="quantidade">
                    0 bens
                </span>
            `;

            novoCard.addEventListener("click", function () {
                alert(`Professor: ${prof.nome}\nUsuário: ${prof.usuario}\nSenha: ${prof.senha}\nDepartamento: ${prof.departamento}`);
            });

            if (campoBusca) {
                campoBusca.insertAdjacentElement("afterend", novoCard);
            }
        });

        const contadorProf = telaProfessores.querySelector(".cabecalho p");
        if (contadorProf) {
            const totalAtual = telaProfessores.querySelectorAll(".card.professor").length;
            contadorProf.textContent = `${totalAtual} professores cadastrados`;
        }
    } catch(e) {}
}

carregarProfessoresCadastradosNaTela();


/* =========================================
   AÇÕES DO PATRIMÔNIO (ATRIBUIÇÃO E DEVOLUÇÃO)
========================================= */

const btnAtribuirPatrimonio = document.querySelector("#btn-atribuir-patrimonio");
if (btnAtribuirPatrimonio) {
    btnAtribuirPatrimonio.addEventListener("click", function () {
        abrirModalAtribuirEquipamento();
    });
}

const btnDevolverPatrimonio = document.querySelector("#btn-devolver-patrimonio");
if (btnDevolverPatrimonio) {
    btnDevolverPatrimonio.addEventListener("click", function () {
        abrirModalDevolucao();
    });
}

// Suporte para cliques genéricos em botões de devolução
const botoesDevolucao = document.querySelectorAll(
    ".botao-principal"
);

botoesDevolucao.forEach(function (botao) {
    if (
        botao.textContent.trim() === "Registrar devolução" &&
        botao.id !== "btn-devolver-patrimonio"
    ) {
        botao.addEventListener("click", function () {
            abrirModalDevolucao();
        });
    }
});


function abrirModalDevolucao() {

    const overlay = document.createElement("div");
    overlay.className = "overlay-js";

    overlay.innerHTML = `
        <div class="modal-js">

            <h2>Registrar devolução</h2>

            <div class="campo-js">
                <label for="motivo-devolucao">Motivo da devolução</label>
                <input
                    type="text"
                    id="motivo-devolucao"
                    placeholder="Informe o motivo"
                >
            </div>

            <button
                class="botao botao-principal"
                id="confirmar-devolucao"
            >
                Confirmar devolução
            </button>

            <button
                class="cancelar-js"
                id="cancelar-devolucao"
            >
                Cancelar
            </button>

        </div>
    `;

    document.body.appendChild(overlay);

    overlay.addEventListener("click", function (event) {
        if (event.target === overlay) {
            overlay.remove();
        }
    });

    overlay.querySelector("#cancelar-devolucao").addEventListener("click", function () {
        overlay.remove();
    });

    overlay.querySelector("#confirmar-devolucao").addEventListener("click", function () {
        const motivo = overlay.querySelector("#motivo-devolucao").value.trim();

        if (motivo === "") {
            alert("Informe o motivo da devolução.");
            return;
        }

        alert("Devolução registrada com sucesso.");
        overlay.remove();

        // Salva estado de devolução e atualiza todas as telas (coordenador e professor)
        localStorage.setItem("equipamentoDevolvido", "true");
        localStorage.setItem("motivoDevolucao", motivo);
        sincronizarStatusGlobal();

        // Adiciona evento na linha do tempo
        const linhaTempo = document.querySelector("#linha-tempo-patrimonio");
        if (linhaTempo) {
            const novoEvento = document.createElement("div");
            novoEvento.className = "evento";
            novoEvento.innerHTML = `
                <h3>Patrimônio devolvido</h3>
                <p>${dadosUsuarioLogado.nome} (Motivo: ${motivo})</p>
                <small>Hoje</small>
            `;
            linhaTempo.insertBefore(novoEvento, linhaTempo.firstChild);
        }
    });

}


function abrirModalAtribuirEquipamento() {

    const listaProf = obterProfessoresCadastrados();
    const overlay = document.createElement("div");
    overlay.className = "overlay-js";

    const opcoesHtml = listaProf.map(function (p) {
        return `<option value="${p.id}">${p.nome} — ${p.departamento || 'Docente'} (Matrícula: ${p.matricula})</option>`;
    }).join("");

    overlay.innerHTML = `
        <div class="modal-js">

            <h2>Atribuir Equipamento</h2>

            <p style="color: #475569; font-size: 14px; margin-bottom: 16px;">
                Selecione o professor que receberá a custódia de: <strong>Notebook Dell Latitude (PAT-2024-001)</strong>
            </p>

            <div class="campo-js">
                <label for="select-prof-atribuir">Professor Responsável *</label>
                <select id="select-prof-atribuir">
                    ${opcoesHtml}
                </select>
            </div>

            <div class="campo-js">
                <label for="obs-atribuicao">Observações de Entrega (Opcional)</label>
                <input
                    type="text"
                    id="obs-atribuicao"
                    placeholder="Ex: Entregue completo com carregador e cabo HDMI"
                >
            </div>

            <button
                class="botao botao-principal"
                id="confirmar-atribuicao"
                style="background-color: #2b6cb0;"
            >
                Confirmar atribuição
            </button>

            <button
                class="cancelar-js"
                id="cancelar-atribuicao"
            >
                Cancelar
            </button>

        </div>
    `;

    document.body.appendChild(overlay);

    overlay.addEventListener("click", function (event) {
        if (event.target === overlay) {
            overlay.remove();
        }
    });

    overlay.querySelector("#cancelar-atribuicao").addEventListener("click", function () {
        overlay.remove();
    });

    overlay.querySelector("#confirmar-atribuicao").addEventListener("click", function () {
        const select = overlay.querySelector("#select-prof-atribuir");
        const profId = select.value;
        const profSelecionado = listaProf.find(function (p) { return p.id === profId; }) || listaProf[0];
        const obs = overlay.querySelector("#obs-atribuicao").value.trim();

        // Atualiza estado de atribuição
        localStorage.setItem("equipamentoDevolvido", "false");
        localStorage.removeItem("motivoDevolucao");
        localStorage.setItem("equipamentoAtribuido", JSON.stringify({
            patrimonioId: "PAT-2024-001",
            patrimonioNome: "Notebook Dell Latitude",
            professorId: profSelecionado.id,
            professorNome: profSelecionado.nome,
            professorUsuario: profSelecionado.usuario,
            professorEmail: profSelecionado.email,
            departamento: profSelecionado.departamento,
            observacao: obs,
            data: new Date().toLocaleDateString("pt-BR")
        }));

        // Adiciona evento na linha do tempo
        const linhaTempo = document.querySelector("#linha-tempo-patrimonio");
        if (linhaTempo) {
            const novoEvento = document.createElement("div");
            novoEvento.className = "evento";
            novoEvento.innerHTML = `
                <h3>Patrimônio atribuído</h3>
                <p>${profSelecionado.nome} ${obs ? '(Obs: ' + obs + ')' : ''}</p>
                <small>Hoje</small>
            `;
            linhaTempo.insertBefore(novoEvento, linhaTempo.firstChild);
        }

        sincronizarStatusGlobal();

        alert(`Equipamento atribuído com sucesso para ${profSelecionado.nome}!\n\nQuando o professor acessar o sistema com o usuário "${profSelecionado.usuario || profSelecionado.nome}" e senha terminada em 02, este equipamento constará vinculado ao nome dele.`);
        overlay.remove();
    });

}


/* =========================================
   MODAL DE CADASTRO DE PATRIMÔNIO
========================================= */

function abrirModalCadastroPatrimonio() {

    const overlay = document.createElement("div");
    overlay.className = "overlay-js";

    overlay.innerHTML = `
        <div class="modal-js">

            <h2>Cadastrar Novo Patrimônio</h2>

            <div class="campo-js">
                <label>Nome / Descrição do bem *</label>
                <input
                    type="text"
                    id="novo-patrimonio-nome"
                    placeholder="Ex: Notebook Dell Latitude 3420"
                >
            </div>

            <div class="campo-js">
                <label>Número de Tombamento *</label>
                <input
                    type="text"
                    id="novo-patrimonio-tombo"
                    placeholder="Ex: PAT-2024-004"
                >
            </div>

            <div class="campo-js">
                <label>Categoria</label>
                <select id="novo-patrimonio-categoria">
                    <option value="Informática">Informática</option>
                    <option value="Mobiliário">Mobiliário</option>
                    <option value="Audiovisual">Audiovisual</option>
                    <option value="Esportivo">Esportivo</option>
                    <option value="Laboratório">Laboratório</option>
                    <option value="Outros">Outros</option>
                </select>
            </div>

            <div class="campo-js">
                <label>Localização / Sala</label>
                <input
                    type="text"
                    id="novo-patrimonio-local"
                    placeholder="Ex: Laboratório de Informática 01"
                >
            </div>

            <div class="campo-js">
                <label>Número de Série</label>
                <input
                    type="text"
                    id="novo-patrimonio-serie"
                    placeholder="Ex: SN-8839201"
                >
            </div>

            <button
                class="botao botao-principal"
                id="confirmar-cadastro-patrimonio"
            >
                Cadastrar patrimônio
            </button>

            <button
                class="cancelar-js"
                id="cancelar-cadastro-patrimonio"
            >
                Cancelar
            </button>

        </div>
    `;

    document.body.appendChild(overlay);

    overlay.addEventListener("click", function (event) {
        if (event.target === overlay) {
            overlay.remove();
        }
    });

    overlay.querySelector("#cancelar-cadastro-patrimonio").addEventListener("click", function () {
        overlay.remove();
    });

    overlay.querySelector("#confirmar-cadastro-patrimonio").addEventListener("click", function () {
        const nome = overlay.querySelector("#novo-patrimonio-nome").value.trim();
        const tombo = overlay.querySelector("#novo-patrimonio-tombo").value.trim();
        const categoria = overlay.querySelector("#novo-patrimonio-categoria").value;
        const local = overlay.querySelector("#novo-patrimonio-local").value.trim() || "Geral";

        if (nome === "" || tombo === "") {
            alert("Preencha o nome e o número de tombamento do patrimônio.");
            return;
        }

        const telaPatrimonios = document.querySelectorAll(".tela")[2];
        if (telaPatrimonios) {
            const filtros = telaPatrimonios.querySelector(".filtros");
            const novoCard = document.createElement("article");
            novoCard.className = "card patrimonio";
            novoCard.style.cursor = "pointer";
            novoCard.innerHTML = `
                <div class="patrimonio-topo">
                    <div>
                        <h3>${nome}</h3>
                        <p>Tombamento: ${tombo}</p>
                        <p>${categoria} • ${local}</p>
                    </div>
                    <span class="status disponivel">
                        Disponível
                    </span>
                </div>
            `;

            novoCard.addEventListener("click", function () {
                mostrarTela(4);
            });

            if (filtros) {
                filtros.insertAdjacentElement("afterend", novoCard);
            } else {
                telaPatrimonios.querySelector(".conteudo").appendChild(novoCard);
            }

            const contadorBens = telaPatrimonios.querySelector(".cabecalho p");
            if (contadorBens) {
                const totalAtual = telaPatrimonios.querySelectorAll(".card.patrimonio").length;
                contadorBens.textContent = `${totalAtual} bens cadastrados`;
            }
        }

        alert("Patrimônio cadastrado com sucesso!");
        overlay.remove();
    });

}


/* =========================================
   MODAL DE CADASTRO DE PROFESSOR
========================================= */

function abrirModalCadastroProfessor() {

    const overlay = document.createElement("div");
    overlay.className = "overlay-js";

    overlay.innerHTML = `
        <div class="modal-js">

            <h2>Cadastrar Novo Professor</h2>

            <div class="campo-js">
                <label for="novo-prof-nome">Nome Completo do Professor *</label>
                <input
                    type="text"
                    id="novo-prof-nome"
                    placeholder="Ex: Profa. Juliana Pereira Santos"
                >
            </div>

            <div class="campo-js">
                <label for="novo-prof-matricula">Número de Matrícula *</label>
                <input
                    type="text"
                    id="novo-prof-matricula"
                    placeholder="Ex: 202404 ou PROF-2024-04"
                >
            </div>

            <div class="campo-js">
                <label for="novo-prof-usuario">Usuário de Acesso (Login do Professor)</label>
                <input
                    type="text"
                    id="novo-prof-usuario"
                    placeholder="Preenchido automaticamente com o nome"
                    style="background-color: #f1f5f9; color: #1e3a8a; font-weight: 500;"
                >
                <small style="display:block; color:#64748b; font-size:12px; margin-top:4px;">
                    👤 Usuário: Nome completo utilizado para login
                </small>
            </div>

            <div class="campo-js">
                <label for="novo-prof-senha">Senha de Acesso (Matrícula + código 02) *</label>
                <input
                    type="text"
                    id="novo-prof-senha"
                    placeholder="Ex: 20240402"
                    style="background-color: #f1f5f9; color: #1e3a8a; font-weight: bold;"
                >
                <small style="display:block; color:#64748b; font-size:12px; margin-top:4px;">
                    🔑 Senha: Matrícula + identificador 02 (permissão de professor)
                </small>
            </div>

            <div class="campo-js">
                <label for="novo-prof-depto">Departamento / Área</label>
                <input
                    type="text"
                    id="novo-prof-depto"
                    placeholder="Ex: Informática / Matemática"
                >
            </div>

            <div class="campo-js">
                <label for="novo-prof-email">E-mail Institucional</label>
                <input
                    type="email"
                    id="novo-prof-email"
                    placeholder="Ex: juliana.pereira@escola.edu.br"
                >
            </div>

            <div class="campo-js">
                <label for="novo-prof-telefone">Telefone</label>
                <input
                    type="text"
                    id="novo-prof-telefone"
                    placeholder="Ex: (11) 98765-4321"
                >
            </div>

            <div class="campo-js">
                <label for="novo-prof-cpf">CPF</label>
                <input
                    type="text"
                    id="novo-prof-cpf"
                    placeholder="Ex: 321.654.987-44"
                >
            </div>

            <button
                class="botao botao-principal"
                id="confirmar-cadastro-professor"
            >
                Cadastrar professor
            </button>

            <button
                class="cancelar-js"
                id="cancelar-cadastro-professor"
            >
                Cancelar
            </button>

        </div>
    `;

    document.body.appendChild(overlay);

    const inputNome = overlay.querySelector("#novo-prof-nome");
    const inputMatricula = overlay.querySelector("#novo-prof-matricula");
    const inputUsuario = overlay.querySelector("#novo-prof-usuario");
    const inputSenha = overlay.querySelector("#novo-prof-senha");
    const inputEmail = overlay.querySelector("#novo-prof-email");

    // Preenche automaticamente o Usuário com o Nome completo
    inputNome.addEventListener("input", function () {
        inputUsuario.value = inputNome.value.trim();
        if (inputEmail.value.trim() === "" && inputNome.value.trim().length > 3) {
            const emailSugerido = inputNome.value.trim().toLowerCase().replace(/\s+/g, ".") + "@escola.edu.br";
            inputEmail.placeholder = emailSugerido;
        }
    });

    // Preenche automaticamente a Senha com a Matrícula + '02'
    inputMatricula.addEventListener("input", function () {
        const mat = inputMatricula.value.trim();
        const digitos = mat.replace(/\D/g, "");
        if (digitos.length > 0) {
            inputSenha.value = digitos + "02";
        } else if (mat.length > 0) {
            inputSenha.value = mat + "02";
        } else {
            inputSenha.value = "";
        }
    });

    overlay.addEventListener("click", function (event) {
        if (event.target === overlay) {
            overlay.remove();
        }
    });

    overlay.querySelector("#cancelar-cadastro-professor").addEventListener("click", function () {
        overlay.remove();
    });

    overlay.querySelector("#confirmar-cadastro-professor").addEventListener("click", function () {
        const nome = inputNome.value.trim();
        const matricula = inputMatricula.value.trim();
        let usuario = inputUsuario.value.trim();
        let senha = inputSenha.value.trim();
        const depto = overlay.querySelector("#novo-prof-depto").value.trim() || "Geral";
        let email = inputEmail.value.trim();
        const telefone = overlay.querySelector("#novo-prof-telefone").value.trim() || "(11) 98765-4321";
        const cpf = overlay.querySelector("#novo-prof-cpf").value.trim() || "987.654.321-99";

        if (nome === "" || matricula === "") {
            alert("Preencha o nome e a matrícula do professor.");
            return;
        }

        if (usuario === "") {
            usuario = nome;
        }

        if (senha === "") {
            const digitos = matricula.replace(/\D/g, "");
            senha = (digitos.length > 0 ? digitos : matricula) + "02";
        }

        // Garante que a senha termine com 02 (ou comece com 02)
        if (!senha.endsWith("02")) {
            senha = senha + "02";
        }

        if (email === "") {
            email = nome.toLowerCase().replace(/\s+/g, ".") + "@escola.edu.br";
        }

        // Cria o registro do novo professor
        const novoProfessor = {
            id: "prof_" + Date.now(),
            nome: nome,
            usuario: usuario,
            matricula: matricula,
            senha: senha,
            departamento: depto,
            email: email,
            telefone: telefone,
            cpf: cpf,
            papel: "professor"
        };

        // Salva na lista do localStorage
        try {
            const listaSalva = JSON.parse(localStorage.getItem("professores_cadastrados") || "[]");
            listaSalva.push(novoProfessor);
            localStorage.setItem("professores_cadastrados", JSON.stringify(listaSalva));
        } catch (e) {
            console.error(e);
        }

        // Atualiza a tela de gestão de professores (Tela 3)
        const telaProfessores = document.querySelectorAll(".tela")[3];
        if (telaProfessores) {
            const campoBusca = telaProfessores.querySelector(".campo-pesquisa");
            const novoCard = document.createElement("article");
            novoCard.className = "card professor";
            novoCard.style.cursor = "pointer";
            novoCard.innerHTML = `
                <div>
                    <h3>${nome}</h3>
                    <p>Matrícula: ${matricula}</p>
                    <p>Departamento: ${depto}</p>
                </div>
                <span class="quantidade">
                    0 bens
                </span>
            `;

            novoCard.addEventListener("click", function () {
                alert(`Professor: ${nome}\nUsuário: ${usuario}\nSenha de acesso: ${senha}\nDepartamento: ${depto}`);
            });

            if (campoBusca) {
                campoBusca.insertAdjacentElement("afterend", novoCard);
            } else {
                telaProfessores.querySelector(".conteudo").appendChild(novoCard);
            }

            const contadorProf = telaProfessores.querySelector(".cabecalho p");
            if (contadorProf) {
                const totalAtual = telaProfessores.querySelectorAll(".card.professor").length;
                contadorProf.textContent = `${totalAtual} professores cadastrados`;
            }
        }

        // Exibe ao coordenador as credenciais criadas para repassar ao professor
        alert(`Professor cadastrado com sucesso!\n\n📋 Credenciais de Acesso criadas para o Professor:\n• Usuário: ${usuario}\n• Senha: ${senha}\n\n(O professor poderá acessar o sistema utilizando este Usuário e Senha terminada em 02).`);
        overlay.remove();
    });

}


/* =========================================
   PERFIL
========================================= */

const opcoesPerfil = document.querySelectorAll(
    ".opcao"
);

opcoesPerfil.forEach(function (opcao) {

    opcao.addEventListener("click", function (event) {

        event.preventDefault();

        const texto = opcao.textContent.trim();

        if (texto.includes("Sair")) {

            const confirmar =
                confirm(
                    "Deseja realmente sair da conta?"
                );

            if (confirmar) {

                aplicarPermissoes("coordenador");
                localStorage.removeItem("jwt_token");
                localStorage.removeItem("jwt_refresh_token");
                localStorage.removeItem("dados_usuario");
                console.log(">>> [JWT TOKEN]: Sessão encerrada e token removido do armazenamento.");

                const emailInput = document.querySelector("#email");
                const senhaInput = document.querySelector("#senha");
                if (emailInput) emailInput.value = "";
                if (senhaInput) senhaInput.value = "";

                mostrarTela(0);

            }

        }

    });

});


/* =========================================
   TOGGLE DE VISUALIZAÇÃO DE SENHA DO PERFIL
========================================= */

const btnToggleSenha = document.querySelector("#btn-toggle-senha");

if (btnToggleSenha) {

    btnToggleSenha.addEventListener("click", function () {

        const infoPassword = document.querySelector("#info-password");

        if (infoPassword) {

            if (infoPassword.textContent === "••••••••") {
                infoPassword.textContent = infoPassword.dataset.senhaReal || dadosUsuarioLogado.password;
                btnToggleSenha.textContent = "🙈";
                btnToggleSenha.title = "Ocultar senha";
            } else {
                infoPassword.textContent = "••••••••";
                btnToggleSenha.textContent = "👁";
                btnToggleSenha.title = "Visualizar senha";
            }

        }

    });

}


/* =========================================
   ESTILO DOS MODAIS CRIADOS PELO JS
========================================= */

const estiloModal = document.createElement("style");

estiloModal.textContent = `

    .overlay-js {
        position: fixed;
        inset: 0;
        background: rgba(0,0,0,.5);
        display: flex;
        align-items: flex-end;
        justify-content: center;
        z-index: 999;
    }

    .modal-js {
        width: 100%;
        max-width: 500px;
        background: white;
        border-radius: 22px 22px 0 0;
        padding: 25px 22px;
        max-height: 85vh;
        overflow-y: auto;
        box-sizing: border-box;
        box-shadow: 0 -4px 20px rgba(0,0,0,0.15);
        animation: deslizarSubir 0.25s ease-out;
    }

    @keyframes deslizarSubir {
        from { transform: translateY(100%); }
        to { transform: translateY(0); }
    }

    .modal-js h2 {
        color: #205988;
        font-size: 20px;
        margin-bottom: 20px;
    }

    .campo-js {
        margin-bottom: 15px;
    }

    .campo-js label {
        display: block;
        font-size: 13px;
        font-weight: 600;
        margin-bottom: 7px;
        color: #334155;
    }

    .campo-js input,
    .campo-js select {
        width: 100%;
        height: 46px;
        border: 1px solid #ccd7e2;
        border-radius: 9px;
        padding: 0 14px;
        outline: none;
        box-sizing: border-box;
        font-size: 14px;
        background: white;
        color: #1e293b;
    }

    .campo-js input:focus,
    .campo-js select:focus {
        border-color: #205988;
    }

    .cancelar-js {
        width: 100%;
        height: 44px;
        border: none;
        background: white;
        color: #D96161;
        font-weight: bold;
        margin-top: 7px;
        cursor: pointer;
    }

`;

document.head.appendChild(estiloModal);

});
