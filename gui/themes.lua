-- themes.lua - BlocOS Theme System

local Themes = {
    light = {
        name = "Light",
        bg = colors.white,
        text = colors.black,
        accent = colors.blue,
        highlight = colors.cyan,
        success = colors.green,
        warning = colors.yellow,
        error = colors.red,
        border = colors.gray,
        shadow = colors.lightGray
    },
    dark = {
        name = "Dark",
        bg = colors.black,
        text = colors.white,
        accent = colors.purple,
        highlight = colors.cyan,
        success = colors.green,
        warning = colors.yellow,
        error = colors.red,
        border = colors.gray,
        shadow = colors.gray
    },
    matrix = {
        name = "Matrix",
        bg = colors.black,
        text = colors.green,
        accent = colors.lime,
        highlight = colors.cyan,
        success = colors.green,
        warning = colors.yellow,
        error = colors.red,
        border = colors.gray,
        shadow = colors.gray
    }
}

local currentTheme = "light"

local function loadSavedTheme()
    if fs.exists(".blocos.cfg") then
        local f = fs.open(".blocos.cfg", "r")
        local config = textutils.unserialize(f.readAll()) or {}
        f.close()
        if config.theme and Themes[config.theme] then
            currentTheme = config.theme
        end
    end
end

loadSavedTheme()

local function get()
    return Themes[currentTheme]
end

local function set(theme)
    if Themes[theme] then
        currentTheme = theme
        -- Save to config
        local config = {}
        if fs.exists(".blocos.cfg") then
            local f = fs.open(".blocos.cfg", "r")
            config = textutils.unserialize(f.readAll()) or {}
            f.close()
        end
        config.theme = theme
        local f = fs.open(".blocos.cfg", "w")
        f.write(textutils.serialize(config))
        f.close()
        return true
    end
    return false
end

local function list()
    local names = {}
    for name, _ in pairs(Themes) do
        table.insert(names, name)
    end
    return names
end

return {
    get = get,
    set = set,
    list = list
}