AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local processedFiles = {}

local function processFiles(folder, isServer)
    local files, folders = file.Find(folder .. "/*", "LUA")

    local function shouldAddCS(f)
        return string.StartWith(f, "cl_") or string.StartWith(f, "sh")
    end

    local function shouldInclude(f)
        return string.StartWith(f, "sv_") or string.StartWith(f, "sh") or string.StartWith(f, "init")
    end

    for _, f in ipairs(files) do
        local fullPath = folder .. "/" .. f

        if not processedFiles[fullPath] then
            processedFiles[fullPath] = true

            if shouldAddCS(f) then
                AddCSLuaFile(fullPath)
            end

            if isServer and shouldInclude(f) then
                include(fullPath)
            end
        end
    end

    for _, f in ipairs(folders) do
        processFiles(folder .. "/" .. f, isServer)
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

for _, name in ipairs(folders) do
    processFiles('localrp/gamemode/' .. name, SERVER)
end

util.AddNetworkString('lrp-loadData')
util.AddNetworkString('lrp-sendData')

function GM:PlayerInitialSpawn(ply)
    ply:SetCanWalk(false)
    ply:SetCanZoom(false)
end

local giveAmmo = {
    {'ammo_air', 150},
    {'ammo_large', 120},
    {'ammo_shot', 40},
    {'ammo_small', 150}
}

function GM:PlayerSpawn(ply)
    net.Start('lrp-loadData')
    net.Send(ply)

    net.Receive('lrp-sendData', function(len, ply)
        local playerData = net.ReadTable()
        ply:SetJob(playerData.job)
    end)

    ply:SetupHands()

    for _, ammo in ipairs(giveAmmo) do
        ply:GiveAmmo(ammo[2], ammo[1])
    end

    return true
end
