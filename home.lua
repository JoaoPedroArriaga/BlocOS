-- home.lua - BlocOS Home Screen
-- Versão final com teclas funcionando

local basalt = require("basalt")
local VERSION = "0.1.0"

-- Detectar dispositivo
local isPocket = pocket ~= nil

-- Cores seguras
local colors = {
    bg = colors.black,
    text = colors.white,
    accent1 = colors.cyan,
    accent2 = colors.purple,
    accent3 = colors.green,
    accent4 = colors.yellow,
    accent5 = colors.red,
    highlight = colors.lime,
    panel = colors.gray
}

-- Tamanho da tela
local w, h = term.getSize()

-- Criar frame principal
local main = basalt.createFrame()
main:setBackground(colors.bg)

-- ==========================================
-- KEYHANDLER GLOBAL (SOLUÇÃO PARA TECLAS)
-- ==========================================
local keyCatcher = main:addLabel()
    :setPosition(1, 1)
    :setSize(1, 1)
    :setText("")
    :setBackground(colors.bg)
    :setForeground(colors.bg)

keyCatcher:onKey(function(key)
    if key == keys.q then
        term.clear()
        print("BlocOS MENU")
        print("===========")
        print("1. Reiniciar")
        print("2. Desligar")
        print("3. Cancelar")
        print()
        write("Escolha: ")
        local opt = read()
        if opt == "1" then
            os.reboot()
        elseif opt == "2" then
            os.shutdown()
        end
        
    elseif key == keys.f1 then
        term.clear()
        print("BlocOS HELP")
        print("===========")
        print("Q - Menu principal")
        print("F1 - Esta ajuda")
        print("Clique nos apps para abrir")
        print()
        print("Versao: " .. VERSION)
        print()
        print("Pressione qualquer tecla")
        os.pullEvent("key")
    end
end)

keyCatcher:onClick(function() end)

-- ==========================================
-- BARRA DE STATUS
-- ==========================================
local statusBar = main:addFrame()
    :setPosition(1, 1)
    :setSize(w, 1)
    :setBackground(colors.accent1)

statusBar:addLabel()
    :setPosition(2, 1)
    :setText(" BlocOS ")
    :setForeground(colors.bg)

local clock = statusBar:addLabel()
    :setPosition(w - 10, 1)
    :setText(os.date("%H:%M:%S"))
    :setForeground(colors.bg)

-- ==========================================
-- CARDS DE INFORMAÇÃO
-- ==========================================
local function createCard(x, y, title, value, icon, color)
    local card = main:addFrame()
        :setPosition(x, y)
        :setSize(18, 5)
        :setBackground(colors.panel)
    
    card:addLabel()
        :setPosition(2, 2)
        :setText("[" .. icon .. "]")
        :setForeground(color)
    
    card:addLabel()
        :setPosition(5, 2)
        :setText(title)
        :setForeground(colors.text)
    
    card:addLabel()
        :setPosition(5, 3)
        :setText(value)
        :setForeground(color)
    
    return card
end

local cpuCard = createCard(3, 3, "CPU", "2%", "C", colors.accent1)
local memCard = createCard(23, 3, "RAM", "128KB", "M", colors.accent2)
local diskCard = createCard(43, 3, "DISK", "45%", "D", colors.accent3)

-- ==========================================
-- LISTA DE APPS
-- ==========================================
main:addLabel()
    :setPosition(3, 9)
    :setText("APPS DISPONIVEIS")
    :setForeground(colors.accent4)

local apps = {
    {name = "App Store", file = "apps/store.lua", icon = "S", color = colors.accent1},
    {name = "Chat", file = "apps/chat.lua", icon = "C", color = colors.accent2},
    {name = "Monitor", file = "apps/monitor.lua", icon = "M", color = colors.accent3},
    {name = "Config", file = "apps/settings.lua", icon = "G", color = colors.accent4}
}

local startY = 11
for i, app in ipairs(apps) do
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    
    local x = 3 + col * 25
    local y = startY + row * 4
    
    local appFrame = main:addFrame()
        :setPosition(x, y)
        :setSize(20, 3)
        :setBackground(colors.panel)
    
    appFrame:addLabel()
        :setPosition(2, 2)
        :setText("[" .. app.icon .. "]")
        :setForeground(app.color)
    
    appFrame:addLabel()
        :setPosition(5, 2)
        :setText(app.name)
        :setForeground(colors.text)
    
    appFrame:onClick(function()
        term.clear()
        shell.run(app.file)
    end)
    
    appFrame:onHover(function()
        appFrame:setBackground(colors.highlight)
    end)
    
    appFrame:onLeave(function()
        appFrame:setBackground(colors.panel)
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
    :setText(" Q: Menu | F1: Ajuda | Clique nos apps")
    :setForeground(colors.bg)

-- ==========================================
-- ATUALIZAÇÕES
-- ==========================================
local function updateClock()
    while true do
        clock:setText(os.date("%H:%M:%S"))
        sleep(1)
    end
end

local function updateStats()
    while true do
        local cpu = math.random(1, 10)
        local mem = 128 + math.random(-5, 5)
        local disk = 45 + math.random(-2, 2)
        
        cpuCard:remove()
        memCard:remove()
        diskCard:remove()
        
        cpuCard = createCard(3, 3, "CPU", cpu .. "%", "C", colors.accent1)
        memCard = createCard(23, 3, "RAM", mem .. "KB", "M", colors.accent2)
        diskCard = createCard(43, 3, "DISK", disk .. "%", "D", colors.accent3)
        
        sleep(5)
    end
end

parallel.waitForAny(
    updateClock,
    updateStats,
    function() basalt.autoUpdate() end
)