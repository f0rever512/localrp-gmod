AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

-- localization
resource.AddSingleFile('resource/localization/en/lrp_gamemode.properties')
resource.AddSingleFile('resource/localization/ru/lrp_gamemode.properties')

local files, catalogs, folders

local function loadFiles(folder)
    local files, catalogs = file.Find(folder .. '/*', 'LUA')

    for _, fileName in ipairs(files) do
        local fullPath = folder .. '/' .. fileName

        if string.StartWith(fileName, 'cl_') or string.StartWith(fileName, 'sh') then
            AddCSLuaFile(fullPath)
        end

        if string.StartWith(fileName, 'sv_') or string.StartWith(fileName, 'sh') or string.StartWith(fileName, 'init') then
            include(fullPath)
        end
    end

    for _, subFolder in ipairs(catalogs) do
        loadFiles(folder .. '/' .. subFolder)
    end
end

local directory = GM.FolderName .. '/gamemode/'
local _, folders = file.Find(directory .. '*', 'LUA')

for _, folderName in SortedPairs(folders) do
    loadFiles(directory .. folderName)
end