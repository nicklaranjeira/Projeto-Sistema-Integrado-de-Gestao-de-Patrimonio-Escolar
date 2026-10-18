document.addEventListener("DOMContentLoaded", function () {

/* =========================================
   TELAS
========================================= */

const telas = document.querySelectorAll(".tela");

function mostrarTela(numero) {

    telas.forEach(function (tela, indice) {

        if (indice === numero) {
            tela.style.display = "block";
        } else {
            tela.style.display = "none";
        }

    });

    window.scrollTo(0, 0);
}


/* =========================================
   INÍCIO
========================================= */

mostrarTela(0);


/* =========================================
   LOGIN
========================================= */

const botaoLogin = document.querySelector(
    ".login-container .botao-principal"
);

if (botaoLogin) {

    botaoLogin.addEventListener("click", function () {

        const email = document.querySelector("#email").value;
        const senha = document.querySelector("#senha").value;

        if (email === "" || senha === "") {

            alert("Preencha o e-mail e a senha.");

            return;
        }

        /*
         * Por enquanto o login é visual.
         * Depois podemos substituir esta parte pela
         * requisição POST da API.
         */

        mostrarTela(1);

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
   MENU INFERIOR
========================================= */

telas.forEach(function (tela, numeroTela) {

    const menuItens = tela.querySelectorAll(".menu-item");

    menuItens.forEach(function (item) {

        item.addEventListener("click", function (event) {

            event.preventDefault();

            const texto = item.textContent.trim();

            if (texto.includes("Início")) {
                mostrarTela(1);
            }

            else if (texto.includes("Patrimônios") || texto.includes("Meus bens")) {
                mostrarTela(2);
            }

            else if (texto.includes("Professores")) {
                mostrarTela(3);
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


/* =========================================
   DEVOLUÇÃO
========================================= */

const botoesDevolucao = document.querySelectorAll(
    ".botao-principal"
);

botoesDevolucao.forEach(function (botao) {

    if (
        botao.textContent.trim() ===
        "Registrar devolução"
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
                <label>Motivo da devolução</label>
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
                <label>Nome do Professor *</label>
                <input
                    type="text"
                    id="novo-prof-nome"
                    placeholder="Ex: Profa. Juliana Pereira"
                >
            </div>

            <div class="campo-js">
                <label>Matrícula *</label>
                <input
                    type="text"
                    id="novo-prof-matricula"
                    placeholder="Ex: PROF-2024-04"
                >
            </div>

            <div class="campo-js">
                <label>Departamento</label>
                <input
                    type="text"
                    id="novo-prof-depto"
                    placeholder="Ex: Informática / Matemática"
                >
            </div>

            <div class="campo-js">
                <label>E-mail Institucional</label>
                <input
                    type="email"
                    id="novo-prof-email"
                    placeholder="Ex: juliana.pereira@escola.edu.br"
                >
            </div>

            <div class="campo-js">
                <label>Telefone</label>
                <input
                    type="text"
                    id="novo-prof-telefone"
                    placeholder="Ex: (11) 98765-4321"
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

    overlay.addEventListener("click", function (event) {
        if (event.target === overlay) {
            overlay.remove();
        }
    });

    overlay.querySelector("#cancelar-cadastro-professor").addEventListener("click", function () {
        overlay.remove();
    });

    overlay.querySelector("#confirmar-cadastro-professor").addEventListener("click", function () {
        const nome = overlay.querySelector("#novo-prof-nome").value.trim();
        const matricula = overlay.querySelector("#novo-prof-matricula").value.trim();
        const depto = overlay.querySelector("#novo-prof-depto").value.trim() || "Geral";

        if (nome === "" || matricula === "") {
            alert("Preencha o nome e a matrícula do professor.");
            return;
        }

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
                alert("Detalhes do professor: " + nome);
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

        alert("Professor cadastrado com sucesso!");
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

                mostrarTela(0);

            }

        }

        else if (texto.includes("Alterar senha")) {

            alert("Abrir alteração de senha.");

        }

        else if (texto.includes("Editar telefone")) {

            alert("Abrir edição do perfil.");

        }

    });

});


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
