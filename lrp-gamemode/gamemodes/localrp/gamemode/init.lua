AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

if not processedFiles then
    processedFiles = {}
end

local function processFiles(folder, isServer) -- by nsfw (https://steamcommunity.com/id/NsfwS)
    local files, folders = file.Find(folder .. "/*", "LUA")
    local filesToAddCS, filesToInclude = {}, {}

    for _, f in ipairs(files) do
        local fullPath = folder .. "/" .. f

        if not processedFiles[fullPath] then
            processedFiles[fullPath] = true

            if string.StartWith(f, "cl_") or string.StartWith(f, 'sh') then
                table.insert(filesToAddCS, fullPath)
                -- MsgC(Color(255, 221, 102), ('Loaded on client: ' .. fullPath .. '\n'))
            end

            if isServer and (string.StartWith(f, "sv_") or string.StartWith(f, 'sh') or string.StartWith(f, 'init')) then
				-- Msg('Loaded on server: ' .. fullPath .. '\n')
            end
        end

        if isServer and (string.StartWith(f, "sv_") or string.StartWith(f, 'sh') or string.StartWith(f, 'init')) then
            table.insert(filesToInclude, fullPath)
        end
    end

    for _, f in ipairs(folders) do
        processFiles(folder .. "/" .. f, isServer)
    end

    for _, fullPath in ipairs(filesToAddCS) do
        AddCSLuaFile(fullPath)
    end

    for _, fullPath in ipairs(filesToInclude) do
        include(fullPath)
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
	processFiles('localrp/gamemode/' .. name, SERVER)
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