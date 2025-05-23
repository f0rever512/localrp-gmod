AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local function loadFiles(folder)
    local files, folders = file.Find(folder .. '/*', 'LUA')

    for _, fileName in ipairs(files) do
        local fullPath = folder .. '/' .. fileName

        if string.StartWith(fileName, 'cl_') or string.StartWith(fileName, 'sh') then
            AddCSLuaFile(fullPath)
        end

        if string.StartWith(fileName, 'sv_') or string.StartWith(fileName, 'sh') or string.StartWith(fileName, 'init') then
            include(fullPath)
        end
    end

    for _, subFolder in ipairs(folders) do
        loadFiles(folder .. '/' .. subFolder)
    end
end

local directory = GM.FolderName .. '/gamemode/'
local _, folders = file.Find(directory .. '*', 'LUA')

for _, folderName in SortedPairs(folders) do
    loadFiles(directory .. folderName)
end

util.AddNetworkString('lrp-loadData')
util.AddNetworkString('lrp-sendData')

function GM:PlayerInitialSpawn(ply)
	ply:SetCanWalk(false)
	ply:SetCanZoom(false)
end

local giveammo = {
    {'ammo_air', 150},
    {'ammo_large', 120},
    {'ammo_shot', 40},
    {'ammo_small', 150}
}

function GM:PlayerSpawn(ply)
    if not ply:IsBot() then
        net.Start('lrp-loadData')
        net.Send(ply)
        net.Receive('lrp-sendData', function(len, ply)
            local playerData = net.ReadTable()
            ply:SetJob(playerData.job)
        end)
    else
        ply:SetJob(1)
    end
	ply:SetupHands()

	for _, ammo in pairs(giveammo) do
		ply:GiveAmmo( ammo[2], ammo[1] )
	end

	return true
end