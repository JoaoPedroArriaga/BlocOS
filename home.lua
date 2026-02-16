-- home.lua - BlocOS Home Screen

local themes = require("gui.themes")
local UI = require("gui.blocosUI")

local function drawStatusBar()
    local w, h = term.getSize()
    local c = themes.get()
    
    term.setBackgroundColor(c.accent)
    term.setTextColor(colors.white)
    
    term.setCursorPos(1, 1)
    term.write(string.rep(" ", w))
    
    term.setCursorPos(2, 1)
    term.write("BlocOS")
    
    local time = os.date("%H:%M")
    term.setCursorPos(w - #time - 1, 1)
    term.write(time)
    
    term.setBackgroundColor(c.bg)
end

local function main()
    UI.init()
    
    while true do
        term.clear()
        drawStatusBar()
        
        local w, h = term.getSize()
        
        UI.window(3, 3, 20, 10, "Apps")
        UI.button(5, 5, "Store", false)
        UI.button(5, 7, "Chat", false)
        UI.button(5, 9, "Settings", false)
        
        UI.text(3, h - 2, "Press Q for menu", colors.gray)
        
        local event, key = os.pullEvent("key")
        if key == keys.q then
            term.clear()
            print("BlocOS Menu")
            print("1. Restart")
            print("2. Shutdown")
            print("3. Exit to shell")
            local opt = read()
            if opt == "1" then
                os.reboot()
            elseif opt == "2" then
                os.shutdown()
            elseif opt == "3" then
                break
            end
        end
    end
end

main()