include('shared.lua')

local function includeFiles(directory)
    local files, subdirectories = file.Find(directory .. "/*", "LUA")

    for _, fileName in ipairs(files) do
        local fullPath = directory .. "/" .. fileName
        if string.StartWith(fileName, "cl_") or string.StartWith(fileName, "sh") then
            include(fullPath)
        end
    end

    for _, subdirectory in ipairs(subdirectories) do
        includeFiles(directory .. "/" .. subdirectory)
    end
end

local foldersToInclude = {
    'anims',
    'commands',
    'core',
    'damage',
    'dropweapon',
    'jobs',
    'other',
    'panicbutton',
    'pushing',
    'ragdoll',
    'respawn',
    'vgui',
}

for _, folder in ipairs(foldersToInclude) do
    includeFiles('localrp/gamemode/' .. folder)
end
