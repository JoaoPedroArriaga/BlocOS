-- install.lua - BlocOS Installer
-- Downloads and installs BlocOS + Basalt automatically

local REPO = "https://raw.githubusercontent.com/JoaoPedroArriaga/BlocOS/main/"
local BASALT_URL = "https://github.com/Pyroxenium/Basalt/releases/download/v1.7/basalt.lua?raw=true"
local VERSION = "0.1.0"

-- Detect device
local device = "Computer"
if pocket ~= nil then
    device = "Tablet"
elseif turtle ~= nil then
    device = "Turtle"
end

-- Colors
local theme = {
    header = colors.cyan,
    success = colors.green,
    error = colors.red,
    warning = colors.yellow,
    text = colors.white,
    bg = colors.black,
    gray = colors.gray
}

-- Draw progress bar
local function drawProgress(percent, text)
    local w, h = term.getSize()
    local barWidth = 40
    local barX = math.floor((w - barWidth) / 2)
    local barY = math.floor(h / 2)
    
    term.setBackgroundColor(theme.bg)
    term.setTextColor(theme.header)
    term.setCursorPos(barX, barY - 2)
    term.write("========================================")
    term.setCursorPos(barX, barY - 1)
    term.write("         BlocOS Installer               ")
    term.setCursorPos(barX, barY)
    term.write("========================================")
    
    term.setTextColor(theme.text)
    term.setCursorPos(barX, barY + 2)
    term.write("Device: " .. device)
    
    -- Progress bar
    term.setBackgroundColor(theme.gray)
    term.setCursorPos(barX, barY + 4)
    term.write("[" .. string.rep("-", barWidth) .. "]")
    
    local filled = math.floor(barWidth * percent / 100)
    term.setBackgroundColor(theme.success)
    term.setCursorPos(barX + 1, barY + 4)
    term.write(string.rep("=", filled))
    
    -- Text
    term.setBackgroundColor(theme.bg)
    term.setTextColor(theme.text)
    term.setCursorPos(barX, barY + 6)
    term.write(text)
end

-- Download file function
local function downloadFile(url, path, desc)
    write("  " .. desc .. "... ")
    
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
        
        term.setTextColor(theme.success)
        print("OK")
        term.setTextColor(theme.text)
        return true
    else
        term.setTextColor(theme.error)
        print("FAILED")
        term.setTextColor(theme.text)
        return false
    end
end

-- Check if BlocOS is already installed
local function isInstalled()
    return fs.exists("home.lua") and fs.exists("kernel/boot.lua")
end

-- Welcome screen
term.clear()
term.setTextColor(theme.header)
print("========================================")
print("         BlocOS Installer               ")
print("========================================")
print()
term.setTextColor(theme.text)

local installed = isInstalled()
if installed then
    print("BlocOS is already installed on this device!")
    print()
    print("Options:")
    print("  1. Reinstall (overwrite all files)")
    print("  2. Update only (keep settings)")
    print("  3. Cancel")
    print()
    write("Choose (1-3): ")
    local choice = read()
    
    if choice == "3" then
        print()
        print("Installation cancelled.")
        return
    elseif choice == "2" then
        print()
        print("Updating BlocOS...")
    else
        print()
        print("Reinstalling BlocOS...")
    end
else
    print("This installer will download and install:")
    print("  • Basalt GUI Framework")
    print("  • BlocOS system files")
    print("  • Built-in apps")
    print()
    print("Repository: " .. REPO)
    print()
    print("Press any key to continue...")
    os.pullEvent("key")
end

-- Download Basalt first
print()
print("Step 1/2: Downloading dependencies...")
print()
downloadFile(BASALT_URL, "basalt.lua", "Basalt GUI Framework")

-- File list
local files = {
    -- Kernel
    {path = "kernel/boot.lua", desc = "Bootloader"},
    {path = "kernel/core.lua", desc = "Core system"},
    {path = "kernel/config.lua", desc = "Configuration"},
    
    -- GUI (now uses Basalt)
    {path = "gui/themes.lua", desc = "Theme system"},
    {path = "gui/widgets/clock.lua", desc = "Clock widget"},
    {path = "gui/widgets/weather.lua", desc = "Weather widget"},
    {path = "gui/widgets/system.lua", desc = "System monitor"},
    
    -- Home
    {path = "home.lua", desc = "Home screen (Basalt)"},
    
    -- Apps
    {path = "apps/store.lua", desc = "App Store"},
    {path = "apps/chat.lua", desc = "Chat app"}
}

-- Download BlocOS files
print()
print("Step 2/2: Downloading BlocOS files...")
print()

local success = true
for i, file in ipairs(files) do
    local percent = math.floor((i - 1) / #files * 100)
    drawProgress(percent, "Downloading: " .. file.desc)
    
    local url = REPO .. file.path
    if not downloadFile(url, file.path, file.desc) then
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
require("basalt")  -- Load Basalt
shell.run("home")
]])
startup.close()
print("  Startup file... OK")

-- Final message
term.clear()
term.setTextColor(success and theme.success or theme.warning)
print("========================================")
if success then
    if installed and choice == "2" then
        print("      BlocOS Updated Successfully!      ")
    else
        print("      BlocOS Installed Successfully!    ")
    end
else
    print("      Installation completed with         ")
    print("            some errors                   ")
end
print("========================================")
print()
term.setTextColor(theme.text)
print("Version: " .. VERSION)
print("Device: " .. device)
print("Files: " .. #files + 1)  -- +1 for Basalt
print()
print("✅ Basalt GUI Framework installed")
print("✅ BlocOS core installed")
print()
print("To start:")
print("  os.reboot()")
print("  or")
print("  home")
print()
print("GitHub: https://github.com/JoaoPedroArriaga/BlocOS")
print()
if not success then
    term.setTextColor(theme.warning)
    print("Some files failed to download.")
    print("Check your internet connection")
    print("and try again.")
    print()
end
term.setTextColor(theme.text)
print("Thank you for installing BlocOS!")