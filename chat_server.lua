-- chat_server.lua - BlocOS Chat Server
-- Versão com caracteres seguros

local VERSION = "1.0.0"
local REDNET_PORT = 12345
local TIMEOUT = 300

local Server = {
    clients = {},
    rooms = {geral = {}, off = {}, ajuda = {}},
    messages = {},
    stats = {startTime = os.time(), totalMessages = 0, totalConnections = 0}
}

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

local function log(msg, tipo)
    local hora = os.date("%H:%M:%S")
    print("[" .. hora .. "] " .. msg)
end

local function addClient(id, name)
    Server.clients[id] = {
        id = id,
        name = name,
        room = "geral",
        lastSeen = os.time(),
        messages = 0
    }
    Server.rooms.geral[id] = true
    Server.stats.totalConnections = Server.stats.totalConnections + 1
    log("Novo cliente: " .. name .. " (ID: " .. id .. ")")
    broadcastToRoom("geral", "CHAT_SYSTEM|" .. name .. " entrou", id)
end

local function removeClient(id)
    local client = Server.clients[id]
    if client then
        for roomName, room in pairs(Server.rooms) do
            room[id] = nil
        end
        broadcastToRoom(client.room, "CHAT_SYSTEM|" .. client.name .. " saiu", id)
        Server.clients[id] = nil
        log("Cliente saiu: " .. client.name)
    end
end

local function broadcastToRoom(room, msg, excludeId)
    for id, _ in pairs(Server.rooms[room] or {}) do
        if id ~= excludeId and Server.clients[id] then
            rednet.send(id, msg, tostring(REDNET_PORT))
        end
    end
end

local function processMessage(senderId, msg)
    local client = Server.clients[senderId]
    if not client then return end
    
    client.lastSeen = os.time()
    local parts = {}
    for part in string.gmatch(msg, "[^|]+") do
        table.insert(parts, part)
    end
    
    if #parts == 0 then return end
    
    local cmd = parts[1]
    
    if cmd == "CHAT_HELLO" and #parts >= 2 then
        addClient(senderId, parts[2])
        rednet.send(senderId, "CHAT_WELCOME|" .. VERSION, tostring(REDNET_PORT))
        
    elseif cmd == "CHAT_MSG" and #parts >= 3 then
        client.messages = client.messages + 1
        Server.stats.totalMessages = Server.stats.totalMessages + 1
        broadcastToRoom(client.room, "CHAT_MSG|" .. client.name .. "|" .. parts[3], senderId)
        log("[" .. client.room .. "] " .. client.name .. ": " .. parts[3])
        
    elseif cmd == "CHAT_USERS" then
        local list = ""
        for id, c in pairs(Server.clients) do
            if c.room == client.room then
                list = list .. c.name .. ","
            end
        end
        rednet.send(senderId, "CHAT_USERS|" .. list, tostring(REDNET_PORT))
        
    elseif cmd == "CHAT_QUIT" then
        removeClient(senderId)
    end
end

local function main()
    term.clear()
    print("================================")
    print("   CHAT SERVER v" .. VERSION)
    print("================================")
    print()
    
    local modem = findModem()
    if not modem then
        print("ERRO: Conecte um modem wireless")
        return
    end
    
    rednet.open(modem)
    print("Modem conectado em: " .. modem)
    print("ID do servidor: " .. os.getComputerID())
    print()
    print("Servidor pronto! (Pressione Q para sair)")
    print()
    
    while true do
        local id, msg = rednet.receive(tostring(REDNET_PORT), 1)
        if id and msg then
            processMessage(id, msg)
        end
        
        local event, key = os.pullEvent("key", 0)
        if event == "key" and key == keys.q then
            break
        end
        
        local now = os.time()
        for id, client in pairs(Server.clients) do
            if now - client.lastSeen > TIMEOUT then
                log("Cliente " .. client.name .. " timeout")
                removeClient(id)
            end
        end
    end
    
    rednet.close(modem)
    print("Servidor encerrado")
end

main()