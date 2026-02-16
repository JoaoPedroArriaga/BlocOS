-- home.lua - BlocOS Home Screen
-- Versão corrigida - problema no onKeyPress resolvido

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
-- BARRA DE STATUS
-- ==========================================
local statusBar = main:addFrame()
    :setPosition(1, 1)
    :setSize(w, 1)
    :setBackground(colors.accent1)

-- Logo
statusBar:addLabel()
    :setPosition(2, 1)
    :setText(" BLOCOS ")
    :setForeground(colors.bg)

-- Relógio
local clock = statusBar:addLabel()
    :setPosition(w - 10, 1)
    :setText(os.date("%H:%M:%S"))
    :setForeground(colors.bg)

-- ==========================================
-- WIDGETS
-- ==========================================

-- Função para criar cards
local function createCard(x, y, title, value, icon, color)
    local card = main:addFrame()
        :setPosition(x, y)
        :setSize(18, 5)
        :setBackground(colors.panel)
    
    -- Borda
    card:addLabel()
        :setPosition(1, 1)
        :setSize(18, 5)
        :setBackground(colors.shadow)
        :setText("")
    
    -- Ícone
    card:addLabel()
        :setPosition(2, 2)
        :setText(icon)
        :setForeground(color)
    
    -- Título
    card:addLabel()
        :setPosition(5, 2)
        :setText(title)
        :setForeground(colors.text)
    
    -- Valor
    card:addLabel()
        :setPosition(5, 3)
        :setText(value)
        :setForeground(color)
    
    return card
end

-- Criar cards de informação
local cpuCard = createCard(3, 3, "CPU", "2%", "⚡", colors.accent1)
local memCard = createCard(23, 3, "RAM", "128KB", "📊", colors.accent2)
local diskCard = createCard(43, 3, "DISK", "45%", "💾", colors.accent3)

-- ==========================================
-- LISTA DE APPS
-- ==========================================

main:addLabel()
    :setPosition(3, 9)
    :setText("📱 APPS DISPONÍVEIS")
    :setForeground(colors.accent4)

-- Apps pré-definidos
local apps = {
    {name = "App Store", icon = "📦", color = colors.accent1, file = "apps/store.lua"},
    {name = "Chat", icon = "💬", color = colors.accent2, file = "apps/chat.lua"},
    {name = "Monitor", icon = "📊", color = colors.accent3, file = "apps/monitor.lua"},
    {name = "Config", icon = "⚙", color = colors.accent4, file = "apps/settings.lua"}
}

-- Criar botões para cada app
local startY = 11
for i, app in ipairs(apps) do
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    
    local x = 3 + col * 25
    local y = startY + row * 4
    
    -- Frame do app
    local appFrame = main:addFrame()
        :setPosition(x, y)
        :setSize(20, 3)
        :setBackground(colors.panel)
    
    -- Ícone
    appFrame:addLabel()
        :setPosition(2, 2)
        :setText(app.icon)
        :setForeground(app.color)
    
    -- Nome
    appFrame:addLabel()
        :setPosition(5, 2)
        :setText(app.name)
        :setForeground(colors.text)
    
    -- Botão de abrir (invisível, mas clicável)
    local btn = appFrame:addButton()
        :setPosition(1, 1)
        :setSize(20, 3)
        :setText("")
        :setBackground(colors.panel)
        :setForeground(colors.panel)
        :onClick(function()
            term.clear()
            shell.run(app.file)
        end)
    
    -- Efeito hover
    btn:onHover(function()
        appFrame:setBackground(colors.highlight)
        btn:setBackground(colors.highlight)
    end, function()
        appFrame:setBackground(colors.panel)
        btn:setBackground(colors.panel)
    end)
end

-- ==========================================
-- RODAPÉ
-- ==========================================
local footer = main:addFrame()
    :setPosition(1, h - 1)
    :setSize(w, 1)
    :setBackground(colors.accent5)

footer:addLabel()
    :setPosition(3, 1)
    :setText(" Q: Menu | F1: Ajuda | Clique nos apps para abrir")
    :setForeground(colors.bg)

-- ==========================================
-- CORREÇÃO: SISTEMA DE TECLAS (ANTES DAVA ERRO)
-- ==========================================

-- Criar um frame invisível para capturar teclas (solução para o erro)
local keyHandler = main:addFrame()
    :setPosition(1, 1)
    :setSize(1, 1)
    :setBackground(colors.bg)

-- Agora sim, o onKeyPress funciona corretamente
keyHandler:onKeyPress(function(key)
    if key == keys.q then
        -- Menu de saída
        local menu = main:addFrame()
            :setPosition(30, 10)
            :setSize(20, 8)
            :setBackground(colors.panel)
        
        -- Sombra
        main:addLabel()
            :setPosition(31, 11)
            :setSize(20, 8)
            :setBackground(colors.shadow)
            :setText("")
        
        menu:addLabel()
            :setPosition(3, 2)
            :setText("⚙️ BLOCOS MENU")
            :setForeground(colors.accent1)
        
        local opt1 = menu:addButton()
            :setPosition(3, 4)
            :setSize(14, 1)
            :setText("1. Reiniciar")
            :setBackground(colors.panel)
            :setForeground(colors.text)
            :onClick(function() os.reboot() end)
        
        local opt2 = menu:addButton()
            :setPosition(3, 5)
            :setSize(14, 1)
            :setText("2. Desligar")
            :setBackground(colors.panel)
            :setForeground(colors.text)
            :onClick(function() os.shutdown() end)
        
        local opt3 = menu:addButton()
            :setPosition(3, 6)
            :setSize(14, 1)
            :setText("3. Cancelar")
            :setBackground(colors.panel)
            :setForeground(colors.text)
            :onClick(function() menu:remove() end)
        
        -- Efeitos hover
        local function addHover(btn)
            btn:onHover(function()
                btn:setBackground(colors.highlight)
                btn:setForeground(colors.bg)
            end, function()
                btn:setBackground(colors.panel)
                btn:setForeground(colors.text)
            end)
        end
        
        addHover(opt1)
        addHover(opt2)
        addHover(opt3)
        
    elseif key == keys.f1 then
        -- Tela de ajuda
        local helpFrame = main:addFrame()
            :setPosition(25, 8)
            :setSize(30, 12)
            :setBackground(colors.panel)
        
        helpFrame:addLabel()
            :setPosition(3, 2)
            :setText("📚 BLOCOS HELP")
            :setForeground(colors.accent1)
        
        helpFrame:addLabel()
            :setPosition(3, 4)
            :setText("Comandos:")
            :setForeground(colors.accent3)
        
        helpFrame:addLabel()
            :setPosition(5, 5)
            :setText("Q - Menu principal")
            :setForeground(colors.text)
        
        helpFrame:addLabel()
            :setPosition(5, 6)
            :setText("F1 - Esta ajuda")
            :setForeground(colors.text)
        
        helpFrame:addLabel()
            :setPosition(5, 7)
            :setText("Clique nos apps para abrir")
            :setForeground(colors.text)
        
        helpFrame:addLabel()
            :setPosition(3, 9)
            :setText("Versão: " .. VERSION)
            :setForeground(colors.accent2)
        
        local closeBtn = helpFrame:addButton()
            :setPosition(12, 11)
            :setSize(6, 1)
            :setText("[OK]")
            :setBackground(colors.accent3)
            :setForeground(colors.bg)
            :onClick(function() helpFrame:remove() end)
        
        closeBtn:onHover(function()
            closeBtn:setBackground(colors.highlight)
        end, function()
            closeBtn:setBackground(colors.accent3)
        end)
    end
end)

-- ==========================================
-- ATUALIZAÇÕES EM TEMPO REAL
-- ==========================================

-- Atualizar relógio
local function updateClock()
    while true do
        clock:setText(os.date("%H:%M:%S"))
        sleep(1)
    end
end

-- Atualizar estatísticas (simulado)
local function updateStats()
    local cpu = 2
    local mem = 128
    local disk = 45
    
    while true do
        -- Simular variação
        cpu = math.random(1, 10)
        mem = 128 + math.random(-5, 5)
        disk = 45 + math.random(-2, 2)
        
        -- Atualizar cards
        cpuCard:removeChildren()
        cpuCard = createCard(3, 3, "CPU", cpu .. "%", "⚡", colors.accent1)
        
        memCard:removeChildren()
        memCard = createCard(23, 3, "RAM", mem .. "KB", "📊", colors.accent2)
        
        diskCard:removeChildren()
        diskCard = createCard(43, 3, "DISK", disk .. "%", "💾", colors.accent3)
        
        sleep(5)
    end
end

-- Iniciar threads
parallel.waitForAny(
    updateClock,
    updateStats,
    function() basalt.autoUpdate() end
)