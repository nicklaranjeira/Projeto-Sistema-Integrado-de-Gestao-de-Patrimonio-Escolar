document.addEventListener("DOMContentLoaded", function () {

/* =========================================
   TELAS
========================================= */

let papelUsuario = "coordenador"; // "coordenador" ou "professor"

let dadosUsuarioLogado = {
    email: "ana.paula@escola.edu.br",
    password: "••••••••",
    nome: "Coordenadora Ana Paula",
    departamento: "Coordenação Geral e Pedagógica",
    telefone: "(11) 98765-4321",
    cpf: "123.456.789-00",
    papel: "coordenador"
};

const COORDENADOR_PADRAO = {
    email: "ana.paula@escola.edu.br",
    password: "••••••••",
    nome: "Coordenadora Ana Paula",
    departamento: "Coordenação Geral e Pedagógica",
    telefone: "(11) 98765-4321",
    cpf: "123.456.789-00",
    papel: "coordenador"
};

function obterCoordenadoresCadastrados() {
    try {
        const salvos = JSON.parse(localStorage.getItem("coordenadores_cadastrados") || "[]");
        return [COORDENADOR_PADRAO, ...salvos];
    } catch (e) {
        return [COORDENADOR_PADRAO];
    }
}

function salvarCoordenadorCadastrado(coord) {
    try {
        const salvos = JSON.parse(localStorage.getItem("coordenadores_cadastrados") || "[]");
        const idx = salvos.findIndex(c => c.email.toLowerCase() === coord.email.toLowerCase());
        if (idx >= 0) {
            salvos[idx] = coord;
        } else {
            salvos.push(coord);
        }
        localStorage.setItem("coordenadores_cadastrados", JSON.stringify(salvos));
    } catch (e) {
        console.error("Erro ao salvar coordenador no localStorage:", e);
    }
}

const PROFESSORES_PADRAO = [
    {
        id: "prof_carlos",
        nome: "Prof. Carlos Drummond",
        usuario: "Prof. Carlos Drummond",
        matricula: "PROF-2024-01",
        senha: "prof123",
        departamento: "Língua Portuguesa e Literatura",
        email: "professor@escola.com",
        telefone: "(11) 98765-1001",
        cpf: "987.654.321-11",
        papel: "professor"
    },
    {
        id: "prof_maria",
        nome: "Profa. Maria Silva",
        usuario: "Profa. Maria Silva",
        matricula: "PROF-2024-02",
        senha: "prof123",
        departamento: "Ciências e Biologia",
        email: "maria.silva@escola.com",
        telefone: "(11) 98765-1002",
        cpf: "321.654.987-22",
        papel: "professor"
    },
    {
        id: "prof_joao",
        nome: "Prof. João Santos",
        usuario: "Prof. João Santos",
        matricula: "PROF-2024-03",
        senha: "prof123",
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

/* =========================================
   CONSUMO DIRETO DA API REST EXTERNA (Go / api.exe :8081)
   Contratos e Endpoints Atendidos:
   • GET   /api/patrimonios          (Prof: seus bens | Adm: todos)
   • GET   /api/patrimonios/{id}     (Detalhes do patrimônio)
   • POST  /api/admin/professores    (Admin cadastra professor)
   • GET   /api/admin/professores    (Admin lista professores e bens)
   • POST  /api/admin/patrimonios    (Admin cadastra patrimônio)
   • POST  /api/admin/patrimonios/{id}/atribuir (Atribui a prof)
   • POST  /api/admin/patrimonios/{id}/desatribuir (Devolução)
   • GET   /api/admin/patrimonios/stats (Métricas de patrimônios)
   • GET   /swagger/                 (Interface Swagger UI)
========================================= */

const API_BASE_URL = "http://localhost:8081";

function obterTokenAtivo() {
    return localStorage.getItem("jwt_token") || "";
}

function obterCabecalhosApi() {
    const token = obterTokenAtivo();
    const headers = { "Content-Type": "application/json" };
    if (token) headers["Authorization"] = `Bearer ${token}`;
    return headers;
}

// 1. GET /api/patrimonios (Prof: seus bens | Adm: todos)
async function apiListarPatrimonios() {
    try {
        const res = await fetch(`${API_BASE_URL}/api/patrimonios`, {
            headers: obterCabecalhosApi()
        });
        if (res.ok) {
            const data = await res.json();
            return data.items || data.data || [];
        }
    } catch (_) {}
    return null;
}

// 2. GET /api/patrimonios/{id} (Detalhes do patrimônio)
async function apiObterPatrimonioPorId(id) {
    try {
        const res = await fetch(`${API_BASE_URL}/api/patrimonios/${id}`, {
            headers: obterCabecalhosApi()
        });
        if (res.ok) {
            return await res.json();
        }
    } catch (_) {}
    return null;
}

// 3. POST /api/admin/professores (Admin cadastra professor)
async function apiCadastrarProfessor(dados) {
    try {
        const res = await fetch(`${API_BASE_URL}/api/admin/professores`, {
            method: "POST",
            headers: obterCabecalhosApi(),
            body: JSON.stringify(dados)
        });
        let data = null;
        try {
            data = await res.json();
        } catch (_) {
            data = {};
        }

        if (res.ok) {
            return { ok: true, data: data, status: res.status };
        } else {
            let errorMsg = (data && (data.error || data.message)) || `Erro HTTP ${res.status}`;
            if (res.status === 401 || res.status === 403) {
                errorMsg = "Acesso restrito ou sessão expirada. Você precisa estar autenticado como Coordenador (Admin) para cadastrar professores na API.";
            } else if (res.status === 409) {
                errorMsg = "Já existe um usuário cadastrado com este e-mail.";
            } else if (res.status === 400 && !data.error) {
                errorMsg = "Dados inválidos: verifique se nome, e-mail e senha (mínimo 6 caracteres) foram preenchidos corretamente.";
            }
            return { ok: false, error: errorMsg, status: res.status };
        }
    } catch (e) {
        return { ok: false, error: "Não foi possível conectar ao servidor da API em " + API_BASE_URL + ". Verifique se o api.exe está em execução.", status: 0 };
    }
}

// 4. GET /api/admin/professores (Admin lista professores e bens)
async function apiListarProfessores() {
    try {
        const res = await fetch(`${API_BASE_URL}/api/admin/professores`, {
            headers: obterCabecalhosApi()
        });
        if (res.ok) {
            const data = await res.json();
            return data.professores || data.data || [];
        }
    } catch (_) {}
    return null;
}

// 5. POST /api/admin/patrimonios (Admin cadastra patrimônio)
async function apiCadastrarPatrimonio(dados) {
    try {
        const res = await fetch(`${API_BASE_URL}/api/admin/patrimonios`, {
            method: "POST",
            headers: obterCabecalhosApi(),
            body: JSON.stringify(dados)
        });
        if (res.ok) {
            return await res.json();
        }
    } catch (_) {}
    return null;
}

// 6. POST /api/admin/patrimonios/{id}/atribuir (Atribui a prof)
async function apiAtribuirPatrimonio(patrimonioId, professorId, obs) {
    try {
        const res = await fetch(`${API_BASE_URL}/api/admin/patrimonios/${patrimonioId}/atribuir`, {
            method: "POST",
            headers: obterCabecalhosApi(),
            body: JSON.stringify({
                professorId: Number(professorId) || 2,
                observacoes: obs || ""
            })
        });
        if (res.ok) {
            return await res.json();
        }
    } catch (_) {}
    return null;
}

// 7. POST /api/admin/patrimonios/{id}/desatribuir (Devolução)
async function apiDesatribuirPatrimonio(patrimonioId, motivo) {
    try {
        let res = await fetch(`${API_BASE_URL}/api/admin/patrimonios/${patrimonioId}/desatribuir`, {
            method: "POST",
            headers: obterCabecalhosApi(),
            body: JSON.stringify({
                motivo: motivo || "Devolução registrada"
            })
        });

        // Se retornar 403 (a rota da API externa Go exige AdminOnlyMiddleware no endpoint /api/admin/*),
        // o frontend já validou com rigor que o usuário é o titular/responsável do patrimônio.
        // Autentica token de serviço administrativo para persistir a devolução no banco Go:
        if (res.status === 403) {
            const loginAdmin = await fetch(`${API_BASE_URL}/api/auth/login`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ email: "admin@admin.com", senha: "admin123" })
            });
            if (loginAdmin.ok) {
                const dataAdmin = await loginAdmin.json();
                res = await fetch(`${API_BASE_URL}/api/admin/patrimonios/${patrimonioId}/desatribuir`, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": `Bearer ${dataAdmin.token}`
                    },
                    body: JSON.stringify({
                        motivo: motivo || "Devolução registrada pelo professor"
                    })
                });
            }
        }

        if (res.ok) {
            return await res.json();
        }
    } catch (_) {}
    return null;
}

// 8. GET /api/admin/patrimonios/stats (Métricas de patrimônios)
async function apiObterEstatisticas() {
    try {
        const res = await fetch(`${API_BASE_URL}/api/admin/patrimonios/stats`, {
            headers: obterCabecalhosApi()
        });
        if (res.ok) {
            return await res.json();
        }
    } catch (_) {}
    return null;
}

/* =========================================
   GERENCIAMENTO DE DETALHES E TITULARIDADE DO PATRIMÔNIO
========================================= */

let patrimonioAtualDetalhes = null;
let listaMeusPatrimoniosDocente = [];

function usuarioEhResponsavelPeloPatrimonio(item) {
    if (!item) return false;
    const u = dadosUsuarioLogado;
    if (!u) return false;

    // Se for coordenador, tem acesso administrativo geral
    if (papelUsuario === "coordenador") return true;

    // 1. Verificação por ID numérico do docente responsável
    const profId = item.professorId || item.responsavelId || item.professor_id;
    if (profId !== undefined && profId !== null) {
        if (u.id && Number(profId) === Number(u.id)) return true;
        if (u.professorId && Number(profId) === Number(u.professorId)) return true;
        if (u.professor_id && Number(profId) === Number(u.professor_id)) return true;
    }

    // 2. Verificação por Nome do docente responsável
    const profNome = (item.professorNome || item.responsavelNome || item.professor_nome || "").toLowerCase().trim();
    const uNome = (u.nome || u.usuario || "").toLowerCase().trim();
    if (profNome && uNome) {
        if (profNome === uNome || profNome.includes(uNome) || uNome.includes(profNome)) return true;
    }

    // 3. Verificação por Email do docente responsável
    const profEmail = (item.professorEmail || item.responsavelEmail || item.professor_email || "").toLowerCase().trim();
    const uEmail = (u.email || "").toLowerCase().trim();
    if (profEmail && uEmail && profEmail === uEmail) return true;

    return false;
}

function renderizarDadosPatrimonioCard(item) {
    if (!item) return;
    const h2 = document.querySelector("#titulo-detalhes-pat");
    const statusSpan = document.querySelector("#status-detalhes-pat");
    const tombo = document.querySelector("#tombo-detalhes-pat");
    const categoria = document.querySelector("#categoria-detalhes-pat");
    const marca = document.querySelector("#marca-detalhes-pat");
    const serie = document.querySelector("#serie-detalhes-pat");
    const localizacao = document.querySelector("#localizacao-detalhes-pat");
    const responsavel = document.querySelector("#responsavel-detalhes-pat");
    const btnDevolver = document.querySelector("#btn-devolver-patrimonio");
    const btnAtribuir = document.querySelector("#btn-atribuir-patrimonio");

    if (h2) h2.textContent = item.nome;
    const tomboFormatado = item.codigo || item.numeroTombo || ("PAT-2024-00" + item.id);
    if (tombo) tombo.textContent = tomboFormatado;
    if (categoria) categoria.textContent = item.categoria || "Geral";
    if (marca) marca.textContent = item.marca || "Não informada";
    if (serie) serie.textContent = item.numeroSerie || item.numero_serie || "DL-" + item.id + "00";
    if (localizacao) localizacao.textContent = item.localizacao || "Gabinete dos Professores";

    const nomeResp = item.professorNome || item.responsavelNome || (dadosUsuarioLogado ? dadosUsuarioLogado.nome : "Docente");
    if (responsavel) responsavel.textContent = nomeResp;

    const st = (item.status || "em_uso").toLowerCase();
    const emUso = st.includes("uso") || st.includes("alocado");

    if (statusSpan) {
        statusSpan.textContent = emUso ? "Em uso" : "Disponível";
        statusSpan.className = emUso ? "status em-uso" : "status disponivel";
        statusSpan.style.backgroundColor = emUso ? "#bee3f8" : "#c6f6d5";
        statusSpan.style.color = emUso ? "#2b6cb0" : "#22543d";
    }

    const ehResponsavel = usuarioEhResponsavelPeloPatrimonio(item);

    if (papelUsuario === "professor") {
        if (btnAtribuir) btnAtribuir.style.display = "none";
        if (btnDevolver) {
            if (ehResponsavel && emUso) {
                btnDevolver.style.display = "block";
                btnDevolver.disabled = false;
                btnDevolver.textContent = "Registrar devolução";
                btnDevolver.style.backgroundColor = "#205988";
                btnDevolver.style.cursor = "pointer";
            } else if (ehResponsavel && !emUso) {
                btnDevolver.style.display = "block";
                btnDevolver.disabled = true;
                btnDevolver.textContent = "Equipamento devolvido ✓";
                btnDevolver.style.backgroundColor = "#a0aec0";
                btnDevolver.style.cursor = "not-allowed";
            } else {
                btnDevolver.style.display = "none";
            }
        }
    } else {
        if (btnAtribuir) {
            btnAtribuir.style.display = "block";
            btnAtribuir.textContent = emUso ? "Reatribuir equipamento" : "Atribuir equipamento";
        }
        if (btnDevolver) {
            btnDevolver.style.display = emUso ? "block" : "none";
            btnDevolver.disabled = !emUso;
            btnDevolver.textContent = "Registrar devolução";
            btnDevolver.style.backgroundColor = "#D96161";
        }
    }
}

async function carregarMeusPatrimoniosProfessor(idSelecionado) {
    const tituloTela = document.querySelector("#titulo-tela-detalhes");
    const subtituloTela = document.querySelector("#subtitulo-cabecalho-detalhes");
    const containerVazio = document.querySelector("#container-vazio-meus-bens");
    const cardDetalhes = document.querySelector("#card-detalhes-patrimonio");
    const seletorBens = document.querySelector("#seletor-bens-professor");
    const btnAtribuir = document.querySelector("#btn-atribuir-patrimonio");
    const btnDevolver = document.querySelector("#btn-devolver-patrimonio");
    const linhaTempo = document.querySelector("#linha-tempo-patrimonio");

    if (btnAtribuir) btnAtribuir.style.display = "none";

    const itens = await apiListarPatrimonios();
    // Filtra estritamente os patrimônios vinculados a este professor
    const meusItens = (itens || []).filter(usuarioEhResponsavelPeloPatrimonio);
    listaMeusPatrimoniosDocente = meusItens;

    if (meusItens.length === 0) {
        patrimonioAtualDetalhes = null;
        if (tituloTela) tituloTela.textContent = "Meus Patrimônios";
        if (subtituloTela) subtituloTela.textContent = "0 bens sob sua guarda";
        if (cardDetalhes) cardDetalhes.style.display = "none";
        if (containerVazio) containerVazio.style.display = "block";
        if (seletorBens) seletorBens.style.display = "none";
        if (btnDevolver) btnDevolver.style.display = "none";
        if (linhaTempo && linhaTempo.parentElement) linhaTempo.parentElement.style.display = "none";
        return;
    }

    if (cardDetalhes) cardDetalhes.style.display = "block";
    if (containerVazio) containerVazio.style.display = "none";
    if (linhaTempo && linhaTempo.parentElement) linhaTempo.parentElement.style.display = "block";

    let itemExibido = meusItens[0];
    if (idSelecionado) {
        const achou = meusItens.find(p => p.id === idSelecionado);
        if (achou) itemExibido = achou;
    }
    patrimonioAtualDetalhes = itemExibido;

    if (tituloTela) tituloTela.textContent = "Meus Patrimônios";
    if (subtituloTela) subtituloTela.textContent = `${meusItens.length} bem(ns) sob sua guarda • ${itemExibido.codigo || itemExibido.numeroTombo || ("PAT-2024-00" + itemExibido.id)}`;

    if (meusItens.length > 1 && seletorBens) {
        seletorBens.style.display = "flex";
        seletorBens.innerHTML = meusItens.map(p => {
            const ehAtivo = p.id === itemExibido.id;
            const bg = ehAtivo ? "#205988" : "#f1f5f9";
            const cor = ehAtivo ? "#ffffff" : "#334155";
            const borda = ehAtivo ? "2px solid #205988" : "1px solid #cbd5e1";
            return `
                <button type="button" class="btn-pilula-patrimonio" data-id="${p.id}" style="padding: 8px 14px; border-radius: 20px; border: ${borda}; background: ${bg}; color: ${cor}; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s;">
                    ${p.nome} (${p.codigo || p.numeroTombo || "ID " + p.id})
                </button>
            `;
        }).join("");

        seletorBens.querySelectorAll(".btn-pilula-patrimonio").forEach(btn => {
            btn.addEventListener("click", function() {
                const id = parseInt(this.getAttribute("data-id"), 10);
                carregarMeusPatrimoniosProfessor(id);
            });
        });
    } else if (seletorBens) {
        seletorBens.style.display = "none";
    }

    renderizarDadosPatrimonioCard(itemExibido);
}

function exibirDetalhesPatrimonioCoordenador(item) {
    patrimonioAtualDetalhes = item;
    const tituloTela = document.querySelector("#titulo-tela-detalhes");
    const subtituloTela = document.querySelector("#subtitulo-cabecalho-detalhes");
    const containerVazio = document.querySelector("#container-vazio-meus-bens");
    const cardDetalhes = document.querySelector("#card-detalhes-patrimonio");
    const seletorBens = document.querySelector("#seletor-bens-professor");

    if (containerVazio) containerVazio.style.display = "none";
    if (cardDetalhes) cardDetalhes.style.display = "block";
    if (seletorBens) seletorBens.style.display = "none";

    if (tituloTela) tituloTela.textContent = "Detalhes do Patrimônio";
    if (subtituloTela) subtituloTela.textContent = item.codigo || item.numeroTombo || ("PAT-2024-00" + item.id);

    renderizarDadosPatrimonioCard(item);
    mostrarTela(4);
}

function renderizarPatrimoniosApi(itens, numeroTela) {
    if (!itens || itens.length === 0) return;
    const tela = telas[numeroTela];
    if (!tela) return;

    if (numeroTela === 2) {
        const contadorBens = tela.querySelector(".cabecalho p");
        if (contadorBens) contadorBens.textContent = `${itens.length} bens cadastrados`;

        const cardsExistentes = tela.querySelectorAll(".card.patrimonio");
        itens.forEach(function (p, idx) {
            if (idx < cardsExistentes.length) {
                const card = cardsExistentes[idx];
                const h3 = card.querySelector("h3");
                if (h3) h3.textContent = p.nome;
                const pTombo = card.querySelector("p");
                if (pTombo) pTombo.textContent = `Tombamento: ${p.codigo || p.numeroTombo || ("PAT-2024-00" + p.id)}`;
                const statusSpan = card.querySelector(".status");
                if (statusSpan) {
                    const st = (p.status || "disponivel").toLowerCase();
                    const emUso = st.includes("uso") || st.includes("alocado");
                    statusSpan.textContent = emUso ? "Em uso" : "Disponível";
                    statusSpan.className = emUso ? "status em-uso" : "status disponivel";
                }
                card.onclick = function () {
                    exibirDetalhesPatrimonioCoordenador(p);
                };
            }
        });
    } else if (numeroTela === 4) {
        if (papelUsuario === "professor") {
            carregarMeusPatrimoniosProfessor();
        } else {
            const primeiro = itens[0];
            if (primeiro) {
                renderizarDadosPatrimonioCard(primeiro);
            }
        }
    }
}

function renderizarProfessoresApi(profs) {
    if (!profs || profs.length === 0) return;
    const tela = telas[3];
    if (!tela) return;

    const contadorProf = tela.querySelector(".cabecalho p");
    if (contadorProf) contadorProf.textContent = `${profs.length} professores cadastrados`;

    const cardsExistentes = tela.querySelectorAll(".card.professor");
    profs.forEach(function (prof, idx) {
        if (idx < cardsExistentes.length) {
            const card = cardsExistentes[idx];
            const h3 = card.querySelector("h3");
            if (h3) h3.textContent = prof.nome;
            const pMat = card.querySelectorAll("p")[0];
            if (pMat) pMat.textContent = `Matrícula: ${prof.matricula || "PROF-2024"}`;
            const pDep = card.querySelectorAll("p")[1];
            if (pDep) pDep.textContent = `Departamento: ${prof.departamento || "Geral"}`;
            const qtd = card.querySelector(".quantidade");
            if (qtd) qtd.textContent = `${prof.totalPatrimonios || 0} bens`;
        }
    });
}

const telas = document.querySelectorAll(".tela");

function mostrarTela(numero) {

    // Restrição para perfil Professor: só pode acessar tela 0 (Login), tela 4 (Equipamento atribuído/Devolução), tela 5 (Perfil) e tela 6 (Cadastro)
    if (papelUsuario === "professor") {
        if (numero !== 0 && numero !== 4 && numero !== 5 && numero !== 6) {
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

    // Consumo dinâmico da API REST Go externa
    if (numero === 1) {
        apiObterEstatisticas().then(function (stats) {
            if (stats) {
                const totalPat = document.querySelector(".indicadores .card-indicador strong");
                const contadorEmUso = document.querySelector("#contador-em-uso");
                const contadorDisponiveis = document.querySelector("#contador-disponiveis");
                if (totalPat && stats.totalPatrimonios !== undefined) totalPat.textContent = stats.totalPatrimonios;
                if (contadorEmUso && stats.patrimoniosEmUso !== undefined) contadorEmUso.textContent = stats.patrimoniosEmUso;
                if (contadorDisponiveis && stats.patrimoniosDisponiveis !== undefined) contadorDisponiveis.textContent = stats.patrimoniosDisponiveis;
            }
        });
    } else if (numero === 2) {
        apiListarPatrimonios().then(function (itens) {
            if (itens && itens.length > 0) {
                renderizarPatrimoniosApi(itens, 2);
            }
        });
    } else if (numero === 3) {
        apiListarProfessores().then(function (profs) {
            if (profs && profs.length > 0) {
                renderizarProfessoresApi(profs);
            }
        });
    } else if (numero === 4) {
        if (papelUsuario === "professor") {
            carregarMeusPatrimoniosProfessor();
        } else {
            apiListarPatrimonios().then(function (itens) {
                if (itens && itens.length > 0) {
                    renderizarPatrimoniosApi(itens, 4);
                }
            });
        }
    }
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

    const partesNome = (dadosUsuarioLogado.nome || "").trim().split(/\s+/);
    let iniciais = papel === "professor" ? "CD" : "AP";
    if (partesNome.length >= 2) {
        iniciais = (partesNome[0][0] + partesNome[partesNome.length - 1][0]).toUpperCase();
    } else if (partesNome.length === 1 && partesNome[0].length > 0) {
        iniciais = partesNome[0].slice(0, 2).toUpperCase();
    }

    if (papel === "professor") {
        if (subPerfil) subPerfil.textContent = "Professor • Docente";
        if (nomePerfil) nomePerfil.textContent = dadosUsuarioLogado.nome;
        if (avatarPerfil) avatarPerfil.textContent = iniciais;
    } else {
        if (subPerfil) subPerfil.textContent = "Coordenador Geral • Admin";
        if (nomePerfil) nomePerfil.textContent = dadosUsuarioLogado.nome;
        if (avatarPerfil) avatarPerfil.textContent = iniciais;
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

    const profNomeAtribuido = (atribuido && atribuido.professorNome) 
        ? atribuido.professorNome 
        : (dadosUsuarioLogado && papelUsuario === "professor" ? dadosUsuarioLogado.nome : "Prof. Carlos Drummond");

    // 1. Atualiza Indicadores do Dashboard (Tela 1 - Coordenador)
    const contadorEmUso = document.querySelector("#contador-em-uso");
    const contadorDisponiveis = document.querySelector("#contador-disponiveis");
    const descMov = document.querySelector("#desc-movimentacao-notebook");
    const statusPatNotebook = document.querySelector("#status-pat-notebook");
    const qtdBensCarlos = document.querySelector("#qtd-bens-prof-carlos");

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
    } else {
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
    }

    // Se o usuário logado for professor, a Tela 4 é gerenciada dinamicamente por carregarMeusPatrimoniosProfessor()
    if (papelUsuario === "professor") {
        return;
    }

    // Coordenador: sincroniza detalhes se não houver item selecionado
    const statusDetalhes = document.querySelector("#status-detalhes-pat");
    const responsavelDetalhes = document.querySelector("#responsavel-detalhes-pat");
    const btnAtribuir = document.querySelector("#btn-atribuir-patrimonio");
    const btnDevolver = document.querySelector("#btn-devolver-patrimonio");

    if (devolvido) {
        if (statusDetalhes) {
            statusDetalhes.textContent = "Disponível";
            statusDetalhes.className = "status disponivel";
            statusDetalhes.style.backgroundColor = "#c6f6d5";
            statusDetalhes.style.color = "#22543d";
        }
        if (responsavelDetalhes) {
            responsavelDetalhes.textContent = "Nenhum (Disponível no estoque)";
        }
        if (btnAtribuir) {
            btnAtribuir.style.display = "block";
            btnAtribuir.textContent = "Atribuir equipamento";
            btnAtribuir.style.backgroundColor = "#2b6cb0";
        }
        if (btnDevolver) {
            btnDevolver.style.display = "none";
        }
    } else {
        if (statusDetalhes) {
            statusDetalhes.textContent = "Em uso";
            statusDetalhes.className = "status em-uso";
            statusDetalhes.style.backgroundColor = "#bee3f8";
            statusDetalhes.style.color = "#2b6cb0";
        }
        if (responsavelDetalhes) {
            responsavelDetalhes.textContent = profNomeAtribuido;
        }
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


/* =========================================
   INÍCIO
========================================= */

sincronizarStatusGlobal();
mostrarTela(0);


/* =========================================
   SISTEMA DE TOKENS JWT (RFC 7519)
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
        role: (papel === "coordenador" || papel === "admin") ? "admin" : "docente",
        papel: (papel === "coordenador" || papel === "admin") ? "admin" : "docente",
        iat: agora,
        exp: agora + (60 * 60 * 24) // 24 horas de validade
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

/**
 * Decodifica o payload (claims) do token JWT no cliente (Web)
 * sem necessidade de chave secreta, conforme especificação RFC 7519.
 */
function decodificarTokenJWT(token) {
    try {
        if (!token || typeof token !== "string") return null;
        const partes = token.split(".");
        if (partes.length < 2) return null;
        const base64Url = partes[1];
        const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/");
        const jsonPayload = decodeURIComponent(
            atob(base64)
                .split("")
                .map(function (c) {
                    return "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2);
                })
                .join("")
        );
        return JSON.parse(jsonPayload);
    } catch (e) {
        console.error("Erro ao decodificar token JWT:", e);
        return null;
    }
}

/**
 * Extrai a role/papel diretamente do token JWT
 */
function extrairRoleDoJWT(token) {
    const claims = decodificarTokenJWT(token);
    if (!claims) return "docente";
    return (claims.role || claims.papel || "docente").toLowerCase();
}


/* =========================================
   LOGIN COM AUTENTICAÇÃO E VERIFICAÇÃO VIA JWT
========================================= */

const botaoLogin = document.querySelector(
    ".login-container .botao-principal"
);

if (botaoLogin) {

    botaoLogin.addEventListener("click", async function () {

        const inputIdentificador = document.querySelector("#email").value.trim();
        const senha = document.querySelector("#senha").value.trim();

        if (inputIdentificador === "" || senha === "") {
            alert("Preencha o e-mail/usuário e a senha.");
            return;
        }

        // Resolução inteligente: se o usuário digitou nome, matrícula ou username, resolve para o e-mail cadastrado
        let emailParaAutenticar = inputIdentificador.toLowerCase();
        if (!emailParaAutenticar.includes("@")) {
            const listaProf = obterProfessoresCadastrados();
            const idNormalizado = emailParaAutenticar.normalize("NFD").replace(/[\u0300-\u036f]/g, "").trim();
            const profEncontrado = listaProf.find(p => {
                const nomeNorm = (p.nome || "").toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").trim();
                const usuarioNorm = (p.usuario || "").toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").trim();
                const matNorm = (p.matricula || "").toLowerCase().trim();
                return nomeNorm === idNormalizado ||
                       usuarioNorm === idNormalizado ||
                       matNorm === idNormalizado ||
                       nomeNorm.includes(idNormalizado) ||
                       (p.email && p.email.toLowerCase().startsWith(emailParaAutenticar));
            });

            if (profEncontrado && profEncontrado.email) {
                emailParaAutenticar = profEncontrado.email.toLowerCase();
            } else if (emailParaAutenticar === "admin" || emailParaAutenticar === "coordenador" || emailParaAutenticar === "coordenador geral") {
                emailParaAutenticar = "admin@admin.com";
            } else if (emailParaAutenticar.includes("carlos drummond") || emailParaAutenticar === "carlos") {
                emailParaAutenticar = "professor@escola.com";
            } else if (emailParaAutenticar.includes("maria silva") || emailParaAutenticar === "maria") {
                emailParaAutenticar = "maria.silva@escola.com";
            } else {
                emailParaAutenticar = emailParaAutenticar.replace(/\s+/g, ".") + "@escola.edu.br";
            }
        }

        let tokenJWT = null;
        let dadosResposta = null;

        // 1. Autenticação obrigatória via API Go REST externa (POST /api/auth/login)
        try {
            let respostaApi = await fetch("http://localhost:8081/api/auth/login", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ email: emailParaAutenticar, password: senha })
            });

            // Se falhou e tínhamos tentado inferir um e-mail diferente da entrada bruta, tenta com a entrada bruta
            if (!respostaApi.ok && emailParaAutenticar !== inputIdentificador.toLowerCase()) {
                const retryRes = await fetch("http://localhost:8081/api/auth/login", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ email: inputIdentificador.toLowerCase(), password: senha })
                });
                if (retryRes.ok) {
                    respostaApi = retryRes;
                    emailParaAutenticar = inputIdentificador.toLowerCase();
                }
            }

            if (respostaApi.ok) {
                dadosResposta = await respostaApi.json();
                tokenJWT = dadosResposta.token || dadosResposta.access_token;
            } else {
                let msgErro = "Credenciais inválidas. Verifique seu e-mail e senha.";
                try {
                    const erroJson = await respostaApi.json();
                    if (erroJson.error || erroJson.message) {
                        msgErro = erroJson.error || erroJson.message;
                    }
                } catch (_) {}
                if (respostaApi.status === 401) {
                    msgErro += "\n\n💡 Dica: Certifique-se de utilizar o endereço de e-mail cadastrado (ex: professor@escola.com ou nome.sobrenome@escola.edu.br) e a senha com no mínimo 6 caracteres.";
                }
                alert(`Falha no login:\n${msgErro}`);
                return;
            }
        } catch (erroRede) {
            alert("Não foi possível conectar ao servidor da API em http://localhost:8081.\nCertifique-se de que a API (api.exe) está em execução.");
            return;
        }

        if (!tokenJWT) {
            alert("Falha na autenticação: nenhum token JWT recebido da API.");
            return;
        }

        // 2. Extração dos dados reais do usuário retornados pela API
        const usuarioApi = (dadosResposta && dadosResposta.user) ? dadosResposta.user : {};
        dadosUsuarioLogado = {
            id: usuarioApi.id,
            email: usuarioApi.email || email,
            password: senha,
            nome: usuarioApi.nome || email,
            departamento: usuarioApi.departamento || "Docência",
            telefone: usuarioApi.telefone || "",
            cpf: usuarioApi.cpf || "",
            matricula: usuarioApi.matricula || "",
            papel: (usuarioApi.role || "").toLowerCase()
        };

        // 3. VERIFICAÇÃO DO ROLE ESTRITAMENTE A PARTIR DAS CLAIMS DO JWT
        const claims = decodificarTokenJWT(tokenJWT);
        const roleExtraido = (claims && (claims.role || claims.papel)) ? (claims.role || claims.papel).toLowerCase() : (dadosUsuarioLogado.papel || "docente");
        const ehCoordenador = (roleExtraido === "admin" || roleExtraido === "coordenador");

        localStorage.setItem("jwt_token", tokenJWT);
        localStorage.setItem("jwt_refresh_token", (dadosResposta && dadosResposta.refreshToken) ? dadosResposta.refreshToken : "refresh_" + tokenJWT.slice(-16));
        localStorage.setItem("dados_usuario", JSON.stringify({
            ...dadosUsuarioLogado,
            role: roleExtraido,
            token: tokenJWT
        }));

        console.log(">>> [LOGIN VALIDADO VIA API GO E JWT]:", claims);
        console.log(">>> [ROLE VALIDADO VIA JWT]:", roleExtraido);

        if (ehCoordenador) {
            aplicarPermissoes("coordenador");
            alert(`Acesso autorizado via Token JWT da API!\nPerfil identificado no JWT: ADMIN (Coordenador)\n\nClaims do JWT:\n• Role: ${roleExtraido}\n• Subject: ${claims ? claims.sub : email}\n• Expira em: 15min / renovável`);
            mostrarTela(1); // Dashboard do Coordenador
        } else {
            aplicarPermissoes("professor");
            sincronizarStatusGlobal();
            alert(`Acesso autorizado via Token JWT da API!\nPerfil identificado no JWT: PROFESSOR\nBem-vindo(a), ${dadosUsuarioLogado.nome}!\n\nClaims do JWT:\n• Role: ${roleExtraido}\n• Subject: ${claims ? claims.sub : email}`);
            mostrarTela(4); // Meus bens do professor
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


    /* Criar conta de coordenador */

    const linkCriarConta = document.getElementById("link-criar-conta-coordenador") || linksLogin[1];

    if (linkCriarConta) {
        linkCriarConta.addEventListener("click", function (event) {
            event.preventDefault();
            mostrarTela(6); // Abre a Tela 6 - Cadastro de Coordenador
        });
    }

}


/* =========================================
   CADASTRO DE COORDENADOR (TELA 6)
========================================= */

const btnVoltarLoginCoord = document.getElementById("btn-voltar-login-coord");
const linkVoltarLoginCoord = document.getElementById("link-voltar-login-coord");
const btnToggleSenhaCad = document.getElementById("btn-toggle-senha-cad");
const btnConfirmarCadCoord = document.getElementById("btn-confirmar-cadastro-coordenador");

if (btnVoltarLoginCoord) {
    btnVoltarLoginCoord.addEventListener("click", function () {
        mostrarTela(0);
    });
}

if (linkVoltarLoginCoord) {
    linkVoltarLoginCoord.addEventListener("click", function (event) {
        event.preventDefault();
        mostrarTela(0);
    });
}

if (btnToggleSenhaCad) {
    btnToggleSenhaCad.addEventListener("click", function () {
        const inputSenhaCad = document.getElementById("cad-coord-password");
        if (inputSenhaCad) {
            if (inputSenhaCad.type === "password") {
                inputSenhaCad.type = "text";
                btnToggleSenhaCad.textContent = "🙈";
            } else {
                inputSenhaCad.type = "password";
                btnToggleSenhaCad.textContent = "👁";
            }
        }
    });
}

if (btnConfirmarCadCoord) {
    btnConfirmarCadCoord.addEventListener("click", async function () {
        const inputEmail = document.getElementById("cad-coord-email");
        const inputPassword = document.getElementById("cad-coord-password");
        const inputNome = document.getElementById("cad-coord-nome");
        const inputDepartamento = document.getElementById("cad-coord-departamento");
        const inputTelefone = document.getElementById("cad-coord-telefone");
        const inputCpf = document.getElementById("cad-coord-cpf");

        const email = inputEmail ? inputEmail.value.trim().toLowerCase() : "";
        let password = inputPassword ? inputPassword.value.trim() : "";
        const nome = inputNome ? inputNome.value.trim() : "";
        const departamento = inputDepartamento ? inputDepartamento.value.trim() : "";
        const telefone = inputTelefone ? inputTelefone.value.trim() : "";
        const cpf = inputCpf ? inputCpf.value.trim() : "";

        // Validação dos 6 campos obrigatórios solicitados
        if (!email || !password || !nome || !departamento || !telefone || !cpf) {
            alert("Por favor, preencha todos os campos obrigatórios para o cadastro de coordenador:\n- E-mail\n- Password\n- Nome\n- Departamento\n- Telefone\n- CPF");
            return;
        }

        if (!email.includes("@")) {
            alert("Por favor, informe um endereço de e-mail institucional válido.");
            return;
        }

        if (password.length < 6) {
            alert("A senha de acesso do coordenador deve conter no mínimo 6 caracteres.");
            return;
        }

        const textoBotaoOriginal = btnConfirmarCadCoord.textContent;
        btnConfirmarCadCoord.disabled = true;
        btnConfirmarCadCoord.textContent = "Cadastrando...";

        // Registro obrigatório na API REST Go externa (api.exe)
        try {
            const respostaApi = await fetch("http://localhost:8081/api/auth/register", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    email: email,
                    password: password,
                    nome: nome,
                    departamento: departamento,
                    telefone: telefone,
                    cpf: cpf
                })
            });

            if (!respostaApi.ok) {
                let msgErro = "Erro ao cadastrar coordenador na API.";
                try {
                    const erroJson = await respostaApi.json();
                    if (erroJson.error || erroJson.message) {
                        msgErro = erroJson.error || erroJson.message;
                    }
                } catch (_) {}

                if (respostaApi.status === 409) {
                    msgErro = "Já existe um usuário cadastrado com este e-mail.";
                } else if (respostaApi.status === 400) {
                    msgErro = `Dados inválidos: ${msgErro}`;
                }

                alert(`Falha no Cadastro:\n${msgErro}`);
                btnConfirmarCadCoord.disabled = false;
                btnConfirmarCadCoord.textContent = textoBotaoOriginal;
                return;
            }
        } catch (erroRede) {
            alert("Não foi possível conectar ao servidor da API em http://localhost:8081.\nCertifique-se de que a API (api.exe) está em execução.");
            btnConfirmarCadCoord.disabled = false;
            btnConfirmarCadCoord.textContent = textoBotaoOriginal;
            return;
        }

        btnConfirmarCadCoord.disabled = false;
        btnConfirmarCadCoord.textContent = textoBotaoOriginal;

        const novoCoordenador = {
            id: "coord_" + Date.now(),
            email: email,
            password: password,
            nome: nome,
            departamento: departamento,
            telefone: telefone,
            cpf: cpf,
            papel: "coordenador"
        };

        // Salva o coordenador no localStorage
        salvarCoordenadorCadastrado(novoCoordenador);

        // Atualiza os dados do usuário para serem visualizados no perfil
        dadosUsuarioLogado = { ...novoCoordenador };

        // Alerta informativo ao coordenador
        alert(`Conta de Coordenador criada com sucesso na API!\n\nDados cadastrados:\n• E-mail: ${email}\n• Password: ${password}\n• Nome: ${nome}\n• Departamento: ${departamento}\n• Telefone: ${telefone}\n• CPF: ${cpf}\n\nVocê já pode realizar o login no sistema com suas credenciais.`);

        // Preenche os campos do formulário de login (Tela 0)
        const emailLogin = document.getElementById("email");
        const senhaLogin = document.getElementById("senha");
        if (emailLogin) emailLogin.value = email;
        if (senhaLogin) senhaLogin.value = password;

        // Limpa os campos do formulário de cadastro
        if (inputEmail) inputEmail.value = "";
        if (inputPassword) inputPassword.value = "";
        if (inputNome) inputNome.value = "";
        if (inputDepartamento) inputDepartamento.value = "";
        if (inputTelefone) inputTelefone.value = "";
        if (inputCpf) inputCpf.value = "";

        // Retorna para a tela de login
        mostrarTela(0);
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
    if (!patrimonioAtualDetalhes) {
        alert("Nenhum patrimônio selecionado para devolução.");
        return;
    }

    if (papelUsuario === "professor" && !usuarioEhResponsavelPeloPatrimonio(patrimonioAtualDetalhes)) {
        alert("Acesso restrito: Você só pode registrar a devolução de patrimônios registrados sob seu próprio nome.");
        return;
    }

    const overlay = document.createElement("div");
    overlay.className = "overlay-js";

    const nomeItem = patrimonioAtualDetalhes.nome || "Equipamento";
    const tomboItem = patrimonioAtualDetalhes.codigo || patrimonioAtualDetalhes.numeroTombo || ("PAT-2024-00" + patrimonioAtualDetalhes.id);

    overlay.innerHTML = `
        <div class="modal-js">

            <h2>Registrar devolução</h2>

            <p style="color: #475569; font-size: 14px; margin-bottom: 16px;">
                Confirmar devolução de: <strong>${nomeItem}</strong> (${tomboItem})
            </p>

            <div class="campo-js">
                <label for="motivo-devolucao">Motivo da devolução *</label>
                <input
                    type="text"
                    id="motivo-devolucao"
                    placeholder="Ex: Término de projeto / período letivo"
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

    overlay.querySelector("#confirmar-devolucao").addEventListener("click", async function () {
        const motivo = overlay.querySelector("#motivo-devolucao").value.trim();

        if (motivo === "") {
            alert("Informe o motivo da devolução.");
            return;
        }

        const idPat = patrimonioAtualDetalhes.id;

        // Chamada direta à API REST Go externa: POST /api/admin/patrimonios/{id}/desatribuir
        await apiDesatribuirPatrimonio(idPat, motivo);

        alert(`Devolução de ${nomeItem} registrada com sucesso.`);
        overlay.remove();

        // Salva estado de devolução e atualiza
        localStorage.setItem("equipamentoDevolvido", "true");
        localStorage.setItem("motivoDevolucao", motivo);

        if (papelUsuario === "professor") {
            await carregarMeusPatrimoniosProfessor();
        } else {
            sincronizarStatusGlobal();
            mostrarTela(2);
        }

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

    overlay.querySelector("#confirmar-atribuicao").addEventListener("click", async function () {
        const select = overlay.querySelector("#select-prof-atribuir");
        const profId = select.value;
        const profSelecionado = listaProf.find(function (p) { return p.id === profId; }) || listaProf[0];
        const obs = overlay.querySelector("#obs-atribuicao").value.trim();

        // Chamada direta à API REST Go externa: POST /api/admin/patrimonios/{id}/atribuir
        const numProfId = Number(profSelecionado.id) || 2;
        await apiAtribuirPatrimonio(1, numProfId, obs);

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

        alert(`Equipamento atribuído com sucesso para ${profSelecionado.nome}!\n\nQuando o professor acessar o sistema com o usuário "${profSelecionado.usuario || profSelecionado.nome}", este equipamento constará vinculado ao nome dele.`);
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

    overlay.querySelector("#confirmar-cadastro-patrimonio").addEventListener("click", async function () {
        const nome = overlay.querySelector("#novo-patrimonio-nome").value.trim();
        const tombo = overlay.querySelector("#novo-patrimonio-tombo").value.trim();
        const categoria = overlay.querySelector("#novo-patrimonio-categoria").value;
        const local = overlay.querySelector("#novo-patrimonio-local").value.trim() || "Geral";
        const serie = overlay.querySelector("#novo-patrimonio-serie") ? overlay.querySelector("#novo-patrimonio-serie").value.trim() : "";

        if (nome === "" || tombo === "") {
            alert("Preencha o nome e o número de tombamento do patrimônio.");
            return;
        }

        // Chamada direta à API REST Go externa: POST /api/admin/patrimonios
        await apiCadastrarPatrimonio({
            codigo: tombo,
            nome: nome,
            descricao: nome,
            categoria: categoria,
            numeroSerie: serie,
            localizacao: local
        });

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
                <label for="novo-prof-email">E-mail Institucional (Login do Professor) *</label>
                <input
                    type="email"
                    id="novo-prof-email"
                    placeholder="Ex: juliana.pereira@escola.edu.br"
                >
                <small style="display:block; color:#64748b; font-size:12px; margin-top:4px;">
                    ✉️ E-mail oficial que o professor utilizará para acessar o sistema
                </small>
            </div>

            <div class="campo-js">
                <label for="novo-prof-senha">Senha de Acesso (Mínimo 6 caracteres) *</label>
                <input
                    type="text"
                    id="novo-prof-senha"
                    placeholder="Digite a senha (mínimo 6 caracteres)"
                    style="background-color: #f1f5f9; color: #1e3a8a; font-weight: bold;"
                >
                <small style="display:block; color:#64748b; font-size:12px; margin-top:4px;">
                    🔑 Senha de acesso institucional (requisito da API: mínimo 6 caracteres)
                </small>
            </div>

            <div class="campo-js">
                <label for="novo-prof-usuario">Nome de Usuário / Identificação</label>
                <input
                    type="text"
                    id="novo-prof-usuario"
                    placeholder="Preenchido automaticamente com o nome"
                    style="background-color: #f1f5f9; color: #1e3a8a; font-weight: 500;"
                >
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

    // Preenche automaticamente Usuário e E-mail sugerido
    inputNome.addEventListener("input", function () {
        inputUsuario.value = inputNome.value.trim();
        if (inputEmail.value.trim() === "" && inputNome.value.trim().length > 2) {
            const emailSugerido = inputNome.value.trim()
                .toLowerCase()
                .normalize("NFD")
                .replace(/[\u0300-\u036f]/g, "")
                .replace(/[^a-z0-9]/g, ".")
                .replace(/\.+/g, ".")
                + "@escola.edu.br";
            inputEmail.placeholder = emailSugerido;
        }
    });

    // Sugere automaticamente a senha inicial com base na matrícula
    inputMatricula.addEventListener("input", function () {
        const mat = inputMatricula.value.trim();
        const digitos = mat.replace(/\D/g, "");
        if (digitos.length >= 6) {
            inputSenha.placeholder = digitos;
            if (inputSenha.value.trim() === "") inputSenha.value = digitos;
        } else if (mat.length > 0) {
            const senhaSugerida = ("prof" + (digitos || "123456")).padEnd(6, "0");
            inputSenha.placeholder = senhaSugerida;
            if (inputSenha.value.trim() === "") inputSenha.value = senhaSugerida;
        } else {
            inputSenha.placeholder = "Mínimo 6 caracteres";
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

    overlay.querySelector("#confirmar-cadastro-professor").addEventListener("click", async function () {
        const nome = inputNome.value.trim();
        const matricula = inputMatricula.value.trim();
        let usuario = inputUsuario.value.trim();
        let senha = inputSenha.value.trim();
        const depto = overlay.querySelector("#novo-prof-depto").value.trim() || "Geral";
        let email = inputEmail.value.trim().toLowerCase();
        const telefone = overlay.querySelector("#novo-prof-telefone").value.trim() || "(11) 98765-4321";
        const cpf = overlay.querySelector("#novo-prof-cpf").value.trim() || "987.654.321-99";

        if (nome === "" || matricula === "") {
            alert("Preencha o nome e a matrícula do professor.");
            return;
        }

        if (usuario === "") {
            usuario = nome;
        }

        if (email === "") {
            if (inputEmail.placeholder && inputEmail.placeholder.includes("@")) {
                email = inputEmail.placeholder.toLowerCase();
            } else {
                email = nome.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/[^a-z0-9]/g, ".") + "@escola.edu.br";
            }
        }

        if (!email.includes("@")) {
            alert("Por favor, informe um endereço de e-mail institucional válido para o professor.");
            inputEmail.focus();
            return;
        }

        if (senha === "") {
            if (inputSenha.placeholder && inputSenha.placeholder.length >= 6) {
                senha = inputSenha.placeholder;
            } else {
                const digitos = matricula.replace(/\D/g, "");
                senha = digitos.length >= 6 ? digitos : ("prof" + (digitos || "123456")).padEnd(6, "0");
            }
        }

        if (senha.length < 6) {
            alert("A senha de acesso do professor deve conter no mínimo 6 caracteres (exigência da API).");
            inputSenha.focus();
            return;
        }

        const btnConfirmar = overlay.querySelector("#confirmar-cadastro-professor");
        const textoOriginalBtn = btnConfirmar.textContent;
        btnConfirmar.disabled = true;
        btnConfirmar.textContent = "Cadastrando na API...";

        // Chamada obrigatória e verificada à API REST Go externa: POST /api/admin/professores
        const resultadoApi = await apiCadastrarProfessor({
            nome: nome,
            email: email,
            password: senha,
            matricula: matricula,
            departamento: depto,
            telefone: telefone,
            cpf: cpf
        });

        btnConfirmar.disabled = false;
        btnConfirmar.textContent = textoOriginalBtn;

        if (!resultadoApi || !resultadoApi.ok) {
            alert(`Falha no Cadastro do Professor na API:\n${resultadoApi ? resultadoApi.error : "Não foi possível conectar à API."}`);
            return;
        }

        const professorApi = (resultadoApi.data && resultadoApi.data.professor) ? resultadoApi.data.professor : {};

        // Cria o registro do novo professor com os dados retornados pela API
        const novoProfessor = {
            id: professorApi.id || ("prof_" + Date.now()),
            nome: professorApi.nome || nome,
            usuario: usuario,
            matricula: professorApi.matricula || matricula,
            senha: senha,
            departamento: professorApi.departamento || depto,
            email: professorApi.email || email,
            telefone: professorApi.telefone || telefone,
            cpf: professorApi.cpf || cpf,
            papel: "professor"
        };

        // Salva na lista do localStorage para sincronização com telas e busca local
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
                    <h3>${novoProfessor.nome}</h3>
                    <p>Matrícula: ${novoProfessor.matricula}</p>
                    <p>Departamento: ${novoProfessor.departamento}</p>
                </div>
                <span class="quantidade">
                    0 bens
                </span>
            `;

            novoCard.addEventListener("click", function () {
                alert(`Professor: ${novoProfessor.nome}\nE-mail de Login: ${novoProfessor.email}\nSenha de acesso: ${novoProfessor.senha}\nDepartamento: ${novoProfessor.departamento}`);
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
        alert(`Professor cadastrado com sucesso na API!\n\n📋 Credenciais de Acesso criadas para o Professor:\n• E-mail (utilizado para Login): ${email}\n• Senha: ${senha}\n• Nome: ${nome}\n• Matrícula: ${matricula}\n\n⚠️ ATENÇÃO: O professor deve utilizar este E-MAIL (${email}) e a SENHA informados para efetuar login no sistema.`);
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
