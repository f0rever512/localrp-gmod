include('shared.lua')

local function includeFiles(folder) -- by nsfw (https://steamcommunity.com/id/NsfwS)
    local files, folders = file.Find(folder .. "/*", "LUA")
    local function shouldInclude(f)
        return string.StartWith(f, "cl_") or string.StartWith(f, "sh")
    end

    for _, f in ipairs(files) do
        local fullPath = folder .. "/" .. f
        if shouldInclude(f) then
            include(fullPath)
        end
    end

    for _, f in ipairs(folders) do
        includeFiles(folder .. "/" .. f)
    end
end


local folders = {
    'core',
    'damage',
    'jobs',
    'other',
    'panicbutton',
    'vgui',
    'commands',
    'anims',
    'dropweapon',
    'pushing'
}

for _, name in pairs(folders) do
	includeFiles('localrp/gamemode/' .. name)
end