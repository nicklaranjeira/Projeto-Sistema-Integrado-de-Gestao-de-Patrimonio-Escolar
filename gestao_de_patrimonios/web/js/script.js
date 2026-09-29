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

            else if (texto.includes("Patrimônios")) {
                mostrarTela(2);
            }

            else if (texto.includes("Professores")) {
                mostrarTela(4);
            }

            else if (texto.includes("Perfil")) {
                mostrarTela(8);
            }

            else if (texto.includes("Meus bens")) {
                mostrarTela(7);
            }

        });

    });

});


/* =========================================
   BOTÃO + DE PATRIMÔNIO
========================================= */

const botoesFlutuantes = document.querySelectorAll(
    ".botao-flutuante"
);

botoesFlutuantes.forEach(function (botao, indice) {

    botao.addEventListener("click", function () {

        /*
         * O primeiro botão + está na tela de patrimônios.
         * Futuramente podemos abrir uma tela específica
         * de cadastro.
         */

        if (indice === 0) {

            alert("Abrir cadastro de patrimônio.");

        }

        else {

            alert("Abrir cadastro de professor.");

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

        mostrarTela(5);

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

    const tela = document.querySelectorAll(".tela")[5];

    if (!tela) {
        return;
    }

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

    tela.appendChild(overlay);


    document
        .querySelector("#cancelar-devolucao")
        .addEventListener("click", function () {

            overlay.remove();

        });


    document
        .querySelector("#confirmar-devolucao")
        .addEventListener("click", function () {

            const motivo =
                document.querySelector(
                    "#motivo-devolucao"
                ).value;

            if (motivo === "") {

                alert(
                    "Informe o motivo da devolução."
                );

                return;

            }

            alert(
                "Devolução registrada com sucesso."
            );

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
        position: absolute;
        inset: 0;
        background: rgba(0,0,0,.5);
        display: flex;
        align-items: flex-end;
        z-index: 20;
    }

    .modal-js {
        width: 100%;
        background: white;
        border-radius: 22px 22px 0 0;
        padding: 25px 22px;
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
    }

    .campo-js input {
        width: 100%;
        height: 46px;
        border: 1px solid #ccd7e2;
        border-radius: 9px;
        padding: 0 14px;
        outline: none;
    }

    .cancelar-js {
        width: 100%;
        height: 44px;
        border: none;
        background: white;
        color: #D96161;
        font-weight: bold;
        margin-top: 7px;
    }

`;

document.head.appendChild(estiloModal);

});
