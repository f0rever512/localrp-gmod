util.AddNetworkString('lrp.menu-clGetModel')
util.AddNetworkString('lrp.menu-svGetModel')
util.AddNetworkString('lrp.menu-clGetSkin')
util.AddNetworkString('lrp.menu-svGetSkin')
util.AddNetworkString('lrp-sendData2')

local jobs = {
	[1] = {
		name = "Гражданин",
		color = Color(255, 255, 255),
		model = "models/humans/modern/male_0%s_01.mdl",
		weapons = {
			'localrp_hands',
			'weapon_physgun',
			'gmod_tool',
			'gmod_camera',
			'lrp_medkit',
			'localrp_flashlight'
		}
	},
	[2] = {
		name = "Бездомный",
		color = Color(125, 65, 55),
		model = "models/player/Group01/male_0%s.mdl",
		weapons = {
			'localrp_hands',
			'weapon_physgun',
			'gmod_tool',
			'gmod_camera',
			'lrp_medkit',
			'lrp_bottle'
		}
	},
	[3] = {
		name = 'Офицер полиции',
		color = Color(80, 80, 220),
		model = "models/player/policeofficer/male_0%s.mdl",
		weapons = {
			'localrp_hands',
			'weapon_physgun',
			'gmod_tool',
			'gmod_camera',
			'lrp_medkit',
			'localrp_flashlight',
			"localrp_glock18",
			'lrp_stungun',
			"localrp_cuff_police",
			"lrp_battering_ram",
			"lrp_nightstick"
		},
		ar = 15
	},
	[4] = {
		name = "Детектив",
		color = Color(80, 80, 220),
		model = "models/kerry/detective/male_0%s.mdl",
		weapons = {
			'localrp_hands',
			'weapon_physgun',
			'gmod_tool',
			'gmod_camera',
			'lrp_medkit',
			'localrp_flashlight',
			"localrp_fiveseven",
			"localrp_air_revolver",
			'lrp_stungun',
			"localrp_cuff_police",
			"lrp_nightstick"
		},
		ar = 10
	},
	[5] = {
		name = 'Оперативник спецназа',
		color = Color(80, 80, 220),
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
			'lrp_stungun',
			"lrp_shield",
			"lrp_battering_ram",
			"localrp_cuff_police",
			"localrp_nightstick"
		},
		ar = 50
	},
	[6] = {
		name = 'Медик',
		color = Color(225, 120, 120),
		model = "models/player/Group03m/male_0%s.mdl",
		weapons = {
			'localrp_hands',
			'weapon_physgun',
			'gmod_tool',
			'gmod_camera',
			'lrp_medkit',
			'localrp_flashlight'
		}
	},
}
local walk = 80
local run = 180

local ply = FindMetaTable("Player")
function ply:SetJob(jobID)
	if not jobs[jobID] then return end

	self:SetTeam(jobID)
	self:SetHealth(100)
	self:SetArmor(jobs[jobID].ar or 0)
	self:SetMaxHealth(100)
	self:SetWalkSpeed(walk)
	self:SetRunSpeed(run)
	self:SetLadderClimbSpeed(140)
	net.Receive('lrp-sendData2', function(len, ply)
        local playerData = net.ReadTable()
        
        self:SetModel(string.format(jobs[jobID].model, playerData.model))
       	self:SetSkin(playerData.skin)
    end)
	self:SetPlayerColor(Vector(jobs[jobID].color.r / 255, jobs[jobID].color.g / 255, jobs[jobID].color.b / 255))

	for _, weapon in pairs(jobs[jobID].weapons) do
		self:Give(weapon)
	end
end

net.Receive('lrp.menu-clGetModel', function(len, ply)
	local modelNum = net.ReadInt(5)
	local jobID = net.ReadInt(4)
	
	net.Start('lrp.menu-svGetModel')
	net.WriteString(string.format(jobs[jobID].model, modelNum))
	net.Send(ply)
end)

net.Receive('lrp.menu-clGetSkin', function(len, ply)
	local modelNum = net.ReadInt(5)
	local jobID = net.ReadInt(4)
	
	net.Start('lrp.menu-svGetSkin')
	net.WriteString(string.format(jobs[jobID].model, modelNum))
	net.Send(ply)
end)