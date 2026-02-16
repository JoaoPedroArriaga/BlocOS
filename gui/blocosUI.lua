-- blocosUI.lua - BlocOS GUI Framework

local themes = require("gui.themes")

local UI = {}

function UI.init()
    UI.colors = themes.get()
end

function UI.window(x, y, w, h, title)
    local c = UI.colors
    
    -- Border
    term.setBackgroundColor(c.bg)
    term.setTextColor(c.border)
    
    term.setCursorPos(x, y)
    term.write("┌" .. string.rep("─", w - 2) .. "┐")
    
    for i = 1, h - 2 do
        term.setCursorPos(x, y + i)
        term.write("│" .. string.rep(" ", w - 2) .. "│")
    end
    
    term.setCursorPos(x, y + h - 1)
    term.write("└" .. string.rep("─", w - 2) .. "┘")
    
    -- Title
    if title then
        term.setCursorPos(x + 2, y)
        term.setBackgroundColor(c.accent)
        term.setTextColor(colors.white)
        term.write(" " .. title .. " ")
    end
    
    term.setBackgroundColor(c.bg)
    term.setTextColor(c.text)
    
    return {x = x, y = y, w = w, h = h}
end

function UI.button(x, y, text, selected)
    local c = UI.colors
    local w = #text + 4
    
    if selected then
        term.setBackgroundColor(c.highlight)
        term.setTextColor(colors.white)
    else
        term.setBackgroundColor(c.accent)
        term.setTextColor(c.text)
    end
    
    term.setCursorPos(x, y)
    term.write("[" .. string.rep(" ", w - 2) .. "]")
    
    local tx = x + math.floor((w - #text) / 2)
    term.setCursorPos(tx, y)
    term.write(text)
    
    term.setBackgroundColor(c.bg)
    term.setTextColor(c.text)
    
    return {x = x, y = y, w = w, h = 1}
end

function UI.text(x, y, text, color)
    term.setCursorPos(x, y)
    term.setTextColor(color or UI.colors.text)
    term.write(text)
    term.setTextColor(UI.colors.text)
end

UI.init()
return UI