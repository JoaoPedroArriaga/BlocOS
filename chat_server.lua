-- chat_server.lua - BlocOS Chat Server
-- Execute em um computador dedicado para servir o chat

local VERSION = "1.0.0"
local REDNET_PORT = 12345
local MAX_CLIENTS = 50
local TIMEOUT = 300 -- 5 minutos

-- Cores para o terminal do servidor
local colors = {
    header = colors.cyan,
    success = colors.green,
    error = colors.red,
    warning = colors.yellow,
    info = colors.white,
    highlight = colors.purple
}

-- ==========================================
-- ESTADO DO SERVIDOR
-- ==========================================

local Server = {
    clients = {},           -- Clientes conectados {id = {name, room, lastSeen}}
    rooms = {               -- Salas disponíveis
        general = {},
        off topic = {},
        ajuda = {},
        random = {}
    },
    messages = {},          -- Histórico recente
    stats = {
        startTime = os.time(),
        totalMessages = 0,
        totalConnections = 0,
        peakClients = 0
    },
    banned = {}             -- IPs/IDs banidos
}

-- ==========================================
-- FUNÇÕES DE UTILIDADE
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

local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function log(message, type)
    type = type or "info"
    local hour = os.date("%H:%M:%S")
    local color = colors.info
    
    if type == "success" then color = colors.success
    elseif type == "error" then color = colors.error
    elseif type == "warning" then color = colors.warning
    elseif type == "header" then color = colors.header
    end
    
    term.setTextColor(color)
    print("[" .. hour .. "] " .. message)
    term.setTextColor(colors.info)
end

-- ==========================================
-- FUNÇÕES DE GERENCIAMENTO DE CLIENTES
-- ==========================================

local function addClient(id, name)
    Server.clients[id] = {
        id = id,
        name = name,
        room = "general",
        joinTime = os.time(),
        lastSeen = os.time(),
        messages = 0,
        status = "online"
    }
    
    -- Adicionar à sala general
    Server.rooms.general[id] = true
    
    -- Atualizar estatísticas
    Server.stats.totalConnections = Server.stats.totalConnections + 1
    local clientCount = #Server.clients
    if clientCount > Server.stats.peakClients then
        Server.stats.peakClients = clientCount
    end
    
    log("Novo cliente: " .. name .. " (ID: " .. id .. ")", "success")
    
    -- Anunciar para outros clientes
    broadcastToRoom("general", "CHAT_SYSTEM|" .. name .. " entrou no chat", id)
end

local function removeClient(id)
    local client = Server.clients[id]
    if client then
        -- Remover das salas
        for roomName, room in pairs(Server.rooms) do
            room[id] = nil
        end
        
        -- Anunciar saída
        broadcastToRoom(client.room, "CHAT_SYSTEM|" .. client.name .. " saiu do chat", id)
        
        -- Remover da lista
        Server.clients[id] = nil
        log("Cliente desconectado: " .. client.name, "warning")
    end
end

local function getClientList(room)
    local list = {}
    for id, _ in pairs(Server.rooms[room] or {}) do
        if Server.clients[id] then
            table.insert(list, Server.clients[id].name)
        end
    end
    return table.concat(list, ",")
end

-- ==========================================
-- FUNÇÕES DE BROADCAST
-- ==========================================

local function broadcastToRoom(room, message, excludeId)
    for id, _ in pairs(Server.rooms[room] or {}) do
        if id ~= excludeId and Server.clients[id] then
            rednet.send(id, message, tostring(REDNET_PORT))
        end
    end
end

local function broadcastToAll(message, excludeId)
    for id, _ in pairs(Server.clients) do
        if id ~= excludeId then
            rednet.send(id, message, tostring(REDNET_PORT))
        end
    end
end

-- ==========================================
-- PROCESSAR MENSAGENS
-- ==========================================

local function processMessage(senderId, message)
    local client = Server.clients[senderId]
    if not client then return end
    
    -- Atualizar lastSeen
    client.lastSeen = os.time()
    
    local parts = {}
    for part in string.gmatch(message, "[^|]+") do
        table.insert(parts, part)
    end
    
    if #parts == 0 then return end
    
    local cmd = parts[1]
    
    if cmd == "CHAT_HELLO" and #parts >= 2 then
        -- Novo cliente se apresentando
        local name = parts[2]
        addClient(senderId, name)
        rednet.send(senderId, "CHAT_WELCOME|" .. VERSION, tostring(REDNET_PORT))
        
    elseif cmd == "CHAT_MSG" and #parts >= 3 then
        -- Mensagem normal
        local userName = parts[2]
        local text = parts[3]
        client.messages = client.messages + 1
        Server.stats.totalMessages = Server.stats.totalMessages + 1
        
        -- Registrar no histórico
        table.insert(Server.messages, {
            time = os.time(),
            user = userName,
            text = text,
            room = client.room
        })
        
        -- Manter só últimas 100 mensagens
        if #Server.messages > 100 then
            table.remove(Server.messages, 1)
        end
        
        -- Broadcast para a sala
        broadcastToRoom(client.room, "CHAT_MSG|" .. userName .. "|" .. text, senderId)
        
        -- Log no servidor
        log("[" .. client.room .. "] " .. userName .. ": " .. text)
        
    elseif cmd == "CHAT_USERS" then
        -- Solicitar lista de usuários
        local list = getClientList(client.room)
        rednet.send(senderId, "CHAT_USERS|" .. list, tostring(REDNET_PORT))
        
    elseif cmd == "CHAT_JOIN" and #parts >= 2 then
        -- Mudar de sala
        local newRoom = parts[2]
        if Server.rooms[newRoom] then
            -- Sair da sala atual
            Server.rooms[client.room][senderId] = nil
            
            -- Entrar na nova sala
            client.room = newRoom
            Server.rooms[newRoom][senderId] = true
            
            -- Avisar
            rednet.send(senderId, "CHAT_SYSTEM|Você entrou na sala " .. newRoom, tostring(REDNET_PORT))
            broadcastToRoom(newRoom, "CHAT_SYSTEM|" .. client.name .. " entrou na sala", senderId)
            
            log(client.name .. " mudou para sala: " .. newRoom)
        end
        
    elseif cmd == "CHAT_QUIT" then
        -- Cliente saindo
        removeClient(senderId)
        
    elseif cmd == "CHAT_PRIVATE" and #parts >= 3 then
        -- Mensagem privada
        local target = parts[2]
        local text = parts[3]
        
        -- Encontrar destinatário
        for id, c in pairs(Server.clients) do
            if c.name == target then
                rednet.send(id, "CHAT_PRIVATE|" .. client.name .. "|" .. text, tostring(REDNET_PORT))
                rednet.send(senderId, "CHAT_PRIVATE|Você para " .. target .. "|" .. text, tostring(REDNET_PORT))
                break
            end
        end
    end
end

-- ==========================================
-- INTERFACE DO SERVIDOR
-- ==========================================

local function drawHeader()
    term.clear()
    term.setTextColor(colors.header)
    print("╔══════════════════════════════════════════════════════════╗")
    print("║                   BLOCOS CHAT SERVER v" .. VERSION .. "                   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    term.setTextColor(colors.info)
    print()
end

local function showStatus()
    drawHeader()
    
    local uptime = os.time() - Server.stats.startTime
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = uptime % 60
    
    print("📊 ESTATÍSTICAS")
    print("  • Uptime: " .. string.format("%02dh %02dm %02ds", hours, minutes, seconds))
    print("  • Clientes online: " .. #Server.clients)
    print("  • Pico de clientes: " .. Server.stats.peakClients)
    print("  • Mensagens totais: " .. Server.stats.totalMessages)
    print("  • Conexões totais: " .. Server.stats.totalConnections)
    print()
    
    print("👥 CLIENTES ONLINE")
    if next(Server.clients) then
        for id, client in pairs(Server.clients) do
            local idle = os.time() - client.lastSeen
            print("  • " .. client.name .. " (ID: " .. id .. ")")
            print("      Sala: " .. client.room)
            print("      Msgs: " .. client.messages)
            print("      Inativo: " .. idle .. "s")
        end
    else
        print("  Nenhum cliente conectado")
    end
    print()
    
    print("🏠 SALAS")
    for name, room in pairs(Server.rooms) do
        local count = 0
        for _ in pairs(room) do count = count + 1 end
        print("  • " .. name .. ": " .. count .. " clientes")
    end
    print()
    
    print("📝 ÚLTIMAS MENSAGENS")
    local start = math.max(1, #Server.messages - 5)
    for i = start, #Server.messages do
        local msg = Server.messages[i]
        if msg then
            local timeStr = os.date("%H:%M", msg.time)
            print("  [" .. timeStr .. "] [" .. msg.room .. "] " .. msg.user .. ": " .. msg.text)
        end
    end
    print()
    
    print("Comandos: Q - Sair | S - Status | L - Limpar tela")
end

-- ==========================================
-- LOOP PRINCIPAL
-- ==========================================

local function main()
    drawHeader()
    
    -- Encontrar modem
    local modem = findModem()
    if not modem then
        log("ERRO: Nenhum modem encontrado!", "error")
        log("Conecte um modem wireless e tente novamente.", "error")
        return
    end
    
    rednet.open(modem)
    log("Modem conectado em: " .. modem, "success")
    log("ID do servidor: " .. os.getComputerID(), "success")
    log("Porta: " .. REDNET_PORT, "info")
    log("Servidor pronto! Aguardando conexões...", "success")
    print()
    
    -- Loop principal
    while true do
        -- Receber mensagens
        local senderId, message, protocol = rednet.receive(tostring(REDNET_PORT), 1)
        
        if senderId and message then
            -- Verificar se é banido
            if not Server.banned[senderId] then
                processMessage(senderId, message)
            end
        end
        
        -- Verificar teclas do servidor
        local event, key = os.pullEvent("key", 0)
        if event == "key" then
            if key == keys.q then
                break
            elseif key == keys.s then
                showStatus()
            elseif key == keys.l then
                drawHeader()
            end
        end
        
        -- Limpar clientes inativos
        local now = os.time()
        for id, client in pairs(Server.clients) do
            if now - client.lastSeen > TIMEOUT then
                log("Cliente " .. client.name .. " desconectado por timeout", "warning")
                removeClient(id)
            end
        end
    end
    
    -- Desconectar todos
    log("Desconectando todos os clientes...", "warning")
    broadcastToAll("CHAT_SYSTEM|Servidor está desligando...")
    sleep(1)
    
    rednet.close(modem)
    log("Servidor encerrado.", "error")
end

-- Iniciar
main()