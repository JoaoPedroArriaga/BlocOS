-- home.lua - BlocOS Home Screen
-- Versão com visual moderno e efeitos

local basalt = require("basalt")
local VERSION = "0.1.0"

-- Detectar dispositivo
local isPocket = pocket ~= nil
local isAdvanced = term.isColor and term.isColor()

-- Cores do tema
local colors = {
    bg = colors.black,
    text = colors.white,
    accent1 = colors.cyan,
    accent2 = colors.purple,
    accent3 = colors.green,
    accent4 = colors.yellow,
    accent5 = colors.red,
    highlight = colors.lime,
    panel = colors.gray,
    shadow = colors.gray
}

-- Tamanho da tela
local w, h = term.getSize()

-- Criar frame principal
local main = basalt.createFrame()
main:setBackground(colors.bg)

-- ==========================================
-- FUNDO COM GRADIENTE (simulado)
-- ==========================================
for i = 1, h do
    local gradient = main:addLabel()
        :setPosition(1, i)
        :setSize(w, 1)
        :setBackground(colors.bg)
        :setText(string.rep(" ", w))
    
    -- Efeito de gradiente (mais claro no centro)
    if i > h/3 and i < 2*h/3 then
        gradient:setBackground(colors.shadow)
    end
end

-- ==========================================
-- BARRA DE STATUS SUPERIOR (ESTILO MAC)
-- ==========================================
local statusBar = main:addFrame()
    :setPosition(1, 1)
    :setSize(w, 2)
    :setBackground(colors.bg)

-- Efeito de vidro (borda inferior)
statusBar:addLabel()
    :setPosition(1, 2)
    :setSize(w, 1)
    :setBackground(colors.accent1)
    :setText("")
    :setForeground(colors.accent1)

-- Logo BlocOS com estilo
local logo = statusBar:addLabel()
    :setPosition(3, 1)
    :setText("◉ BLOCOS")
    :setForeground(colors.accent1)
    :setBackground(colors.bg)

-- Efeito de brilho no logo (hover)
logo:onHover(function()
    logo:setForeground(colors.highlight)
end, function()
    logo:setForeground(colors.accent1)
end)

-- Relógio digital estilizado
local clock = statusBar:addLabel()
    :setPosition(w - 15, 1)
    :setText("[" .. os.date("%H:%M:%S") .. "]")
    :setForeground(colors.accent2)
    :setBackground(colors.bg)

-- Bateria (simulada)
local battery = statusBar:addLabel()
    :setPosition(w - 5, 1)
    :setText("⚡100%")
    :setForeground(colors.accent3)
    :setBackground(colors.bg)

-- ==========================================
-- PAINEL PRINCIPAL COM SOMBRA
-- ==========================================
local mainPanel = main:addFrame()
    :setPosition(3, 4)
    :setSize(w - 6, h - 8)
    :setBackground(colors.panel)

-- Sombra do painel (efeito 3D)
main:addLabel()
    :setPosition(4, 5)
    :setSize(w - 6, h - 8)
    :setBackground(colors.shadow)
    :setText("")
    :setForeground(colors.shadow)

-- ==========================================
-- CABEÇALHO DO PAINEL
-- ==========================================
local panelHeader = main:addFrame()
    :setPosition(5, 5)
    :setSize(w - 8, 2)
    :setBackground(colors.accent1)

panelHeader:addLabel()
    :setPosition(3, 1)
    :setText("🚀 BLOCOS DASHBOARD")
    :setForeground(colors.bg)
    :setBackground(colors.accent1)

panelHeader:addLabel()
    :setPosition(w - 20, 1)
    :setText("v" .. VERSION)
    :setForeground(colors.bg)
    :setBackground(colors.accent1)

-- ==========================================
-- WIDGETS (CARDS MODERNOS)
-- ==========================================

-- Função para criar cards
local function createCard(x, y, title, value, icon, color)
    local card = main:addFrame()
        :setPosition(x, y)
        :setSize(18, 5)
        :setBackground(colors.bg)
    
    -- Borda do card
    card:addLabel()
        :setPosition(1, 1)
        :setSize(18, 5)
        :setBackground(colors.gray)
        :setText("")
    
    -- Ícone
    card:addLabel()
        :setPosition(2, 2)
        :setText(icon)
        :setForeground(color)
        :setBackground(colors.bg)
    
    -- Título
    card:addLabel()
        :setPosition(5, 2)
        :setText(title)
        :setForeground(colors.white)
        :setBackground(colors.bg)
    
    -- Valor
    local val = card:addLabel()
        :setPosition(5, 3)
        :setText(value)
        :setForeground(color)
        :setBackground(colors.bg)
    
    return card
end

-- Criar cards
local card1 = createCard(7, 8, "CPU", "2%", "⚡", colors.accent1)
local card2 = createCard(27, 8, "RAM", "128KB", "📊", colors.accent2)
local card3 = createCard(47, 8, "STORAGE", "45%", "💾", colors.accent3)

-- ==========================================
-- LISTA DE APPS (ESTILO MODERNO)
-- ==========================================
local appsTitle = main:addLabel()
    :setPosition(7, 15)
    :setText("📱 APPS DISPONÍVEIS")
    :setForeground(colors.accent4)
    :setBackground(colors.bg)

-- Apps com design de cards
local apps = {
    {name = "App Store", icon = "📦", color = colors.accent1, file = "apps/store.lua", desc = "Baixe novos apps"},
    {name = "Chat", icon = "💬", color = colors.accent2, file = "apps/chat.lua", desc = "Converse com amigos"},
    {name = "Monitor", icon = "📊", color = colors.accent3, file = "apps/monitor.lua", desc = "Veja estatísticas"},
    {name = "Config", icon = "⚙", color = colors.accent4, file = "kernel/config.lua", desc = "Ajustes do sistema"},
    {name = "Arquivos", icon = "📁", color = colors.accent5, file = "apps/files.lua", desc = "Gerenciar arquivos"},
    {name = "Calc", icon = "🧮", color = colors.accent1, file = "apps/calc.lua", desc = "Calculadora"}
}

local startY = 17
for i, app in ipairs(apps) do
    local col = (i - 1) % 3
    local row = math.floor((i - 1) / 3)
    
    local x = 7 + col * 20
    local y = startY + row * 6
    
    -- Card do app
    local appCard = main:addFrame()
        :setPosition(x, y)
        :setSize(18, 5)
        :setBackground(colors.bg)
    
    -- Borda
    appCard:addLabel()
        :setPosition(1, 1)
        :setSize(18, 5)
        :setBackground(colors.gray)
        :setText("")
    
    -- Ícone grande
    appCard:addLabel()
        :setPosition(2, 2)
        :setText(app.icon)
        :setForeground(app.color)
        :setBackground(colors.bg)
        :setFontSize(2)  -- Ícone maior (se suportado)
    
    -- Nome do app
    appCard:addLabel()
        :setPosition(5, 2)
        :setText(app.name)
        :setForeground(colors.white)
        :setBackground(colors.bg)
    
    -- Descrição
    appCard:addLabel()
        :setPosition(5, 3)
        :setText(app.desc)
        :setForeground(colors.gray)
        :setBackground(colors.bg)
    
    -- Botão de abrir (estilo moderno)
    local openBtn = appCard:addButton()
        :setPosition(12, 4)
        :setSize(5, 1)
        :setText("▶")
        :setBackground(app.color)
        :setForeground(colors.bg)
        :onClick(function()
            term.clear()
            shell.run(app.file)
        end)
    
    -- Efeito hover no card inteiro
    local function highlightCard()
        appCard:setBackground(colors.highlight)
        openBtn:setBackground(colors.white)
        openBtn:setForeground(colors.black)
    end
    
    local function unhighlightCard()
        appCard:setBackground(colors.bg)
        openBtn:setBackground(app.color)
        openBtn:setForeground(colors.bg)
    end
    
    appCard:onHover(highlightCard, unhighlightCard)
end

-- ==========================================
-- RODAPÉ COM DICAS (ESTILO MODERNO)
-- ==========================================
local footer = main:addFrame()
    :setPosition(1, h - 2)
    :setSize(w, 1)
    :setBackground(colors.accent5)

footer:addLabel()
    :setPosition(3, 1)
    :setText("🔹 Q: Menu  🔹 F1: Ajuda  🔹 ↑↓: Navegar  🔹 Enter: Abrir")
    :setForeground(colors.bg)
    :setBackground(colors.accent5)

-- ==========================================
-- MENU FLUTUANTE (ESTILO MODERNO)
-- ==========================================
local function showModernMenu()
    local menu = main:addFrame()
        :setPosition(30, 10)
        :setSize(25, 10)
        :setBackground(colors.bg)
    
    -- Sombra
    main:addLabel()
        :setPosition(31, 11)
        :setSize(25, 10)
        :setBackground(colors.gray)
        :setText("")
    
    -- Título do menu
    menu:addLabel()
        :setPosition(3, 2)
        :setText("⚙️ BLOCOS MENU")
        :setForeground(colors.accent1)
        :setBackground(colors.bg)
    
    -- Opções
    local opt1 = menu:addButton()
        :setPosition(3, 4)
        :setSize(19, 1)
        :setText("🔄  Reiniciar")
        :setBackground(colors.bg)
        :setForeground(colors.white)
        :onClick(function() os.reboot() end)
    
    local opt2 = menu:addButton()
        :setPosition(3, 5)
        :setSize(19, 1)
        :setText("⏻  Desligar")
        :setBackground(colors.bg)
        :setForeground(colors.white)
        :onClick(function() os.shutdown() end)
    
    local opt3 = menu:addButton()
        :setPosition(3, 6)
        :setSize(19, 1)
        :setText("✕  Cancelar")
        :setBackground(colors.bg)
        :setForeground(colors.white)
        :onClick(function() menu:remove() end)
    
    -- Efeitos hover
    local function addHover(btn)
        btn:onHover(function()
            btn:setBackground(colors.accent1)
            btn:setForeground(colors.bg)
        end, function()
            btn:setBackground(colors.bg)
            btn:setForeground(colors.white)
        end)
    end
    
    addHover(opt1)
    addHover(opt2)
    addHover(opt3)
end

-- ==========================================
-- ATALHOS DE TECLADO
-- ==========================================
main:onKeyPress(function(key)
    if key == keys.q then
        showModernMenu()
    elseif key == keys.f1 then
        -- Tela de ajuda estilizada
        term.clear()
        term.setTextColor(colors.cyan)
        print("╔══════════════════════════════════╗")
        print("║         BLOCOS HELP              ║")
        print("╚══════════════════════════════════╝")
        term.setTextColor(colors.white)
        print()
        print("📌 Comandos Disponíveis:")
        print("   Q  - Menu principal")
        print("   F1 - Esta ajuda")
        print("   Enter - Abrir app")
        print("   ↑/↓ - Navegar")
        print()
        print("📱 Apps:")
        for i, app in ipairs(apps) do
            print("   " .. app.icon .. " " .. app.name .. " - " .. app.desc)
        end
        print()
        print("Pressione qualquer tecla para voltar")
        os.pullEvent("key")
    end
end)

-- ==========================================
-- ATUALIZAÇÕES EM TEMPO REAL
-- ==========================================

-- Atualizar relógio
local function updateClock()
    while true do
        clock:setText("[" .. os.date("%H:%M:%S") .. "]")
        sleep(1)
    end
end

-- Atualizar estatísticas
local function updateStats()
    local cpu = 0
    while true do
        cpu = math.random(1, 20)
        -- Atualizar cards quando implementarmos referências diretas
        sleep(3)
    end
end

-- Iniciar threads
parallel.waitForAny(
    updateClock,
    updateStats,
    function() basalt.autoUpdate() end
)