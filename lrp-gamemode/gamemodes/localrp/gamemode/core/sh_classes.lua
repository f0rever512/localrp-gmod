local ply = FindMetaTable("Player")

local teams = {}

teams[0] = {
	name = "Гражданин",
	color = Vector(1, 1, 1),
	model = ("models/humans/modern/male_0" .. math.random(1, 9) .. "_01.mdl"),
	weapons = {
		'localrp_hands',
		'weapon_physgun',
		'gmod_tool',
		'gmod_camera',
		'lrp_medkit',
		'localrp_flashlight'
	}
}

teams[1] = {
	name = "Бездомный",
	color = Vector(0.3, 0.1, 0.1), --Color(90, 35, 25)
	model = "models/player/Group01/male_01.mdl",
	weapons = {
		'localrp_hands',
		'weapon_physgun',
		'gmod_tool',
		'gmod_camera',
		'lrp_medkit'
	}
}

teams[2] = {
	name = 'Офицер полиции',
	color = Vector(0, 0, 1),
	model = ("models/player/policeofficer/male_0" .. math.random(1, 9) .. ".mdl"),
	weapons = {
		'localrp_hands',
		'weapon_physgun',
		'gmod_tool',
		'gmod_camera',
		'lrp_medkit',
		'localrp_flashlight',
		"localrp_glock18",
		"localrp_taser",
		"localrp_cuff_police",
		"lrp_battering_ram",
		"localrp_nightstick"
	},
	ar = 15
}

teams[3] = {
	name = "Детектив",
	color = Vector(0, 0, 1),
	model = ("models/kerry/detective/male_0" .. math.random(1, 9) .. ".mdl"),
	weapons = {
		'localrp_hands',
		'weapon_physgun',
		'gmod_tool',
		'gmod_camera',
		'lrp_medkit',
		'localrp_flashlight',
		"localrp_fiveseven",
		"localrp_air_revolver",
		"localrp_taser",
		"localrp_cuff_police",
		"localrp_nightstick"
	},
	ar = 10
}

teams[4] = {
	name = 'Оперативник спецназа',
	color = Vector(1, 1, 1),
	model = "models/player/plattsburg_swat/swat.mdl",
	weapons = {
		'localrp_hands',
		'weapon_physgun',
		'gmod_tool',
		'gmod_camera',
		'lrp_medkit',
		'localrp_flashlight',
		"localrp_m4a1s",
		"localrp_usps",
		"localrp_taser",
		"lrp_shield",
		"lrp_battering_ram",
		"localrp_cuff_police",
		"localrp_nightstick"
	},
	ar = 50
}

if SERVER then
	util.AddNetworkString( 'skin' )

	net.Receive( 'skin', function(ply)
		local wep = ply:GetActiveWeapon()
    
        if IsValid(ply) and IsValid(wep) then
            ply:DropWeapon()
        end
	end )
else
	concommand.Add( 'lrp_skin', function(ply)
        local wep = ply:GetActiveWeapon()

        if not table.HasValue(blacklist, wep:GetClass()) then
            net.Start( 'skin' )
            net.SendToServer()
        else
            notification.AddLegacy('Это оружие нельзя выбросить', NOTIFY_GENERIC, 3 )
            surface.PlaySound( "buttons/lightswitch2.wav" )
        end
	end )
end

function ply:SetupTeam(n)
	if (not teams[n]) then return end
	local walk = 80
	local run = 180

	local randskin = math.random(0, 23)
	
	self:SetTeam(n)
	self:SetHealth(100)
	self:SetArmor(teams[n].ar or 0)
	self:SetMaxHealth(100)
	self:SetWalkSpeed(walk)
	self:SetRunSpeed(run)
	self:SetLadderClimbSpeed(140)
	self:SetModel(teams[n].model)
	self:SetSkin(randskin)
	self:SetPlayerColor(teams[n].color)

	for k, weapon in pairs(teams[n].weapons) do
		self:Give(weapon)
	end
end