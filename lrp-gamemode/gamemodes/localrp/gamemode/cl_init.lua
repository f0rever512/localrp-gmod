include('shared.lua')

local function includeFiles(folder) -- by nsfw (https://steamcommunity.com/id/NsfwS)
    local files, folders = file.Find(folder .. "/*", "LUA")
    
    for _, f in ipairs(files) do
        local fullPath = folder .. "/" .. f
        if string.StartWith(f, "cl_") or string.StartWith(f, 'sh') then
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
    'voicechat'
}

for _, name in pairs(folders) do
	includeFiles('localrp/gamemode/' .. name)
end