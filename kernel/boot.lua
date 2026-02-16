-- boot.lua - BlocOS Bootloader
-- Detects device and loads the system

local function detectDevice()
    local device = {
        type = "computer",
        isPocket = pocket ~= nil,
        isTurtle = turtle ~= nil,
        isAdvanced = term.isColor and term.isColor(),
        termSize = {term.getSize()}
    }
    
    if device.isPocket then
        device.type = "tablet"
        -- Optimize for tablet
        pcall(function() term.setSize(45, 20) end)
    elseif device.isTurtle then
        device.type = "turtle"
    end
    
    return device
end

local function loadConfig()
    if fs.exists(".blocos.cfg") then
        local f = fs.open(".blocos.cfg", "r")
        local content = f.readAll()
        f.close()
        return textutils.unserialize(content) or {}
    end
    return {}
end

local function boot()
    term.clear()
    term.setCursorPos(1, 1)
    
    -- Boot animation
    term.setTextColor(colors.cyan)
    print("╔══════════════════════════════════╗")
    print("║         BlocOS v0.1.0            ║")
    print("║    Booting system...             ║")
    print("╚══════════════════════════════════╝")
    
    local device = detectDevice()
    print("Device: " .. device.type)
    
    local config = loadConfig()
    print("Theme: " .. (config.theme or "light"))
    
    sleep(1)
    
    -- Start home screen
    term.clear()
    shell.run("home")
end

boot()