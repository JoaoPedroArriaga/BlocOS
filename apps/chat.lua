-- apps/chat.lua - BlocOS Chat App
-- App de chat multiplayer para o BlocOS

local basalt = require("basalt")
local VERSION = "1.0.0"

-- Configurações de rede
local REDNET_PORT = 12345
local SERVER_ID = nil

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
    myMessage = colors.lime,
    otherMessage = colors.lightGray,
    system = colors.purple,
    online = colors.green,
    offline = colors.gray
}

-- Tamanho da tela
local w, h = term.getSize()

-- Criar frame principal
local main = basalt.createFrame()
main:setBackground(colors.bg)

-- ==========================================
-- ESTADO DO APP
-- ==========================================

local app = {
    user = "",
    serverId = nil,
    connected = false,
    messages = {},
    users = {},
    currentRoom = "general",
    status = "offline"
}

-- ==========================================
-- FUNÇÕES DE REDE
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
        return false, "No modem found"
    end
    
    rednet.open(modem)
    
    -- Broadcast para encontrar servidor
    rednet.broadcast("CHAT_HELLO|" .. app.user, tostring(REDNET_PORT))
    
    -- Aguardar resposta
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
                app.status = "online"
                return true, "Connected"
            end
        end
    end
    
    rednet.close(modem)
    return false, "Server not found"
end

-- ==========================================
-- INTERFACE DO CHAT
-- ==========================================

-- Cabeçalho
local header = main:addFrame()
    :setPosition(1, 1)
    :setSize(w, 3)
    :setBackground(colors.accent1)

-- Título
header:addLabel()
    :setPosition(3, 1)
    :setText("💬 BLOCOS CHAT")
    :setForeground(colors.bg)

-- Status da conexão
local statusLabel = header:addLabel()
    :setPosition(w - 15, 1)
    :setText("[Desconectado]")
    :setForeground(colors.accent5)

-- Usuário logado
header:addLabel()
    :setPosition(3, 2)
    :setText("Usuário: " .. (app.user ~= "" and app.user or "Não logado"))
    :setForeground(colors.bg)

-- Botão de voltar
local backBtn = header:addButton()
    :setPosition(2, 3)
    :setSize(8, 1)
    :setText("← Home")
    :setBackground(colors.accent5)
    :setForeground(colors.white)
    :onClick(function() shell.run("home") end)

-- ==========================================
-- PAINEL DE USUÁRIOS (LATERAL)
-- ==========================================

local userPanel = main:addFrame()
    :setPosition(w - 20, 4)
    :setSize(18, h - 8)
    :setBackground(colors.panel)

userPanel:addLabel()
    :setPosition(2, 1)
    :setText("👥 Online")
    :setForeground(colors.accent1)

-- Lista de usuários
local userList = userPanel:addFrame()
    :setPosition(2, 3)
    :setSize(16, h - 12)
    :setBackground(colors.panel)

local function updateUserList()
    userList:removeChildren()
    local y = 1
    for _, user in ipairs(app.users) do
        local u = userList:addLabel()
            :setPosition(1, y)
            :setText("● " .. user)
            :setForeground(colors.online)
        y = y + 1
    end
end

-- ==========================================
=-- ÁREA DE MENSAGENS
-- ==========================================

local msgArea = main:addFrame()
    :setPosition(3, 4)
    :setSize(w - 25, h - 6)
    :setBackground(colors.bg)

local msgList = msgArea:addFrame()
    :setPosition(1, 1)
    :setSize(w - 27, h - 8)
    :setBackground(colors.bg)

local function addMessage(msg, type, user)
    table.insert(app.messages, {
        text = msg,
        type = type,
        user = user,
        time = os.date("%H:%M")
    })
    
    -- Manter só últimas 50 mensagens
    if #app.messages > 50 then
        table.remove(app.messages, 1)
    end
    
    -- Atualizar display
    msgList:removeChildren()
    local y = #app.messages
    for i, m in ipairs(app.messages) do
        local line = msgList:addLabel()
            :setPosition(1, i)
            :setText("")
        
        if m.type == "system" then
            line:setText("[" .. m.time .. "] " .. m.text)
            line:setForeground(colors.system)
        elseif m.type == "mine" then
            line:setText("[" .. m.time .. "] Você: " .. m.text)
            line:setForeground(colors.myMessage)
        else
            line:setText("[" .. m.time .. "] " .. m.user .. ": " .. m.text)
            line:setForeground(colors.otherMessage)
        end
    end
end

-- ==========================================
-- CAMPO DE INPUT
-- ==========================================

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
    :setSize(6, 1)
    :setText("[Enviar]")
    :setBackground(colors.accent3)
    :setForeground(colors.white)
    :onClick(function()
        local text = inputField:getText()
        if text ~= "" then
            if text:sub(1,1) == "/" then
                handleCommand(text)
            else
                rednet.send(app.serverId, "CHAT_MSG|" .. app.user .. "|" .. text, tostring(REDNET_PORT))
                addMessage(text, "mine")
            end
            inputField:setText("")
        end
    end)

-- Enter para enviar
inputField:onSubmit(function(text)
    if text ~= "" then
        if text:sub(1,1) == "/" then
            handleCommand(text)
        else
            rednet.send(app.serverId, "CHAT_MSG|" .. app.user .. "|" .. text, tostring(REDNET_PORT))
            addMessage(text, "mine")
        end
        inputField:setText("")
    end
end)

-- ==========================================
-- COMANDOS
-- ==========================================

local function handleCommand(cmd)
    local parts = {}
    for p in string.gmatch(cmd, "%S+") do
        table.insert(parts, p)
    end
    
    local command = parts[1]
    
    if command == "/ajuda" or command == "/help" then
        addMessage("Comandos disponíveis:", "system")
        addMessage("/users - Listar usuários", "system")
        addMessage("/clear - Limpar tela", "system")
        addMessage("/sair - Sair do chat", "system")
        
    elseif command == "/users" then
        rednet.send(app.serverId, "CHAT_USERS", tostring(REDNET_PORT))
        
    elseif command == "/clear" then
        app.messages = {}
        msgList:removeChildren()
        
    elseif command == "/sair" then
        disconnect()
        shell.run("home")
    end
end

-- ==========================================
-- CONEXÃO
-- ==========================================

local function disconnect()
    if app.connected then
        rednet.send(app.serverId, "CHAT_QUIT|" .. app.user, tostring(REDNET_PORT))
        local modem = findModem()
        if modem then
            rednet.close(modem)
        end
        app.connected = false
        app.status = "offline"
    end
end

-- ==========================================
-- TELA DE LOGIN
-- ==========================================

local function showLogin()
    -- Frame de login
    local loginFrame = main:addFrame()
        :setPosition(20, 8)
        :setSize(30, 8)
        :setBackground(colors.panel)
    
    loginFrame:addLabel()
        :setPosition(3, 2)
        :setText("🔐 Login no Chat")
        :setForeground(colors.accent1)
    
    loginFrame:addLabel()
        :setPosition(3, 4)
        :setText("Seu nome:")
        :setForeground(colors.white)
    
    local nameInput = loginFrame:addInput()
        :setPosition(3, 5)
        :setSize(20, 1)
        :setBackground(colors.bg)
        :setForeground(colors.text)
    
    local loginBtn = loginFrame:addButton()
        :setPosition(10, 7)
        :setSize(10, 1)
        :setText("[Conectar]")
        :setBackground(colors.accent3)
        :setForeground(colors.white)
        :onClick(function()
            local name = nameInput:getText()
            if name ~= "" then
                app.user = name
                loginFrame:remove()
                
                -- Tentar conectar
                local ok, err = connectToServer()
                if ok then
                    statusLabel:setText("[Conectado]")
                    statusLabel:setForeground(colors.accent3)
                    addMessage("Conectado ao servidor!", "system")
                    addMessage("Digite /ajuda para comandos", "system")
                    
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
                                        addMessage(parts[3], "other", parts[2])
                                    elseif parts[1] == "CHAT_USERS" and #parts >= 2 then
                                        app.users = {}
                                        for u in string.gmatch(parts[2], "[^,]+") do
                                            table.insert(app.users, u)
                                        end
                                        updateUserList()
                                    elseif parts[1] == "CHAT_SYSTEM" and #parts >= 2 then
                                        addMessage(parts[2], "system")
                                    end
                                end
                            end
                        end,
                        function() basalt.autoUpdate() end
                    )
                    
                else
                    statusLabel:setText("[Falha]")
                    statusLabel:setForeground(colors.accent5)
                    addMessage("Erro: " .. err, "system")
                end
            end
        end)
    
    loginBtn:onHover(function()
        loginBtn:setBackground(colors.highlight)
    end, function()
        loginBtn:setBackground(colors.accent3)
    end)
end

-- ==========================================
-- INICIAR
-- ==========================================

showLogin()

basalt.autoUpdate()

-- Garantir desconexão ao sair
local function onExit()
    disconnect()
end