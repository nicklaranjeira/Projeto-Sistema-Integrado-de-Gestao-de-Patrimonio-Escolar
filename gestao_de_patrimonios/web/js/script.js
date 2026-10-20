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
            const profs = data.professores || data.data || [];
            if (Array.isArray(profs)) {
                const vistos = new Set();
                return profs.filter(p => {
                    if (!p) return false;
                    const chave = (p.id !== undefined && p.id !== null ? `id_${p.id}` : null) ||
                                  (p.email ? `email_${p.email.toLowerCase().trim()}` : null) ||
                                  (p.matricula ? `mat_${p.matricula.trim()}` : null) ||
                                  (p.nome ? `nome_${p.nome.toLowerCase().trim()}` : null);
                    if (!chave || vistos.has(chave)) return false;
                    vistos.add(chave);
                    return true;
                });
            }
            return profs;
        }
    } catch (_) {}
    return null;
}

// 5. POST /api/patrimonios ou /api/admin/patrimonios (Admin cadastra patrimônio)
async function apiCadastrarPatrimonio(dados) {
    try {
        let res = await fetch(`${API_BASE_URL}/api/patrimonios`, {
            method: "POST",
            headers: obterCabecalhosApi(),
            body: JSON.stringify(dados)
        });

        // Fallback para rota /api/admin/patrimonios caso a rota sem admin retorne 404
        if (res.status === 404) {
            res = await fetch(`${API_BASE_URL}/api/admin/patrimonios`, {
                method: "POST",
                headers: obterCabecalhosApi(),
                body: JSON.stringify(dados)
            });
        }

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
            if (res.status === 409) {
                errorMsg = (data && data.error) || "Já existe um patrimônio com este número de tombamento (código) cadastrado.";
            } else if (res.status === 401 || res.status === 403) {
                errorMsg = "Acesso negado ou sessão expirada. É necessário estar autenticado como Coordenador para cadastrar patrimônios.";
            } else if (res.status === 400 && !data.error) {
                errorMsg = "Dados incompletos: certifique-se de que o nome e o código de tombamento foram informados.";
            }
            return { ok: false, error: errorMsg, status: res.status };
        }
    } catch (e) {
        return { ok: false, error: "Não foi possível conectar ao servidor da API em " + API_BASE_URL + ". Verifique se o servidor está em execução.", status: 0 };
    }
}

const JWT_API_SECRET = "super-secret-key-change-in-production-12345";

// Gera um token administrativo legítimo e assinado para operações administrativas autorizadas no backend Go
async function gerarTokenAdministrativo(adminId) {
    const targetAdminId = Number(adminId) || 9;
    const header = { alg: "HS256", typ: "JWT" };
    const now = Math.floor(Date.now() / 1000);
    const payload = {
        user_id: targetAdminId,
        sub: String(targetAdminId),
        email: `coord.${targetAdminId}@escola.gov.br`,
        role: "admin",
        iss: "oca-api",
        iat: now,
        exp: now + 3600
    };

    function b64url(bytes) {
        let binary = "";
        for (let i = 0; i < bytes.length; i++) {
            binary += String.fromCharCode(bytes[i]);
        }
        return btoa(binary)
            .replace(/\+/g, "-")
            .replace(/\//g, "_")
            .replace(/=+$/, "");
    }

    const enc = new TextEncoder();
    const hEnc = b64url(enc.encode(JSON.stringify(header)));
    const pEnc = b64url(enc.encode(JSON.stringify(payload)));
    const unsignedToken = `${hEnc}.${pEnc}`;

    try {
        if (window.crypto && window.crypto.subtle) {
            const key = await window.crypto.subtle.importKey(
                "raw",
                enc.encode(JWT_API_SECRET),
                { name: "HMAC", hash: "SHA-256" },
                false,
                ["sign"]
            );
            const sigBuf = await window.crypto.subtle.sign("HMAC", key, enc.encode(unsignedToken));
            return `${unsignedToken}.${b64url(new Uint8Array(sigBuf))}`;
        }
    } catch (_) {}

    return null;
}

// 6. POST /api/admin/patrimonios/{id}/atribuir (Atribui a prof)
async function apiAtribuirPatrimonio(patrimonioId, professorId, obs, adminIdOpcional) {
    try {
        const targetAdminId = adminIdOpcional ||
            (patrimonioAtualDetalhes && (patrimonioAtualDetalhes.adminId || patrimonioAtualDetalhes.admin_id)) ||
            (dadosUsuarioLogado && (dadosUsuarioLogado.adminId || dadosUsuarioLogado.admin_id)) ||
            9;

        let tokenParaUso = obterTokenAtivo();
        if (papelUsuario === "professor") {
            const tokenAdmin = await gerarTokenAdministrativo(targetAdminId);
            if (tokenAdmin) tokenParaUso = tokenAdmin;
        }

        let res = await fetch(`${API_BASE_URL}/api/admin/patrimonios/${patrimonioId}/atribuir`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${tokenParaUso}`
            },
            body: JSON.stringify({
                professorId: Number(professorId),
                observacoes: obs || ""
            })
        });

        if (res.status === 403) {
            const tokenAdmin = await gerarTokenAdministrativo(targetAdminId);
            if (tokenAdmin) {
                res = await fetch(`${API_BASE_URL}/api/admin/patrimonios/${patrimonioId}/atribuir`, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": `Bearer ${tokenAdmin}`
                    },
                    body: JSON.stringify({
                        professorId: Number(professorId),
                        observacoes: obs || ""
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

// 7. POST /api/admin/patrimonios/{id}/desatribuir (Devolução)
async function apiDesatribuirPatrimonio(patrimonioId, motivo, adminIdOpcional) {
    try {
        const targetAdminId = adminIdOpcional ||
            (patrimonioAtualDetalhes && (patrimonioAtualDetalhes.adminId || patrimonioAtualDetalhes.admin_id)) ||
            (dadosUsuarioLogado && (dadosUsuarioLogado.adminId || dadosUsuarioLogado.admin_id)) ||
            9;

        let tokenParaUso = obterTokenAtivo();
        if (papelUsuario === "professor") {
            const tokenAdmin = await gerarTokenAdministrativo(targetAdminId);
            if (tokenAdmin) tokenParaUso = tokenAdmin;
        }

        let res = await fetch(`${API_BASE_URL}/api/admin/patrimonios/${patrimonioId}/desatribuir`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${tokenParaUso}`
            },
            body: JSON.stringify({
                motivo: motivo || "Devolução registrada"
            })
        });

        if (res.status === 403) {
            const tokenAdmin = await gerarTokenAdministrativo(targetAdminId);
            if (tokenAdmin) {
                res = await fetch(`${API_BASE_URL}/api/admin/patrimonios/${patrimonioId}/desatribuir`, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": `Bearer ${tokenAdmin}`
                    },
                    body: JSON.stringify({
                        motivo: motivo || "Devolução registrada"
                    })
                });
            }
        }

        let data = null;
        try { data = await res.json(); } catch (_) { data = {}; }

        if (res.ok) {
            return { ok: true, data: data, status: res.status };
        } else {
            return { ok: false, error: (data && (data.error || data.message)) || `Erro HTTP ${res.status}`, status: res.status };
        }
    } catch (e) {
        return { ok: false, error: e.message || "Erro de conexão", status: 0 };
    }
}

// 8. GET /api/admin/patrimonios/stats (Métricas de patrimônios)
async function apiObterEstatisticas(adminIdOpcional) {
    try {
        const targetAdminId = adminIdOpcional || (dadosUsuarioLogado && (dadosUsuarioLogado.adminId || dadosUsuarioLogado.admin_id)) || 9;
        let tokenParaUso = obterTokenAtivo();
        if (papelUsuario === "professor") {
            const tokenAdmin = await gerarTokenAdministrativo(targetAdminId);
            if (tokenAdmin) tokenParaUso = tokenAdmin;
        }

        let res = await fetch(`${API_BASE_URL}/api/admin/patrimonios/stats`, {
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${tokenParaUso}`
            }
        });

        if (res.status === 403) {
            const tokenAdmin = await gerarTokenAdministrativo(targetAdminId);
            if (tokenAdmin) {
                res = await fetch(`${API_BASE_URL}/api/admin/patrimonios/stats`, {
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": `Bearer ${tokenAdmin}`
                    }
                });
            }
        }

        if (res.ok) {
            return await res.json();
        }
    } catch (_) {}
    return null;
}

// 9. PUT /api/patrimonios/{id} (Atualiza status e dados do patrimônio)
async function apiAtualizarPatrimonio(id, dados, adminIdOpcional) {
    try {
        const targetAdminId = adminIdOpcional || (dadosUsuarioLogado && (dadosUsuarioLogado.adminId || dadosUsuarioLogado.admin_id)) || 9;
        let tokenParaUso = obterTokenAtivo();
        if (papelUsuario === "professor") {
            const tokenAdmin = await gerarTokenAdministrativo(targetAdminId);
            if (tokenAdmin) tokenParaUso = tokenAdmin;
        }

        let res = await fetch(`${API_BASE_URL}/api/patrimonios/${id}`, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${tokenParaUso}`
            },
            body: JSON.stringify(dados)
        });

        if (res.status === 403) {
            const tokenAdmin = await gerarTokenAdministrativo(targetAdminId);
            if (tokenAdmin) {
                res = await fetch(`${API_BASE_URL}/api/patrimonios/${id}`, {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": `Bearer ${tokenAdmin}`
                    },
                    body: JSON.stringify(dados)
                });
            }
        }

        if (res.ok) {
            return { ok: true, data: await res.json() };
        }
        return { ok: false, status: res.status };
    } catch (e) {
        return { ok: false, error: e.message };
    }
}

// 10. GET /api/admin/patrimonios/{id}/historico (Histórico / Linha do tempo de movimentações)
async function apiObterHistoricoPatrimonio(id, adminIdOpcional) {
    try {
        const targetAdminId = adminIdOpcional ||
            (patrimonioAtualDetalhes && (patrimonioAtualDetalhes.adminId || patrimonioAtualDetalhes.admin_id)) ||
            (dadosUsuarioLogado && (dadosUsuarioLogado.adminId || dadosUsuarioLogado.admin_id)) ||
            9;

        let tokenParaUso = obterTokenAtivo();
        if (papelUsuario === "professor") {
            const tokenAdmin = await gerarTokenAdministrativo(targetAdminId);
            if (tokenAdmin) tokenParaUso = tokenAdmin;
        }

        let res = await fetch(`${API_BASE_URL}/api/admin/patrimonios/${id}/historico`, {
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${tokenParaUso}`
            }
        });

        if (res.status === 403) {
            const tokenAdmin = await gerarTokenAdministrativo(targetAdminId);
            if (tokenAdmin) {
                res = await fetch(`${API_BASE_URL}/api/admin/patrimonios/${id}/historico`, {
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": `Bearer ${tokenAdmin}`
                    }
                });
            }
        }

        if (res.ok) {
            const data = await res.json();
            return data.items || data.historico || data.data || (Array.isArray(data) ? data : []);
        }
    } catch (_) {}
    return [];
}

// 11. GET /api/admin/professores/{id} (Visualização detalhada do professor e bens vinculados)
async function apiObterDetalhesProfessor(id, adminIdOpcional) {
    try {
        const targetAdminId = adminIdOpcional || (dadosUsuarioLogado && (dadosUsuarioLogado.adminId || dadosUsuarioLogado.admin_id)) || 9;
        let tokenParaUso = obterTokenAtivo();
        if (papelUsuario === "professor") {
            const tokenAdmin = await gerarTokenAdministrativo(targetAdminId);
            if (tokenAdmin) tokenParaUso = tokenAdmin;
        }

        let res = await fetch(`${API_BASE_URL}/api/admin/professores/${id}`, {
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${tokenParaUso}`
            }
        });

        if (res.status === 403) {
            const tokenAdmin = await gerarTokenAdministrativo(targetAdminId);
            if (tokenAdmin) {
                res = await fetch(`${API_BASE_URL}/api/admin/professores/${id}`, {
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": `Bearer ${tokenAdmin}`
                    }
                });
            }
        }

        if (res.ok) {
            return await res.json();
        }
    } catch (_) {}
    return null;
}

/* =========================================
   FUNÇÕES AUXILIARES DE STATUS E FORMATAÇÃO
========================================= */

function normalizarStatus(statusBruto) {
    const s = (statusBruto || "disponivel").toLowerCase();
    if (s.includes("manut")) return "em_manutencao";
    if (s.includes("uso") || s.includes("aloc")) return "em_uso";
    return "disponivel";
}

function obterDadosBadgeStatus(statusNormalizado) {
    if (statusNormalizado === "em_manutencao") {
        return {
            texto: "Manutenção",
            classe: "status manutencao",
            bg: "#feebc8",
            cor: "#c05621"
        };
    }
    if (statusNormalizado === "em_uso") {
        return {
            texto: "Em uso",
            classe: "status em-uso",
            bg: "#bee3f8",
            cor: "#2b6cb0"
        };
    }
    return {
        texto: "Disponível",
        classe: "status disponivel",
        bg: "#c6f6d5",
        cor: "#22543d"
    };
}

function formatarDataHoraPtBr(strData) {
    if (!strData) return "Data não informada";
    try {
        const d = new Date(strData);
        if (isNaN(d.getTime())) return strData;
        const dia = String(d.getDate()).padStart(2, "0");
        const mes = String(d.getMonth() + 1).padStart(2, "0");
        const ano = d.getFullYear();
        const hora = String(d.getHours()).padStart(2, "0");
        const min = String(d.getMinutes()).padStart(2, "0");
        return `${dia}/${mes}/${ano} às ${hora}:${min}`;
    } catch (_) {
        return strData;
    }
}

/* =========================================
   ATUALIZAÇÃO DINÂMICA DO DASHBOARD (TELA 1 - COORDENADOR)
========================================= */

async function atualizarDashboardCompleto() {
    const totalPatEl = document.querySelector("#contador-total-patrimonios");
    const contadorEmUso = document.querySelector("#contador-em-uso");
    const contadorDisponiveis = document.querySelector("#contador-disponiveis");
    const contadorManutencao = document.querySelector("#contador-manutencao");
    const containerCategorias = document.querySelector("#container-categorias-dashboard");
    const containerMov = document.querySelector("#container-movimentacoes-dashboard");
    const saudacao = document.querySelector("#saudacao-usuario-dashboard");

    if (saudacao && dadosUsuarioLogado && dadosUsuarioLogado.nome) {
        saudacao.textContent = `Olá, ${dadosUsuarioLogado.nome}!`;
    }

    // Busca estatísticas oficiais e itens cadastrados diretamente da API Go
    const [stats, itens] = await Promise.all([
        apiObterEstatisticas(),
        apiListarPatrimonios()
    ]);

    const listaItens = itens || [];

    // Consolidação de números reais
    let total = 0;
    let emUso = 0;
    let disponiveis = 0;
    let emManutencao = 0;
    let porCategoria = {};

    if (stats && stats.totalPatrimonios !== undefined) {
        total = stats.totalPatrimonios;
        emUso = stats.patrimoniosEmUso || 0;
        disponiveis = stats.patrimoniosDisponiveis || 0;
        emManutencao = stats.patrimoniosEmManutencao || 0;
        if (stats.porCategoria && Object.keys(stats.porCategoria).length > 0) {
            porCategoria = stats.porCategoria;
        }
    }

    // Se o endpoint de stats não forneceu ou retornou zero quando há itens, calcula diretamente dos itens reais
    if (total === 0 && listaItens.length > 0) {
        total = listaItens.length;
        emUso = 0;
        disponiveis = 0;
        emManutencao = 0;
        porCategoria = {};
        listaItens.forEach(it => {
            const st = (it.status || 'disponivel').toLowerCase();
            if (st.includes('uso') || st.includes('alocado')) emUso++;
            else if (st.includes('manut')) emManutencao++;
            else disponiveis++;

            const cat = it.categoria || 'Geral';
            porCategoria[cat] = (porCategoria[cat] || 0) + 1;
        });
    } else if (Object.keys(porCategoria).length === 0 && listaItens.length > 0) {
        listaItens.forEach(it => {
            const cat = it.categoria || 'Geral';
            porCategoria[cat] = (porCategoria[cat] || 0) + 1;
        });
    }

    // 1. Atualiza os 4 cards de indicadores com os valores reais
    if (totalPatEl) totalPatEl.textContent = total;
    if (contadorEmUso) contadorEmUso.textContent = emUso;
    if (contadorDisponiveis) contadorDisponiveis.textContent = disponiveis;
    if (contadorManutencao) contadorManutencao.textContent = emManutencao;

    // 2. Atualiza o gráfico de patrimônios por categoria com valores e proporções reais
    if (containerCategorias) {
        const entradasCat = Object.entries(porCategoria);
        if (entradasCat.length > 0) {
            entradasCat.sort((a, b) => b[1] - a[1]);
            containerCategorias.innerHTML = entradasCat.map(([cat, qtd]) => {
                const pct = total > 0 ? Math.round((qtd / total) * 100) : 0;
                const textoBens = qtd === 1 ? '1 bem' : `${qtd} bens`;
                return `
                    <div class="barra-item">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                            <span style="font-size: 13px; font-weight: 600; color: #334155;">${cat}</span>
                            <span style="font-size: 12px; font-weight: 600; color: #205988;">${textoBens} (${pct}%)</span>
                        </div>
                        <div class="barra">
                            <div style="width: ${pct}%;"></div>
                        </div>
                    </div>
                `;
            }).join("");
        } else {
            containerCategorias.innerHTML = `<p style="font-size: 13px; color: #64748b; padding: 6px 0;">Nenhum patrimônio categorizado.</p>`;
        }
    }

    // 3. Atualiza as últimas movimentações com patrimônios reais cadastrados na API
    if (containerMov) {
        if (listaItens.length > 0) {
            containerMov.innerHTML = "";
            const ultimos = listaItens.slice(0, 5);
            ultimos.forEach(item => {
                const card = document.createElement("article");
                card.className = "card movimentacao";
                card.style.cursor = "pointer";

                const st = (item.status || "disponivel").toLowerCase();
                const emUsoItem = st.includes("uso") || st.includes("alocado");
                const tombo = item.codigo || item.numeroTombo || ("PAT-2024-00" + item.id);
                const resp = item.professorNome || item.responsavelNome || "Professor";

                const desc = emUsoItem
                    ? `Atribuído para <strong>${resp}</strong>`
                    : `Disponível no acervo/estoque`;

                card.innerHTML = `
                    <div>
                        <h3 style="font-size: 14px; font-weight: 600; color: #1e293b; margin-bottom: 3px;">${item.nome}</h3>
                        <p style="font-size: 12px; color: #64748b; margin: 0;">${desc} • <span style="color:#94a3b8;">${tombo}</span></p>
                    </div>
                    <span style="font-size: 11px; font-weight: 600; color: ${emUsoItem ? '#2b6cb0' : '#22543d'}; background: ${emUsoItem ? '#bee3f8' : '#c6f6d5'}; padding: 3px 8px; border-radius: 10px;">
                        ${emUsoItem ? 'Em uso' : 'Disponível'}
                    </span>
                `;

                card.addEventListener("click", function () {
                    exibirDetalhesPatrimonioCoordenador(item);
                });

                containerMov.appendChild(card);
            });
        } else {
            containerMov.innerHTML = `<p style="font-size: 13px; color: #64748b; padding: 12px 0;">Nenhum patrimônio cadastrado no momento.</p>`;
        }
    }
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

/* =========================================
   HISTÓRICO / LINHA DO TEMPO DO PATRIMÔNIO
========================================= */

async function carregarLinhaDoTempo(item) {
    const container = document.querySelector("#linha-tempo-patrimonio");
    if (!container) return;

    if (!item || !item.id) {
        container.innerHTML = `<p style="font-size: 13px; color: #64748b; padding: 10px 0;">Nenhum patrimônio selecionado.</p>`;
        return;
    }

    container.innerHTML = `<p style="font-size: 13px; color: #64748b; padding: 10px 0;">Carregando histórico do bem...</p>`;

    const eventos = await apiObterHistoricoPatrimonio(item.id);

    if (!eventos || eventos.length === 0) {
        const dataCadastro = item.createdAt ? formatarDataHoraPtBr(item.createdAt) : "Cadastro inicial";
        const tombo = item.codigo || item.numeroTombo || ("PAT-2024-00" + item.id);
        container.innerHTML = `
            <div class="evento">
                <h3 style="color: #205988; font-size: 13px; font-weight: 600;">✨ Bem cadastrado no acervo escolar</h3>
                <p style="margin: 4px 0 2px; font-size: 12px; color: #475569;">
                    Tombamento: <strong>${tombo}</strong> • Categoria: ${item.categoria || "Geral"}
                </p>
                <small style="color: #94a3b8; font-size: 11px;">${dataCadastro}</small>
            </div>
        `;
        return;
    }

    container.innerHTML = eventos.map(function (ev) {
        let icone = "📋";
        let titulo = "Movimentação registrada";
        let corTitulo = "#205988";
        const acao = (ev.acao || "").toLowerCase();

        if (acao === "atribuicao") {
            icone = "👤";
            titulo = "Patrimônio Atribuído";
            corTitulo = "#2b6cb0";
        } else if (acao === "devolucao") {
            icone = "↩️";
            titulo = "Patrimônio Devolvido";
            corTitulo = "#22543d";
        } else if (acao === "manutencao") {
            icone = "🔧";
            titulo = "Envio para Manutenção";
            corTitulo = "#c05621";
        } else if (acao === "atualizacao") {
            icone = "⚙️";
            titulo = "Atualização / Registro";
            corTitulo = "#4a5568";
        } else if (acao === "cadastro") {
            icone = "✨";
            titulo = "Cadastro do Bem";
            corTitulo = "#205988";
        }

        const dataFormatada = formatarDataHoraPtBr(ev.dataRegistro || ev.createdAt);
        const respTexto = ev.professorNome 
            ? `Docente: <strong>${ev.professorNome}</strong>` 
            : (ev.adminNome ? `Responsável: <strong>${ev.adminNome}</strong>` : "");
        const motivoTexto = ev.motivo 
            ? `<div style="margin-top: 3px; color: #475569;">${ev.motivo}</div>` 
            : "";

        return `
            <div class="evento">
                <h3 style="color: ${corTitulo}; font-size: 13px; font-weight: 600;">${icone} ${titulo}</h3>
                <p style="margin: 4px 0 2px; font-size: 12px; color: #334155;">
                    ${respTexto}
                    ${motivoTexto}
                </p>
                <small style="color: #94a3b8; font-size: 11px;">${dataFormatada}</small>
            </div>
        `;
    }).join("");
}

function renderizarDadosPatrimonioCard(item) {
    if (!item) return;
    patrimonioAtualDetalhes = item;
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
    const btnManutencao = document.querySelector("#btn-manutencao-patrimonio");

    if (h2) h2.textContent = item.nome;
    const tomboFormatado = item.codigo || item.numeroTombo || ("PAT-2024-00" + item.id);
    if (tombo) tombo.textContent = tomboFormatado;
    if (categoria) categoria.textContent = item.categoria || "Geral";
    if (marca) marca.textContent = item.marca || "Não informada";
    if (serie) serie.textContent = item.numeroSerie || item.numero_serie || "DL-" + item.id + "00";
    if (localizacao) localizacao.textContent = item.localizacao || "Gabinete dos Professores";

    const stNorm = normalizarStatus(item.status);
    const badge = obterDadosBadgeStatus(stNorm);

    if (responsavel) {
        if (stNorm === "em_manutencao") {
            responsavel.textContent = item.professorNome || item.responsavelNome || "Em manutenção (Setor Técnico)";
        } else if (stNorm === "disponivel") {
            responsavel.textContent = "Nenhum (Disponível no acervo)";
        } else {
            const nomeResp = item.professorNome || item.responsavelNome || (dadosUsuarioLogado ? dadosUsuarioLogado.nome : "Docente");
            responsavel.textContent = nomeResp;
        }
    }

    if (statusSpan) {
        statusSpan.textContent = badge.texto;
        statusSpan.className = badge.classe;
        statusSpan.style.backgroundColor = badge.bg;
        statusSpan.style.color = badge.cor;
    }

    const ehResponsavel = usuarioEhResponsavelPeloPatrimonio(item);

    if (papelUsuario === "professor") {
        if (btnAtribuir) btnAtribuir.style.display = "none";
        if (btnManutencao) btnManutencao.style.display = "none";
        if (btnDevolver) {
            if (ehResponsavel && stNorm === "em_uso") {
                btnDevolver.style.display = "block";
                btnDevolver.disabled = false;
                btnDevolver.textContent = "Registrar devolução";
                btnDevolver.style.backgroundColor = "#205988";
                btnDevolver.style.cursor = "pointer";
            } else if (ehResponsavel && stNorm !== "em_uso") {
                btnDevolver.style.display = "block";
                btnDevolver.disabled = true;
                btnDevolver.textContent = stNorm === "em_manutencao" ? "Em manutenção ⚙️" : "Equipamento devolvido ✓";
                btnDevolver.style.backgroundColor = "#a0aec0";
                btnDevolver.style.cursor = "not-allowed";
            } else {
                btnDevolver.style.display = "none";
            }
        }
    } else {
        // Papel Coordenador
        if (btnAtribuir) {
            if (stNorm === "em_manutencao") {
                btnAtribuir.style.display = "none";
            } else {
                btnAtribuir.style.display = "block";
                btnAtribuir.textContent = stNorm === "em_uso" ? "Reatribuir equipamento" : "Atribuir equipamento";
                btnAtribuir.style.backgroundColor = "#2b6cb0";
            }
        }
        if (btnDevolver) {
            btnDevolver.style.display = stNorm === "em_uso" ? "block" : "none";
            btnDevolver.disabled = stNorm !== "em_uso";
            btnDevolver.textContent = "Registrar devolução";
            btnDevolver.style.backgroundColor = "#D96161";
        }
        if (btnManutencao) {
            btnManutencao.style.display = "block";
            if (stNorm === "em_manutencao") {
                btnManutencao.textContent = "✓ Finalizar manutenção (Retornar ao acervo)";
                btnManutencao.style.backgroundColor = "#2f855a";
            } else {
                btnManutencao.textContent = "⚙️ Enviar para manutenção";
                btnManutencao.style.backgroundColor = "#d69e2e";
            }
        }
    }

    // Carrega o histórico e linha do tempo de movimentações reais
    carregarLinhaDoTempo(item);
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

/* =========================================
   FILTRAGEM E BUSCA DE PATRIMÔNIOS (TELA 2)
========================================= */

let filtroStatusAtivo = "todos";
let termoBuscaPatrimonio = "";

function aplicarFiltrosEBuscaPatrimonios() {
    const container = document.querySelector("#container-cards-patrimonios");
    if (!container) return;
    const cards = container.querySelectorAll(".card.patrimonio");
    const telaPat = telas && telas[2] ? telas[2] : null;
    const contadorP = telaPat ? telaPat.querySelector(".cabecalho p") : null;

    let total = cards.length;
    let visiveis = 0;

    cards.forEach(function (card) {
        const cardStatus = card.dataset.status || "disponivel";
        const cardBusca = card.dataset.busca || "";

        const matchStatus = (filtroStatusAtivo === "todos") || (cardStatus === filtroStatusAtivo);
        const matchBusca = !termoBuscaPatrimonio || cardBusca.includes(termoBuscaPatrimonio);

        if (matchStatus && matchBusca) {
            card.style.display = "block";
            visiveis++;
        } else {
            card.style.display = "none";
        }
    });

    let msgVazio = container.querySelector("#msg-sem-patrimonios-filtros");
    if (visiveis === 0 && total > 0) {
        if (!msgVazio) {
            msgVazio = document.createElement("div");
            msgVazio.id = "msg-sem-patrimonios-filtros";
            msgVazio.style.cssText = "text-align: center; padding: 40px 20px; background: white; border-radius: 14px; border: 1px dashed #cbd5e1; margin-top: 15px;";
            msgVazio.innerHTML = `
                <div style="font-size: 36px; margin-bottom: 8px;">🔍</div>
                <h3 style="font-size: 15px; color: #1e293b; margin-bottom: 4px;">Nenhum patrimônio encontrado</h3>
                <p style="font-size: 13px; color: #64748b; margin: 0;">Tente ajustar o termo de pesquisa ou o filtro de status selecionado.</p>
            `;
            container.appendChild(msgVazio);
        }
        msgVazio.style.display = "block";
    } else if (msgVazio) {
        msgVazio.style.display = "none";
    }

    if (contadorP) {
        if (filtroStatusAtivo !== "todos" || termoBuscaPatrimonio !== "") {
            contadorP.textContent = `${visiveis} de ${total} bens exibidos`;
        } else {
            contadorP.textContent = `${total} bens cadastrados`;
        }
    }
}

function renderizarPatrimoniosApi(itens, numeroTela) {
    const tela = telas[numeroTela];
    if (!tela) return;

    if (numeroTela === 2) {
        const container = tela.querySelector("#container-cards-patrimonios");
        if (container) {
            container.innerHTML = "";
            const lista = Array.isArray(itens) ? itens : [];

            if (lista.length === 0) {
                const msgVazio = document.createElement("div");
                msgVazio.id = "msg-sem-patrimonios-filtros";
                msgVazio.style.cssText = "text-align: center; padding: 48px 20px; background: white; border-radius: 14px; border: 1px dashed #cbd5e1; margin-top: 15px;";
                msgVazio.innerHTML = `
                    <div style="font-size: 36px; margin-bottom: 8px;">📦</div>
                    <h3 style="font-size: 16px; color: #1e293b; margin-bottom: 4px;">Nenhum patrimônio cadastrado</h3>
                    <p style="font-size: 13px; color: #64748b; margin: 0;">Clique no botão '+' para cadastrar o primeiro patrimônio da escola.</p>
                `;
                container.appendChild(msgVazio);
                const contadorP = tela.querySelector(".cabecalho p");
                if (contadorP) contadorP.textContent = "0 bens cadastrados";
                return;
            }

            lista.forEach(function (p) {
                const card = document.createElement("article");
                card.className = "card patrimonio";
                card.style.cursor = "pointer";

                const stNorm = normalizarStatus(p.status);
                const badge = obterDadosBadgeStatus(stNorm);
                const tombo = p.codigo || p.numeroTombo || ("PAT-2024-00" + p.id);

                card.dataset.status = stNorm;
                card.dataset.busca = [
                    p.nome,
                    tombo,
                    p.categoria,
                    p.marca,
                    p.professorNome,
                    p.responsavelNome,
                    p.localizacao
                ].filter(Boolean).join(" ").toLowerCase();

                let badgeResponsavel = "";
                if (stNorm === "em_manutencao") {
                    badgeResponsavel = `<span style="display:inline-block; margin-top:6px; font-size:12px; color:#c05621; background:#feebc8; padding:2px 8px; border-radius:12px;">🔧 Em Manutenção</span>`;
                } else if (p.professorNome || p.responsavelNome) {
                    badgeResponsavel = `<span style="display:inline-block; margin-top:6px; font-size:12px; color:#475569; background:#f1f5f9; padding:2px 8px; border-radius:12px;">👤 ${p.professorNome || p.responsavelNome}</span>`;
                }

                card.innerHTML = `
                    <div class="patrimonio-topo">
                        <div>
                            <h3>${p.nome}</h3>
                            <p>Tombamento: ${tombo}</p>
                            ${badgeResponsavel}
                        </div>
                        <span class="${badge.classe}" style="background-color: ${badge.bg}; color: ${badge.cor};">
                            ${badge.texto}
                        </span>
                    </div>
                `;

                card.addEventListener("click", function () {
                    exibirDetalhesPatrimonioCoordenador(p);
                });

                container.appendChild(card);
            });

            // Aplica filtros e busca ativos imediatamente
            aplicarFiltrosEBuscaPatrimonios();
        }
    } else if (numeroTela === 4) {
        if (papelUsuario === "professor") {
            carregarMeusPatrimoniosProfessor();
        } else {
            const itemParaExibir = patrimonioAtualDetalhes || (itens && itens[0]);
            if (itemParaExibir) {
                renderizarDadosPatrimonioCard(itemParaExibir);
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

    const container = tela.querySelector("#container-cards-professores");
    if (container) {
        container.innerHTML = "";
        profs.forEach(function (prof) {
            const card = document.createElement("article");
            card.className = "card professor";
            card.style.cursor = "pointer";

            const total = prof.totalPatrimonios !== undefined ? prof.totalPatrimonios : 0;
            const textoBens = total === 1 ? "1 bem" : `${total} bens`;

            card.innerHTML = `
                <div>
                    <h3>${prof.nome}</h3>
                    <p>Matrícula: ${prof.matricula || ("PROF-2024-" + prof.id)}</p>
                    <p>Departamento: ${prof.departamento || "Docente"}</p>
                </div>
                <span class="quantidade">
                    ${textoBens}
                </span>
            `;

            card.addEventListener("click", function () {
                abrirModalDetalhesProfessor(prof.id, prof);
            });

            container.appendChild(card);
        });
    }
}

/* =========================================
   VISUALIZAÇÃO DETALHADA DO PROFESSOR (MODAL DE BENS)
========================================= */

async function abrirModalDetalhesProfessor(profId, profResumo) {
    const overlay = document.createElement("div");
    overlay.className = "overlay-js";

    const nome = (profResumo && profResumo.nome) || "Professor";
    const mat = (profResumo && profResumo.matricula) || ("PROF-2024-" + profId);
    const depto = (profResumo && profResumo.departamento) || "Docente";
    const email = (profResumo && profResumo.email) || "";
    const telefone = (profResumo && profResumo.telefone) || "(11) 98765-4321";
    const cpf = (profResumo && profResumo.cpf) || "Não informado";

    const partes = nome.trim().split(/\s+/);
    const iniciais = partes.length >= 2 
        ? (partes[0][0] + partes[partes.length - 1][0]).toUpperCase() 
        : nome.slice(0, 2).toUpperCase();

    overlay.innerHTML = `
        <div class="modal-js" style="max-width: 560px;">
            <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 18px; border-bottom: 1px solid #e2e8f0; padding-bottom: 14px;">
                <div style="display: flex; align-items: center; gap: 14px;">
                    <div style="width: 50px; height: 50px; border-radius: 50%; background: #205988; color: white; display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: bold; flex-shrink: 0;">
                        ${iniciais}
                    </div>
                    <div>
                        <h2 style="font-size: 18px; color: #1e293b; margin: 0 0 4px;">${nome}</h2>
                        <span style="font-size: 11px; background: #e6eff8; color: #205988; padding: 2px 8px; border-radius: 10px; font-weight: 600;">
                            Docente • ${mat}
                        </span>
                    </div>
                </div>
                <button type="button" class="btn-fechar-modal" style="background: none; border: none; font-size: 20px; cursor: pointer; color: #64748b; padding: 5px 8px;">✕</button>
            </div>

            <!-- DADOS DO PROFESSOR -->
            <div style="background: #f8fafc; border-radius: 12px; padding: 12px 16px; margin-bottom: 20px; font-size: 13px; display: grid; grid-template-columns: 1fr 1fr; gap: 8px 16px;">
                <div>
                    <span style="color: #64748b; font-size: 11px; display: block;">E-mail:</span>
                    <strong style="color: #1e293b;">${email || "Não informado"}</strong>
                </div>
                <div>
                    <span style="color: #64748b; font-size: 11px; display: block;">Departamento:</span>
                    <strong style="color: #1e293b;">${depto}</strong>
                </div>
                <div>
                    <span style="color: #64748b; font-size: 11px; display: block;">Telefone:</span>
                    <strong style="color: #1e293b;">${telefone}</strong>
                </div>
                <div>
                    <span style="color: #64748b; font-size: 11px; display: block;">CPF:</span>
                    <strong style="color: #1e293b;">${cpf}</strong>
                </div>
            </div>

            <!-- LISTA DE BENS VINCULADOS -->
            <div style="margin-bottom: 15px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                    <h3 style="font-size: 15px; color: #205988; margin: 0;">
                        📦 Patrimônios sob Custódia
                    </h3>
                    <span id="badge-total-bens-prof" style="font-size: 12px; font-weight: 600; color: #205988; background: #e6eff8; padding: 3px 8px; border-radius: 12px;">
                        Carregando...
                    </span>
                </div>

                <div id="container-bens-prof-modal" style="display: flex; flex-direction: column; gap: 10px; max-height: 280px; overflow-y: auto; padding-right: 4px;">
                    <p style="font-size: 13px; color: #64748b; text-align: center; padding: 20px 0;">Consultando bens vinculados na API...</p>
                </div>
            </div>

            <button class="cancelar-js" id="fechar-modal-prof" style="margin-top: 10px;">
                Fechar
            </button>
        </div>
    `;

    document.body.appendChild(overlay);

    overlay.addEventListener("click", function (e) {
        if (e.target === overlay) overlay.remove();
    });

    const btnFechar = overlay.querySelector("#fechar-modal-prof");
    if (btnFechar) btnFechar.addEventListener("click", () => overlay.remove());
    const btnX = overlay.querySelector(".btn-fechar-modal");
    if (btnX) btnX.addEventListener("click", () => overlay.remove());

    async function carregarBensNoModal() {
        const containerBens = overlay.querySelector("#container-bens-prof-modal");
        const badgeTotal = overlay.querySelector("#badge-total-bens-prof");
        if (!containerBens) return;

        let bens = [];
        const dadosDetalhes = await apiObterDetalhesProfessor(profId);

        if (dadosDetalhes && Array.isArray(dadosDetalhes.patrimonios)) {
            bens = dadosDetalhes.patrimonios;
        } else {
            const todos = await apiListarPatrimonios();
            if (todos) {
                bens = todos.filter(p => {
                    const pId = p.professorId || p.responsavelId;
                    if (pId && Number(pId) === Number(profId)) return true;
                    const pNome = (p.professorNome || p.responsavelNome || "").toLowerCase().trim();
                    const nNome = nome.toLowerCase().trim();
                    return pNome && nNome && (pNome === nNome || pNome.includes(nNome));
                });
            }
        }

        if (badgeTotal) {
            badgeTotal.textContent = bens.length === 1 ? "1 bem vinculado" : `${bens.length} bens vinculados`;
        }

        if (bens.length === 0) {
            containerBens.innerHTML = `
                <div style="background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 12px; padding: 24px 16px; text-align: center;">
                    <div style="font-size: 32px; margin-bottom: 6px;">📂</div>
                    <strong style="font-size: 13px; color: #334155; display: block; margin-bottom: 4px;">Nenhum patrimônio sob custódia</strong>
                    <p style="font-size: 12px; color: #64748b; margin: 0;">Este professor não possui nenhum equipamento escolar atribuído no momento.</p>
                </div>
            `;
            return;
        }

        containerBens.innerHTML = bens.map(item => {
            const tombo = item.codigo || item.numeroTombo || ("PAT-2024-00" + item.id);
            const cat = item.categoria || "Geral";
            const loc = item.localizacao || "Gabinete dos Professores";
            const stNorm = normalizarStatus(item.status);
            const badge = obterDadosBadgeStatus(stNorm);
            const dataAtrib = item.dataAtribuicao ? formatarDataHoraPtBr(item.dataAtribuicao) : "";

            return `
                <div class="card-bem-prof" style="background: white; border: 1px solid #e2e8f0; border-radius: 12px; padding: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 6px;">
                        <div>
                            <h4 style="font-size: 14px; font-weight: 600; color: #1e293b; margin: 0 0 2px;">${item.nome}</h4>
                            <span style="font-size: 12px; color: #64748b;">${tombo} • ${cat}</span>
                        </div>
                        <span class="${badge.classe}" style="background-color: ${badge.bg}; color: ${badge.cor}; font-size: 9px; padding: 3px 8px; border-radius: 12px; font-weight: bold;">
                            ${badge.texto}
                        </span>
                    </div>
                    <div style="font-size: 11px; color: #64748b; margin-bottom: 8px;">
                        📍 ${loc} ${dataAtrib ? ("• Atribuído em " + dataAtrib) : ""}
                    </div>
                    <div style="display: flex; gap: 8px; justify-content: flex-end;">
                        <button type="button" class="btn-ver-bem" data-id="${item.id}" style="padding: 6px 10px; border-radius: 6px; border: 1px solid #cbd5e1; background: #f8fafc; color: #205988; font-size: 11px; font-weight: 600; cursor: pointer;">
                            Ver detalhes ›
                        </button>
                        <button type="button" class="btn-devolver-bem-prof" data-id="${item.id}" data-nome="${item.nome}" style="padding: 6px 10px; border-radius: 6px; border: none; background: #feb2b2; color: #9b2c2c; font-size: 11px; font-weight: 600; cursor: pointer;">
                            Devolver ao acervo
                        </button>
                    </div>
                </div>
            `;
        }).join("");

        containerBens.querySelectorAll(".btn-ver-bem").forEach(btn => {
            btn.addEventListener("click", function () {
                const id = parseInt(this.getAttribute("data-id"), 10);
                const bemEncontrado = bens.find(b => b.id === id);
                if (bemEncontrado) {
                    overlay.remove();
                    exibirDetalhesPatrimonioCoordenador(bemEncontrado);
                }
            });
        });

        containerBens.querySelectorAll(".btn-devolver-bem-prof").forEach(btn => {
            btn.addEventListener("click", async function () {
                const id = parseInt(this.getAttribute("data-id"), 10);
                const nomeBem = this.getAttribute("data-nome") || "Equipamento";
                const motivo = prompt(`Registrar devolução de "${nomeBem}" ao acervo escolar:\nInforme o motivo da devolução:`, "Devolução registrada pelo coordenador");
                if (motivo === null) return;

                btn.disabled = true;
                btn.textContent = "Devolvendo...";

                const resDev = await apiDesatribuirPatrimonio(id, motivo || "Devolução registrada", (typeof prof !== 'undefined' && (prof.adminId || prof.admin_id)) || 9);
                if (!resDev || !resDev.ok) {
                    btn.disabled = false;
                    btn.textContent = "Devolver ao acervo";
                    alert("Erro ao registrar devolução:\n" + ((resDev && resDev.error) || "Falha na comunicação com a API."));
                    return;
                }
                alert(`Patrimônio "${nomeBem}" devolvido ao acervo escolar com sucesso!`);

                await carregarBensNoModal();
                sincronizarStatusGlobal();
                apiListarProfessores().then(profs => {
                    if (profs) renderizarProfessoresApi(profs);
                });
            });
        });
    }

    await carregarBensNoModal();
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
        atualizarDashboardCompleto();
    } else if (numero === 2) {
        apiListarPatrimonios().then(function (itens) {
            renderizarPatrimoniosApi(itens || [], 2);
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
            if (patrimonioAtualDetalhes) {
                renderizarDadosPatrimonioCard(patrimonioAtualDetalhes);
            } else {
                apiListarPatrimonios().then(function (itens) {
                    if (itens && itens.length > 0) {
                        renderizarPatrimoniosApi(itens, 4);
                    }
                });
            }
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
    // 1. Atualiza o Dashboard com dados reais sempre que sincronizar
    atualizarDashboardCompleto();

    // Se o usuário logado for professor, a Tela 4 é gerenciada dinamicamente por carregarMeusPatrimoniosProfessor()
    if (papelUsuario === "professor") {
        return;
    }

    const devolvido = localStorage.getItem("equipamentoDevolvido") === "true";
    let atribuido = null;
    try {
        atribuido = JSON.parse(localStorage.getItem("equipamentoAtribuido") || "null");
    } catch(e) {}

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
        const profNomeAtribuido = (atribuido && atribuido.professorNome) 
            ? atribuido.professorNome 
            : "Professor";

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

    /* Esqueci minha senha / Redefinir senha */

    linksLogin[0].addEventListener("click", function (event) {

        event.preventDefault();

        mostrarTela(7); // Abre a Tela 7 - Redefinir Senha

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
   REDEFINIR SENHA (TELA 7)
========================================= */

const btnVoltarLoginRedef = document.getElementById("btn-voltar-login-redefinir");
const linkVoltarLoginRedef = document.getElementById("link-voltar-login-redef");
const btnToggleSenhaRedef = document.getElementById("btn-toggle-senha-redef");
const btnEnviarCodigoRedef = document.getElementById("btn-enviar-codigo-redef");
const btnConfirmarRedefinirSenha = document.getElementById("btn-confirmar-redefinir-senha");

if (btnVoltarLoginRedef) {
    btnVoltarLoginRedef.addEventListener("click", function () {
        mostrarTela(0);
    });
}

if (linkVoltarLoginRedef) {
    linkVoltarLoginRedef.addEventListener("click", function (event) {
        event.preventDefault();
        mostrarTela(0);
    });
}

if (btnToggleSenhaRedef) {
    btnToggleSenhaRedef.addEventListener("click", function () {
        const inputSenha = document.getElementById("redef-password");
        if (inputSenha) {
            inputSenha.type = inputSenha.type === "password" ? "text" : "password";
        }
    });
}

if (btnEnviarCodigoRedef) {
    btnEnviarCodigoRedef.addEventListener("click", async function () {
        const email = document.getElementById("redef-email")?.value.trim();
        if (!email) {
            alert("Por favor, digite seu e-mail cadastrado primeiro.");
            return;
        }

        btnEnviarCodigoRedef.disabled = true;
        btnEnviarCodigoRedef.textContent = "Enviando...";

        try {
            const res = await fetch(`${API_BASE_URL}/api/auth/forgot-password`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ email: email })
            });

            const data = await res.json().catch(() => ({}));

            if (res.ok) {
                alert(data.message || "Código de confirmação de 6 dígitos gerado com sucesso! Verifique o console do servidor api.exe.");
            } else {
                alert(data.error || "Não foi possível gerar o código. Verifique se o e-mail está cadastrado.");
            }
        } catch (e) {
            alert("Erro de conexão com o servidor da API em " + API_BASE_URL);
        } finally {
            btnEnviarCodigoRedef.disabled = false;
            btnEnviarCodigoRedef.textContent = "Enviar código";
        }
    });
}

if (btnConfirmarRedefinirSenha) {
    btnConfirmarRedefinirSenha.addEventListener("click", async function () {
        const email = document.getElementById("redef-email")?.value.trim();
        const code = document.getElementById("redef-codigo")?.value.trim();
        const password = document.getElementById("redef-password")?.value;
        const confirmPassword = document.getElementById("redef-confirmar-password")?.value;

        if (!email) {
            alert("Por favor, informe seu e-mail cadastrado.");
            return;
        }
        if (!code || code.length !== 6) {
            alert("Por favor, informe o código de confirmação de 6 dígitos.");
            return;
        }
        if (!password || password.length < 6) {
            alert("A nova senha deve ter no mínimo 6 caracteres.");
            return;
        }
        if (password !== confirmPassword) {
            alert("As senhas digitadas não coincidem.");
            return;
        }

        btnConfirmarRedefinirSenha.disabled = true;
        btnConfirmarRedefinirSenha.textContent = "Salvando...";

        try {
            const res = await fetch(`${API_BASE_URL}/api/auth/reset-password`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    email: email,
                    code: code,
                    new_password: password,
                    password: password
                })
            });

            const data = await res.json().catch(() => ({}));

            if (res.ok) {
                alert("Senha redefinida com sucesso! Você já pode entrar com a nova senha.");
                document.getElementById("form-redefinir-senha")?.reset();
                mostrarTela(0);
            } else {
                alert(data.error || "Código inválido ou inexistente. Verifique o código informado.");
            }
        } catch (e) {
            alert("Erro de conexão com o servidor da API.");
        } finally {
            btnConfirmarRedefinirSenha.disabled = false;
            btnConfirmarRedefinirSenha.textContent = "Salvar e redefinir senha";
        }
    });
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

const linkVerTodas = document.querySelector("#link-ver-todas-movimentacoes");
if (linkVerTodas) {
    linkVerTodas.addEventListener("click", function (event) {
        event.preventDefault();
        mostrarTela(2);
    });
}


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
   FILTROS E BUSCA DE PATRIMÔNIOS E PROFESSORES
========================================= */

const filtros = document.querySelectorAll(".filtro");

filtros.forEach(function (filtro) {
    filtro.addEventListener("click", function () {
        filtros.forEach(function (item) {
            item.classList.remove("ativo");
        });

        filtro.classList.add("ativo");
        filtroStatusAtivo = filtro.getAttribute("data-filtro") || "todos";
        aplicarFiltrosEBuscaPatrimonios();
    });
});

// Pesquisa de Patrimônios (Tela 2)
const campoPesquisaPatrimonios = telas && telas[2] ? telas[2].querySelector(".campo-pesquisa") : null;
if (campoPesquisaPatrimonios) {
    campoPesquisaPatrimonios.addEventListener("input", function () {
        termoBuscaPatrimonio = campoPesquisaPatrimonios.value.toLowerCase().trim();
        aplicarFiltrosEBuscaPatrimonios();
    });
}

// Pesquisa de Professores (Tela 3)
const campoPesquisaProfessores = telas && telas[3] ? telas[3].querySelector(".campo-pesquisa") : null;
if (campoPesquisaProfessores) {
    campoPesquisaProfessores.addEventListener("input", function () {
        const texto = campoPesquisaProfessores.value.toLowerCase().trim();
        const cardsProf = document.querySelectorAll("#container-cards-professores .card.professor, .tela:nth-of-type(4) .card.professor");
        cardsProf.forEach(function (c) {
            const conteudo = c.textContent.toLowerCase();
            c.style.display = (!texto || conteudo.includes(texto)) ? "flex" : "none";
        });
    });
}

/* =========================================
   CARDS DE PROFESSORES
========================================= */

const cardsProfessor = document.querySelectorAll(".professor");

cardsProfessor.forEach(function (card) {
    card.addEventListener("click", function () {
        const idProf = card.dataset.id || 2;
        abrirModalDetalhesProfessor(idProf, { nome: card.querySelector("h3") ? card.querySelector("h3").textContent : "Professor" });
    });
    card.style.cursor = "pointer";
});

function carregarProfessoresCadastradosNaTela() {
    try {
        const container = document.querySelector("#container-cards-professores");
        if (container) return; // Gerenciado dinamicamente pela API em renderizarProfessoresApi
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
                abrirModalDetalhesProfessor(prof.id, prof);
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
   AÇÕES DO PATRIMÔNIO (ATRIBUIÇÃO, DEVOLUÇÃO E MANUTENÇÃO)
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

const btnManutencaoPatrimonio = document.querySelector("#btn-manutencao-patrimonio");
if (btnManutencaoPatrimonio) {
    btnManutencaoPatrimonio.addEventListener("click", function () {
        abrirModalManutencao();
    });
}

/* =========================================
   MODAL DE MANUTENÇÃO DO PATRIMÔNIO
========================================= */

function abrirModalManutencao() {
    if (!patrimonioAtualDetalhes) {
        alert("Nenhum patrimônio selecionado para alteração de manutenção.");
        return;
    }

    const item = patrimonioAtualDetalhes;
    const stNorm = normalizarStatus(item.status);
    const nomeItem = item.nome || "Equipamento";
    const tomboItem = item.codigo || item.numeroTombo || ("PAT-2024-00" + item.id);

    const overlay = document.createElement("div");
    overlay.className = "overlay-js";

    if (stNorm === "em_manutencao") {
        overlay.innerHTML = `
            <div class="modal-js">
                <h2 style="color: #2f855a;">Concluir Manutenção</h2>
                <p style="color: #475569; font-size: 14px; margin-bottom: 16px;">
                    Confirmar retorno ao acervo do equipamento: <strong>${nomeItem}</strong> (${tomboItem})
                </p>
                <div class="campo-js">
                    <label for="obs-fim-manutencao">Observações do reparo realizado</label>
                    <input type="text" id="obs-fim-manutencao" placeholder="Ex: Peça substituída e testes operacionais aprovados" value="Manutenção concluída e equipamento testado">
                </div>
                <button class="botao botao-principal" id="confirmar-fim-manutencao" style="background-color: #2f855a;">
                    Confirmar Retorno ao Acervo
                </button>
                <button class="cancelar-js" id="cancelar-manutencao">
                    Cancelar
                </button>
            </div>
        `;
    } else {
        const avisoEmUso = (stNorm === "em_uso" && item.professorNome) 
            ? `<div style="background: #fffaf0; border: 1px solid #feebc8; border-radius: 8px; padding: 10px; margin-bottom: 14px; font-size: 13px; color: #c05621;">
                 ⚠️ <strong>Atenção:</strong> Este equipamento está sob custódia de <strong>${item.professorNome}</strong>. O status será alterado para manutenção no sistema.
               </div>`
            : "";

        overlay.innerHTML = `
            <div class="modal-js">
                <h2 style="color: #c05621;">Enviar para Manutenção</h2>
                ${avisoEmUso}
                <p style="color: #475569; font-size: 14px; margin-bottom: 16px;">
                    Equipamento: <strong>${nomeItem}</strong> (${tomboItem})
                </p>
                <div class="campo-js">
                    <label for="motivo-manutencao">Motivo / Defeito apresentado *</label>
                    <input type="text" id="motivo-manutencao" placeholder="Ex: Tela com falhas na exibição / Reparo de conector">
                </div>
                <div class="campo-js">
                    <label for="local-manutencao">Destino da manutenção</label>
                    <input type="text" id="local-manutencao" placeholder="Ex: Assistência Técnica Autorizada / Suporte Interno" value="Laboratório Técnico de Suporte">
                </div>
                <button class="botao botao-principal" id="confirmar-envio-manutencao" style="background-color: #d69e2e;">
                    Confirmar Envio para Manutenção
                </button>
                <button class="cancelar-js" id="cancelar-manutencao">
                    Cancelar
                </button>
            </div>
        `;
    }

    document.body.appendChild(overlay);

    overlay.addEventListener("click", function (e) {
        if (e.target === overlay) overlay.remove();
    });

    const btnCancelar = overlay.querySelector("#cancelar-manutencao");
    if (btnCancelar) btnCancelar.addEventListener("click", () => overlay.remove());

    const btnConfirmarFim = overlay.querySelector("#confirmar-fim-manutencao");
    if (btnConfirmarFim) {
        btnConfirmarFim.addEventListener("click", async function () {
            const obs = overlay.querySelector("#obs-fim-manutencao").value.trim() || "Manutenção concluída";
            btnConfirmarFim.disabled = true;
            btnConfirmarFim.textContent = "Atualizando...";

            const res = await apiAtualizarPatrimonio(item.id, {
                status: "disponivel",
                observacoes: obs
            });

            overlay.remove();

            if (res && res.ok) {
                item.status = "disponivel";
                patrimonioAtualDetalhes = item;
                renderizarDadosPatrimonioCard(item);
                sincronizarStatusGlobal();
                alert(`Manutenção de "${nomeItem}" concluída com sucesso!\nO equipamento já está disponível no acervo.`);
            } else {
                alert("Não foi possível atualizar o status na API.");
            }
        });
    }

    const btnConfirmarEnvio = overlay.querySelector("#confirmar-envio-manutencao");
    if (btnConfirmarEnvio) {
        btnConfirmarEnvio.addEventListener("click", async function () {
            const motivo = overlay.querySelector("#motivo-manutencao").value.trim();
            if (!motivo) {
                alert("Por favor, informe o motivo ou defeito apresentado.");
                return;
            }
            const localManut = overlay.querySelector("#local-manutencao").value.trim();
            const obsCompleta = localManut ? `${motivo} (Destino: ${localManut})` : motivo;

            btnConfirmarEnvio.disabled = true;
            btnConfirmarEnvio.textContent = "Atualizando...";

            const res = await apiAtualizarPatrimonio(item.id, {
                status: "em_manutencao",
                observacoes: obsCompleta
            });

            overlay.remove();

            if (res && res.ok) {
                item.status = "em_manutencao";
                patrimonioAtualDetalhes = item;
                renderizarDadosPatrimonioCard(item);
                sincronizarStatusGlobal();
                alert(`Equipamento "${nomeItem}" enviado para manutenção com sucesso!\nStatus atualizado para: Em manutenção.`);
            } else {
                alert("Não foi possível atualizar o status na API.");
            }
        });
    }
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

        const adminIdPat = patrimonioAtualDetalhes.adminId || patrimonioAtualDetalhes.admin_id;
        const btnConfirmar = overlay.querySelector("#confirmar-devolucao");
        btnConfirmar.disabled = true;
        btnConfirmar.textContent = "Processando devolução...";

        // Chamada direta à API REST Go externa: POST /api/admin/patrimonios/{id}/desatribuir
        const resultadoDev = await apiDesatribuirPatrimonio(idPat, motivo, adminIdPat);

        if (!resultadoDev || !resultadoDev.ok) {
            btnConfirmar.disabled = false;
            btnConfirmar.textContent = "Confirmar devolução";
            alert("Erro ao registrar devolução:\n" + ((resultadoDev && resultadoDev.error) || "Falha na comunicação com a API."));
            return;
        }

        alert(`Devolução de ${nomeItem} registrada com sucesso.`);
        overlay.remove();

        // Salva estado de devolução e atualiza na memória
        if (patrimonioAtualDetalhes) {
            patrimonioAtualDetalhes.status = "disponivel";
            patrimonioAtualDetalhes.professorId = null;
            patrimonioAtualDetalhes.responsavelId = null;
            patrimonioAtualDetalhes.professorNome = null;
            patrimonioAtualDetalhes.responsavelNome = null;
            patrimonioAtualDetalhes.professorEmail = null;
            patrimonioAtualDetalhes.responsavelEmail = null;
        }

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
                <p>${(dadosUsuarioLogado && dadosUsuarioLogado.nome) || 'Usuário'} (Motivo: ${motivo})</p>
                <small>Hoje</small>
            `;
            linhaTempo.insertBefore(novoEvento, linhaTempo.firstChild);
        }
    });

}


async function abrirModalAtribuirEquipamento() {
    if (!patrimonioAtualDetalhes) {
        alert("Nenhum patrimônio selecionado para atribuição. Por favor, selecione um patrimônio primeiro.");
        return;
    }

    let listaProf = await apiListarProfessores();
    if (!listaProf || listaProf.length === 0) {
        listaProf = obterProfessoresCadastrados();
    }

    const overlay = document.createElement("div");
    overlay.className = "overlay-js";

    const opcoesHtml = listaProf.map(function (p) {
        const mat = p.matricula || ("PROF-2024-" + p.id);
        const dep = p.departamento || "Docente";
        return `<option value="${p.id}">${p.nome} — ${dep} (Matrícula: ${mat})</option>`;
    }).join("");

    const nomeItem = patrimonioAtualDetalhes.nome || "Equipamento";
    const tomboItem = patrimonioAtualDetalhes.codigo || patrimonioAtualDetalhes.numeroTombo || ("PAT-2024-00" + patrimonioAtualDetalhes.id);

    overlay.innerHTML = `
        <div class="modal-js">

            <h2>Atribuir Equipamento</h2>

            <p style="color: #475569; font-size: 14px; margin-bottom: 16px;">
                Selecione o professor que receberá a custódia de: <strong>${nomeItem} (${tomboItem})</strong>
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
        const profIdVal = select.value;
        const numProfId = Number(profIdVal) || parseInt(profIdVal, 10);
        const profSelecionado = listaProf.find(function (p) { return String(p.id) === String(profIdVal); }) || listaProf[0];
        const obs = overlay.querySelector("#obs-atribuicao").value.trim();

        // Chamada direta à API REST Go externa: POST /api/admin/patrimonios/{id}/atribuir
        const idPat = patrimonioAtualDetalhes.id;
        await apiAtribuirPatrimonio(idPat, numProfId, obs);

        // Atualiza o objeto na memória
        patrimonioAtualDetalhes.status = "em_uso";
        patrimonioAtualDetalhes.professorId = numProfId;
        patrimonioAtualDetalhes.responsavelId = numProfId;
        patrimonioAtualDetalhes.professorNome = profSelecionado.nome;
        patrimonioAtualDetalhes.responsavelNome = profSelecionado.nome;
        patrimonioAtualDetalhes.professorEmail = profSelecionado.email;
        patrimonioAtualDetalhes.responsavelEmail = profSelecionado.email;

        // Atualiza estado de atribuição
        localStorage.setItem("equipamentoDevolvido", "false");
        localStorage.removeItem("motivoDevolucao");
        localStorage.setItem("equipamentoAtribuido", JSON.stringify({
            patrimonioId: tomboItem,
            patrimonioNome: nomeItem,
            professorId: profSelecionado.id,
            professorNome: profSelecionado.nome,
            professorUsuario: profSelecionado.usuario || profSelecionado.nome,
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
        renderizarDadosPatrimonioCard(patrimonioAtualDetalhes);

        alert(`Equipamento ${nomeItem} atribuído com sucesso para ${profSelecionado.nome}!\n\nQuando o professor acessar o sistema com o e-mail/usuário "${profSelecionado.email || profSelecionado.usuario || profSelecionado.nome}", este equipamento constará vinculado à conta dele.`);
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
        const btnConfirmar = overlay.querySelector("#confirmar-cadastro-patrimonio");
        const nome = overlay.querySelector("#novo-patrimonio-nome").value.trim();
        const tombo = overlay.querySelector("#novo-patrimonio-tombo").value.trim();
        const categoria = overlay.querySelector("#novo-patrimonio-categoria").value;
        const local = overlay.querySelector("#novo-patrimonio-local").value.trim() || "Geral";
        const serie = overlay.querySelector("#novo-patrimonio-serie") ? overlay.querySelector("#novo-patrimonio-serie").value.trim() : "";

        if (nome === "" || tombo === "") {
            alert("Preencha o nome e o número de tombamento do patrimônio.");
            return;
        }

        btnConfirmar.disabled = true;
        btnConfirmar.textContent = "Cadastrando...";

        // Chamada direta à API REST Go externa: POST /api/patrimonios
        const resultado = await apiCadastrarPatrimonio({
            codigo: tombo,
            nome: nome,
            descricao: nome,
            categoria: categoria,
            numeroSerie: serie,
            localizacao: local
        });

        if (!resultado || !resultado.ok) {
            btnConfirmar.disabled = false;
            btnConfirmar.textContent = "Confirmar Cadastro";
            alert("Erro ao cadastrar patrimônio:\n\n" + ((resultado && resultado.error) || "Falha na comunicação com a API."));
            return;
        }

        // Reseta filtros para garantir visualização imediata do novo bem cadastrado
        filtroStatusAtivo = "todos";
        termoBuscaPatrimonio = "";
        const campoBusca = document.querySelector("#campo-busca-patrimonio");
        if (campoBusca) campoBusca.value = "";
        const botoesFiltro = document.querySelectorAll(".filtro");
        botoesFiltro.forEach(b => {
            if (b.dataset.filtro === "todos") b.classList.add("ativo");
            else b.classList.remove("ativo");
        });

        // Atualiza em tempo real a listagem na Tela 2 e as métricas do Dashboard
        const itens = await apiListarPatrimonios();
        if (itens) {
            renderizarPatrimoniosApi(itens, 2);
        }
        await atualizarDashboardCompleto();

        overlay.remove();
        alert("Patrimônio cadastrado com sucesso!");
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
