-- apps/chat.lua - BlocOS Chat App
-- Versão corrigida com métodos reais do Basalt

local basalt = require("basalt")
local VERSION = "1.0.0"

local REDNET_PORT = 12345

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
    panel = colors.gray,
    online = colors.green,
    offline = colors.gray
}

local w, h = term.getSize()
local main = basalt.createFrame()
main:setBackground(colors.bg)

-- Estado
local app = {
    user = "",
    serverId = nil,
    connected = false,
    messages = {},
    users = {}
}

-- ==========================================
-- FUNCOES DE REDE
-- ==========================================

local function findModem()
    local sides = {"left", "right", "top", "bottom", "front", "back"}
    for _, side in ipairs(sides) do
        if peripheral.isPresent(side) then
            local typ = peripheral.getType(side)
            if typ == "modem" or typ == "wireless_modem" then
                return side
            end
        end
    end
    return nil
end

local function connectToServer()
    local modem = findModem()
    if not modem then
        return false, "Sem modem"
    end
    
    rednet.open(modem)
    rednet.broadcast("CHAT_HELLO|" .. app.user, tostring(REDNET_PORT))
    
    local timeout = os.time() + 5
    while os.time() < timeout do
        local id, msg = rednet.receive(tostring(REDNET_PORT), 1)
        if id and msg then
            local parts = {}
            for part in string.gmatch(msg, "[^|]+") do
                table.insert(parts, part)
            end
            if parts[1] == "CHAT_WELCOME" then
                app.serverId = id
                app.connected = true
                return true, "Conectado"
            end
        end
    end
    
    rednet.close(modem)
    return false, "Servidor nao encontrado"
end

local function disconnect()
    if app.connected then
        rednet.send(app.serverId, "CHAT_QUIT|" .. app.user, tostring(REDNET_PORT))
        local modem = findModem()
        if modem then
            rednet.close(modem)
        end
        app.connected = false
    end
end

-- ==========================================
-- INTERFACE
-- ==========================================

-- Cabecalho
local header = main:addFrame()
    :setPosition(1, 1)
    :setSize(w, 2)
    :setBackground(colors.accent1)

header:addLabel()
    :setPosition(3, 1)
    :setText("CHAT")
    :setForeground(colors.bg)

local statusLabel = header:addLabel()
    :setPosition(w - 15, 1)
    :setText("[ Desconectado ]")
    :setForeground(colors.accent5)

local backBtn = header:addButton()
    :setPosition(2, 2)
    :setSize(8, 1)
    :setText("[ Home ]")
    :setBackground(colors.accent5)
    :setForeground(colors.text)
    :onClick(function() shell.run("home") end)

-- Painel de usuarios
local userPanel = main:addFrame()
    :setPosition(w - 20, 4)
    :setSize(18, h - 6)
    :setBackground(colors.panel)

userPanel:addLabel()
    :setPosition(2, 1)
    :setText("Usuarios")
    :setForeground(colors.accent1)

local userList = userPanel:addFrame()
    :setPosition(2, 3)
    :setSize(16, h - 10)
    :setBackground(colors.panel)

-- Area de mensagens
local msgArea = main:addFrame()
    :setPosition(3, 4)
    :setSize(w - 25, h - 6)
    :setBackground(colors.bg)

local msgList = msgArea:addFrame()
    :setPosition(1, 1)
    :setSize(w - 27, h - 8)
    :setBackground(colors.bg)

-- Campo de input
local inputFrame = main:addFrame()
    :setPosition(3, h - 2)
    :setSize(w - 25, 1)
    :setBackground(colors.panel)

local inputField = inputFrame:addInput()
    :setPosition(2, 1)
    :setSize(w - 30, 1)
    :setBackground(colors.bg)
    :setForeground(colors.text)
    :setPlaceholder("Digite sua mensagem...")

local sendBtn = inputFrame:addButton()
    :setPosition(w - 28, 1)
    :setSize(8, 1)
    :setText("[ Enviar ]")
    :setBackground(colors.accent3)
    :setForeground(colors.text)
    :onClick(function() sendMessage() end)

-- ==========================================
-- FUNCOES DO CHAT
-- ==========================================

local function sendMessage()
    local text = inputField:getText()
    if text ~= "" then
        rednet.send(app.serverId, "CHAT_MSG|" .. app.user .. "|" .. text, tostring(REDNET_PORT))
        addMessage(text, "voce")
        inputField:setText("")
    end
end

inputField:onSubmit(function(text)
    if text ~= "" then
        rednet.send(app.serverId, "CHAT_MSG|" .. app.user .. "|" .. text, tostring(REDNET_PORT))
        addMessage(text, "voce")
        inputField:setText("")
    end
end)

local function addMessage(text, tipo, user)
    local msg = {
        text = text,
        tipo = tipo,
        user = user,
        hora = os.date("%H:%M")
    }
    table.insert(app.messages, msg)
    if #app.messages > 50 then
        table.remove(app.messages, 1)
    end
    
    msgList:removeChildren()
    local y = 1
    for _, m in ipairs(app.messages) do
        local line = msgList:addLabel()
            :setPosition(1, y)
            :setText("")
        
        if m.tipo == "sistema" then
            line:setText("[" .. m.hora .. "] " .. m.text)
            line:setForeground(colors.accent4)
        elseif m.tipo == "voce" then
            line:setText("[" .. m.hora .. "] Voce: " .. m.text)
            line:setForeground(colors.accent3)
        else
            line:setText("[" .. m.hora .. "] " .. m.user .. ": " .. m.text)
            line:setForeground(colors.text)
        end
        y = y + 1
    end
end

local function updateUserList()
    userList:removeChildren()
    local y = 1
    for _, user in ipairs(app.users) do
        userList:addLabel()
            :setPosition(1, y)
            :setText("[O] " .. user)
            :setForeground(colors.online)
        y = y + 1
    end
end

-- ==========================================
-- TELA DE LOGIN
-- ==========================================
local loginFrame = main:addFrame()
    :setPosition(20, 8)
    :setSize(30, 8)
    :setBackground(colors.panel)

loginFrame:addLabel()
    :setPosition(3, 2)
    :setText("LOGIN")
    :setForeground(colors.accent1)

loginFrame:addLabel()
    :setPosition(3, 4)
    :setText("Seu nome:")
    :setForeground(colors.text)

local nameInput = loginFrame:addInput()
    :setPosition(3, 5)
    :setSize(20, 1)
    :setBackground(colors.bg)
    :setForeground(colors.text)

local loginBtn = loginFrame:addButton()
    :setPosition(10, 7)
    :setSize(10, 1)
    :setText("[ Conectar ]")
    :setBackground(colors.accent3)
    :setForeground(colors.text)
    :onClick(function()
        local name = nameInput:getText()
        if name ~= "" then
            app.user = name
            loginFrame:remove()
            
            local ok, err = connectToServer()
            if ok then
                statusLabel:setText("[ Conectado ]")
                statusLabel:setForeground(colors.accent3)
                addMessage("Conectado ao servidor", "sistema")
                
                -- Thread de recebimento
                parallel.waitForAny(
                    function()
                        while app.connected do
                            local id, msg = rednet.receive(tostring(REDNET_PORT), 1)
                            if id and id == app.serverId then
                                local parts = {}
                                for p in string.gmatch(msg, "[^|]+") do
                                    table.insert(parts, p)
                                end
                                if parts[1] == "CHAT_MSG" and #parts >= 3 then
                                    addMessage(parts[3], "outro", parts[2])
                                elseif parts[1] == "CHAT_USERS" and #parts >= 2 then
                                    app.users = {}
                                    for u in string.gmatch(parts[2], "[^,]+") do
                                        table.insert(app.users, u)
                                    end
                                    updateUserList()
                                elseif parts[1] == "CHAT_SYSTEM" and #parts >= 2 then
                                    addMessage(parts[2], "sistema")
                                end
                            end
                        end
                    end,
                    function() basalt.autoUpdate() end
                )
            else
                statusLabel:setText("[ Falha ]")
                statusLabel:setForeground(colors.accent5)
                addMessage("Erro: " .. err, "sistema")
            end
        end
    end)

loginBtn:onHover(function()
    loginBtn:setBackground(colors.highlight)
end)
loginBtn:onLeave(function()
    loginBtn:setBackground(colors.accent3)
end)

basalt.autoUpdate()