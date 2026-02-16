-- home.lua - BlocOS Home Screen
-- Interface bonita usando Basalt

local basalt = require("basalt")
local VERSION = "0.1.0"

-- Detectar dispositivo
local isPocket = pocket ~= nil
local isAdvanced = term.isColor and term.isColor()

-- Ajustes de tamanho
local window = {
    width, height = term.getSize()
}

-- Criar frame principal
local main = basalt.createFrame()
main:setBackground(colors.black)
main:setForeground(colors.white)

-- ==========================================
-- BARRA DE STATUS SUPERIOR
-- ==========================================
local statusBar = main:addFrame()
    :setPosition(1, 1)
    :setSize(window.width, 1)
    :setBackground(colors.gray)

-- Logo BlocOS
statusBar:addLabel()
    :setPosition(2, 1)
    :setText(" BlocOS ")
    :setForeground(colors.cyan)
    :setBackground(colors.gray)

-- Relógio
local clock = statusBar:addLabel()
    :setPosition(window.width - 10, 1)
    :setText(os.date("%H:%M:%S"))
    :setForeground(colors.white)
    :setBackground(colors.gray)

-- ==========================================
-- ÁREA DE WIDGETS (LADO ESQUERDO)
-- ==========================================
local widgets = main:addFrame()
    :setPosition(2, 3)
    :setSize(20, 12)
    :setBackground(colors.black)

-- Título da seção
widgets:addLabel()
    :setPosition(1, 1)
    :setText("📊 WIDGETS")
    :setForeground(colors.cyan)

-- Widget 1: Informações do sistema
widgets:addLabel()
    :setPosition(1, 3)
    :setText("Sistema:")
    :setForeground(colors.green)

widgets:addLabel()
    :setPosition(1, 4)
    :setText("  • CPU: 2%")
    :setForeground(colors.white)

widgets:addLabel()
    :setPosition(1, 5)
    :setText("  • RAM: 128KB")
    :setForeground(colors.white)

-- Widget 2: Dispositivo
widgets:addLabel()
    :setPosition(1, 7)
    :setText("Dispositivo:")
    :setForeground(colors.green)

local deviceType = isPocket and "Tablet" or "PC"
widgets:addLabel()
    :setPosition(1, 8)
    :setText("  • " .. deviceType)
    :setForeground(colors.white)

if isAdvanced then
    widgets:addLabel()
        :setPosition(1, 9)
        :setText("  • Cores")
        :setForeground(colors.white)
end

-- ==========================================
-- GRID DE APPS (CENTRO)
-- ==========================================
local appsGrid = main:addFrame()
    :setPosition(25, 3)
    :setSize(30, 15)
    :setBackground(colors.black)

-- Título
appsGrid:addLabel()
    :setPosition(1, 1)
    :setText("🚀 APPS")
    :setForeground(colors.cyan)

-- Apps disponíveis
local apps = {
    {name = "App Store", file = "apps/store.lua", icon = "📦", color = colors.green},
    {name = "Chat", file = "apps/chat.lua", icon = "💬", color = colors.blue},
    {name = "Config", file = "kernel/config.lua", icon = "⚙", color = colors.yellow},
    {name = "Monitor", file = "apps/monitor.lua", icon = "📊", color = colors.purple}
}

local y = 3
for i, app in ipairs(apps) do
    -- Ícone
    appsGrid:addLabel()
        :setPosition(2, y)
        :setText(app.icon)
        :setForeground(app.color)
    
    -- Nome do app
    appsGrid:addLabel()
        :setPosition(5, y)
        :setText(app.name)
        :setForeground(colors.white)
    
    -- Botão de abrir
    local btn = appsGrid:addButton()
        :setPosition(22, y)
        :setSize(6, 1)
        :setText("[Abrir]")
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(function()
            term.clear()
            shell.run(app.file)
        end)
    
    -- Efeito hover
    btn:onHover(function()
        btn:setBackground(colors.cyan)
        btn:setForeground(colors.black)
    end, function()
        btn:setBackground(colors.gray)
        btn:setForeground(colors.white)
    end)
    
    y = y + 2
end

-- ==========================================
-- RODAPÉ COM DICAS
-- ==========================================
local footer = main:addFrame()
    :setPosition(1, window.height - 2)
    :setSize(window.width, 1)
    :setBackground(colors.gray)

footer:addLabel()
    :setPosition(2, 1)
    :setText("↑↓ Navegar | Enter Abrir | Q Menu | F1 Ajuda")
    :setForeground(colors.white)
    :setBackground(colors.gray)

-- Versão no canto
footer:addLabel()
    :setPosition(window.width - 15, 1)
    :setText("BlocOS v" .. VERSION)
    :setForeground(colors.cyan)
    :setBackground(colors.gray)

-- ==========================================
-- SISTEMA DE NAVEGAÇÃO
-- ==========================================
local selectedApp = 1

-- Função para atualizar seleção
local function updateSelection()
    -- Resetar todos os botões
    for i, app in ipairs(apps) do
        -- Aqui você implementaria a lógica de destaque
    end
    
    -- Destacar o selecionado
    -- Implementar conforme necessidade
end

-- Atalhos de teclado
main:onKeyPress(function(key)
    if key == keys.q then
        -- Menu de saída
        local menu = main:addFrame()
            :setPosition(30, 10)
            :setSize(20, 8)
            :setBackground(colors.gray)
            :setForeground(colors.white)
        
        menu:addLabel()
            :setPosition(3, 2)
            :setText("BlocOS Menu")
            :setForeground(colors.cyan)
        
        menu:addButton()
            :setPosition(3, 4)
            :setSize(14, 1)
            :setText("1. Reiniciar")
            :onClick(function() os.reboot() end)
        
        menu:addButton()
            :setPosition(3, 5)
            :setSize(14, 1)
            :setText("2. Desligar")
            :onClick(function() os.shutdown() end)
        
        menu:addButton()
            :setPosition(3, 6)
            :setSize(14, 1)
            :setText("3. Cancelar")
            :onClick(function() menu:remove() end)
        
        menu:show()
        
    elseif key == keys.f1 then
        -- Tela de ajuda
        term.clear()
        print("BlocOS Help")
        print("===========")
        print("Q: Menu principal")
        print("F1: Esta ajuda")
        print("Enter: Abrir app")
        print("↑↓: Navegar")
        print()
        print("Pressione qualquer tecla")
        os.pullEvent("key")
    end
end)

-- ==========================================
-- ATUALIZAÇÕES EM TEMPO REAL
-- ==========================================

-- Atualizar relógio a cada segundo
local function updateClock()
    while true do
        clock:setText(os.date("%H:%M:%S"))
        sleep(1)
    end
end

-- Atualizar estatísticas do sistema
local function updateStats()
    -- Simular uso de CPU e memória
    local cpu = 0
    local mem = 128
    
    while true do
        cpu = math.random(1, 10)
        mem = 128 + math.random(-10, 10)
        
        -- Atualizar widgets
        -- Implementar quando tiver labels específicas
        
        sleep(5)
    end
end

-- Iniciar threads de atualização
parallel.waitForAny(
    updateClock,
    updateStats,
    function() basalt.autoUpdate() end
)