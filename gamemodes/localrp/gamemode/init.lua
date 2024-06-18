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

processFiles('localrp/gamemode/core', SERVER)
processFiles('localrp/gamemode/damage', SERVER)
processFiles("localrp/gamemode/other", SERVER)
processFiles('localrp/gamemode/vgui', SERVER)
processFiles("localrp/gamemode/voicechat", SERVER)

function GM:Initialize()
	MsgN('LocalRP Gamemode initialized on server')
end

function GM:PlayerInitialSpawn(ply)
	ply:SetCanWalk(false)
	ply:SetCanZoom(false)
	--ply:ConCommand( "lrp_greet" )
end

function GM:PlayerSpawn(ply)
	ply:SetupTeam(GetConVar('lrp_class'):GetInt())

	local giveammo = {
		{'ammo_air', 150},
		{'ammo_air', 150},
		{'ammo_pist', 150},
		{'ammo_smg', 100},
		{'ammo_assault', 120},
		{'ammo_snip', 60},
		{'ammo_shot', 40}
	}

	for _, ammo in pairs(giveammo) do
		ply:GiveAmmo( ammo[2], ammo[1] )
	end

	male = {
		'models/humans/modern/male_01_01.mdl',
		'models/humans/modern/male_02_01.mdl',
		'models/humans/modern/male_03_01.mdl',
		'models/humans/modern/male_04_01.mdl',
		'models/humans/modern/male_05_01.mdl',
		'models/humans/modern/male_06_01.mdl',
		'models/humans/modern/male_07_01.mdl',
		'models/humans/modern/male_08_01.mdl',
		'models/humans/modern/male_09_01.mdl'
	}

	female = {
		'models/humans/modern/female_01.mdl',
		'models/humans/modern/female_02.mdl',
		'models/humans/modern/female_03.mdl',
		'models/humans/modern/female_04.mdl',
		'models/humans/modern/female_06.mdl',
		'models/humans/modern/female_07.mdl'
	}

	hook.Add( "PlayerDeathSound", 'lrp-deathsound', function(ply)
		if table.HasValue(male, ply:GetModel()) then
			ply:EmitSound('vo/coast/odessa/male01/nlo_cubdeath0' .. math.random(1, 2) .. '.wav', SNDLVL_NORM)
		elseif table.HasValue(female, ply:GetModel()) then
			ply:EmitSound('vo/coast/odessa/female01/nlo_cubdeath0' .. math.random(1, 2) .. '.wav', SNDLVL_NORM)
		end
		return true
	end )

	ply:SetupHands()

	return true
end