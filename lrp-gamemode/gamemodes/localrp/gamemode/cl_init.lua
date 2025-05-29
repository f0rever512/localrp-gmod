include('shared.lua')

local files, catalogs, folders

local function loadFiles(folder)
    local files, catalogs = file.Find(folder .. '/*', 'LUA')

    for _, fileName in ipairs(files) do
        local fullPath = folder .. '/' .. fileName
        
        if string.StartWith(fileName, 'cl_') or string.StartWith(fileName, 'sh') then
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