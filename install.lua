-- install.lua - BlocOS Installer
-- Versão com caracteres seguros

local REPO = "https://raw.githubusercontent.com/JoaoPedroArriaga/BlocOS/main/"
local BASALT_URL = "https://github.com/Pyroxenium/Basalt/releases/download/v1.7/basalt.lua?raw=true"
local VERSION = "0.1.0"

local device = "Computador"
if pocket ~= nil then
    device = "Tablet"
elseif turtle ~= nil then
    device = "Turtle"
end

local colors = {
    header = colors.cyan,
    success = colors.green,
    error = colors.red,
    warning = colors.yellow,
    text = colors.white,
    bg = colors.black,
    gray = colors.gray
}

local function drawProgress(percent, text)
    local w, h = term.getSize()
    local barWidth = 40
    local barX = math.floor((w - barWidth) / 2)
    local barY = math.floor(h / 2)
    
    term.setBackgroundColor(colors.bg)
    term.setTextColor(colors.header)
    term.setCursorPos(barX, barY - 2)
    term.write("================================")
    term.setCursorPos(barX, barY - 1)
    term.write("       BlocOS Installer         ")
    term.setCursorPos(barX, barY)
    term.write("================================")
    
    term.setTextColor(colors.text)
    term.setCursorPos(barX, barY + 2)
    term.write("Dispositivo: " .. device)
    
    term.setBackgroundColor(colors.gray)
    term.setCursorPos(barX, barY + 4)
    term.write("[" .. string.rep("-", barWidth) .. "]")
    
    local filled = math.floor(barWidth * percent / 100)
    term.setBackgroundColor(colors.success)
    term.setCursorPos(barX + 1, barY + 4)
    term.write(string.rep("=", filled))
    
    term.setBackgroundColor(colors.bg)
    term.setTextColor(colors.text)
    term.setCursorPos(barX, barY + 6)
    term.write(text)
end

local function downloadFile(url, path, desc)
    write("  " .. desc .. "... ")
    
    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()
        
        local dir = path:match("(.*)/")
        if dir and not fs.exists(dir) then
            fs.makeDir(dir)
        end
        
        local f = fs.open(path, "w")
        f.write(content)
        f.close()
        
        term.setTextColor(colors.success)
        print("OK")
        term.setTextColor(colors.text)
        return true
    else
        term.setTextColor(colors.error)
        print("FALHOU")
        term.setTextColor(colors.text)
        return false
    end
end

local function isInstalled()
    return fs.exists("home.lua")
end

term.clear()
term.setTextColor(colors.header)
print("================================")
print("      BlocOS Installer         ")
print("================================")
print()
term.setTextColor(colors.text)

local installed = isInstalled()
if installed then
    print("BlocOS ja instalado!")
    print()
    print("Opcoes:")
    print("  1. Reinstalar")
    print("  2. Cancelar")
    print()
    write("Escolha (1-2): ")
    local choice = read()
    if choice == "2" then
        print()
        print("Instalacao cancelada")
        return
    end
end

print()
print("Baixando dependencias...")
downloadFile(BASALT_URL, "basalt.lua", "Basalt")

local files = {
    {path = "home.lua", desc = "Tela inicial"},
    {path = "apps/store.lua", desc = "App Store"},
    {path = "apps/chat.lua", desc = "Chat"},
    {path = "chat_server.lua", desc = "Servidor de Chat"}
}

print()
print("Baixando BlocOS...")
print()

local success = true
for i, file in ipairs(files) do
    local percent = math.floor((i - 1) / #files * 100)
    drawProgress(percent, "Baixando: " .. file.desc)
    
    local url = REPO .. file.path
    if not downloadFile(url, file.path, file.desc) then
        success = false
    end
    sleep(0.2)
end

drawProgress(100, "Criando startup...")
local startup = fs.open("startup.lua", "w")
startup.write([[
-- BlocOS - Startup
if pocket ~= nil then
    pcall(function() term.setSize(45, 20) end)
end
require("basalt")
shell.run("home")
]])
startup.close()
print("  Startup... OK")

term.clear()
term.setTextColor(success and colors.success or colors.warning)
print("================================")
if success then
    print("    BlocOS Instalado!         ")
else
    print("    Instalacao com erros      ")
end
print("================================")
print()
term.setTextColor(colors.text)
print("Versao: " .. VERSION)
print("Dispositivo: " .. device)
print()
print("Para iniciar:")
print("  os.reboot()")
print("  ou")
print("  home")
print()
print("GitHub: https://github.com/JoaoPedroArriaga/BlocOS")
print()