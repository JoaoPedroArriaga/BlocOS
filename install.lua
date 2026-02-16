-- install.lua - BlocOS Installer
-- Downloads and installs BlocOS directly from GitHub

local REPO = "https://raw.githubusercontent.com/JoaoPedroArriaga/BlocOS/main/"
local VERSION = "0.1.0"

-- Detect device
local device = "Computer"
if pocket ~= nil then
    device = "Tablet"
elseif turtle ~= nil then
    device = "Turtle"
end

-- Colors
local colors = {
    header = colors.cyan,
    success = colors.green,
    error = colors.red,
    warning = colors.yellow,
    text = colors.white
}

-- Draw progress bar
local function drawProgress(percent, text)
    local w, h = term.getSize()
    local barWidth = 40
    local barX = math.floor((w - barWidth) / 2)
    local barY = math.floor(h / 2)
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.header)
    term.setCursorPos(barX, barY - 3)
    term.write("╔══════════════════════════════════╗")
    term.setCursorPos(barX, barY - 2)
    term.write("║         BlocOS Installer         ║")
    term.setCursorPos(barX, barY - 1)
    term.write("╚══════════════════════════════════╝")
    
    term.setTextColor(colors.text)
    term.setCursorPos(barX, barY + 1)
    term.write("Device: " .. device)
    
    -- Progress bar
    term.setBackgroundColor(colors.gray)
    term.setCursorPos(barX, barY + 3)
    term.write("[" .. string.rep(" ", barWidth) .. "]")
    
    local filled = math.floor(barWidth * percent / 100)
    term.setBackgroundColor(colors.success)
    term.setCursorPos(barX + 1, barY + 3)
    term.write(string.rep("█", filled))
    
    -- Text
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.text)
    term.setCursorPos(barX, barY + 5)
    term.write(text)
end

-- Download file function
local function downloadFile(path, desc)
    write("  " .. desc .. "... ")
    
    local url = REPO .. path
    local response = http.get(url)
    
    if response then
        local content = response.readAll()
        response.close()
        
        -- Create directory if needed
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
        print("FAILED")
        term.setTextColor(colors.text)
        return false
    end
end

-- Welcome screen
term.clear()
term.setTextColor(colors.header)
print("╔══════════════════════════════════╗")
print("║         BlocOS Installer         ║")
print("╚══════════════════════════════════╝")
print()
term.setTextColor(colors.text)
print("This installer will download and install")
print("BlocOS on your " .. device .. ".")
print()
print("Repository: " .. REPO)
print()
print("Press any key to continue...")
os.pullEvent("key")

-- File list
local files = {
    -- Kernel
    {path = "kernel/boot.lua", desc = "Bootloader"},
    {path = "kernel/core.lua", desc = "Core system"},
    {path = "kernel/config.lua", desc = "Configuration"},
    
    -- GUI
    {path = "gui/blocosUI.lua", desc = "GUI Framework"},
    {path = "gui/themes.lua", desc = "Theme system"},
    {path = "gui/widgets/clock.lua", desc = "Clock widget"},
    {path = "gui/widgets/weather.lua", desc = "Weather widget"},
    {path = "gui/widgets/system.lua", desc = "System monitor"},
    
    -- Home
    {path = "home.lua", desc = "Home screen"},
    
    -- Apps
    {path = "apps/store.lua", desc = "App Store"},
    {path = "apps/chat.lua", desc = "Chat app"}
}

-- Download files
print()
print("Downloading files...")
print()

local success = true
for i, file in ipairs(files) do
    local percent = math.floor((i - 1) / #files * 100)
    drawProgress(percent, "Downloading: " .. file.desc)
    
    if not downloadFile(file.path, file.desc) then
        success = false
    end
    sleep(0.2)
end

-- Create startup file
drawProgress(100, "Creating startup file...")
local startup = fs.open("startup.lua", "w")
startup.write([[
-- BlocOS - Startup
if pocket ~= nil then
    pcall(function() term.setSize(45, 20) end)
end
shell.run("home")
]])
startup.close()
print("  Startup file... OK")

-- Final message
term.clear()
term.setTextColor(success and colors.success or colors.warning)
print("╔══════════════════════════════════╗")
if success then
    print("║   BlocOS Installed Successfully! ║")
else
    print("║   Installation completed with    ║")
    print("║         some errors              ║")
end
print("╚══════════════════════════════════╝")
print()
term.setTextColor(colors.text)
print("✅ Version: " .. VERSION)
print("✅ Device: " .. device)
print("✅ Files: " .. #files)
print()
print("📱 To start:")
print("   os.reboot()")
print("   or")
print("   home")
print()
print("🌐 GitHub: https://github.com/JoaoPedroArriaga/BlocOS")
print()
if not success then
    term.setTextColor(colors.warning)
    print("⚠️  Some files failed to download.")
    print("   Check your internet connection")
    print("   and try again.")
    print()
end
term.setTextColor(colors.text)
print("Thank you for installing BlocOS!")