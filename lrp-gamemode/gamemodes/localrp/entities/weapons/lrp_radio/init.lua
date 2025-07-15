include('shared.lua')
AddCSLuaFile('shared.lua')

util.AddNetworkString('lrp-radio.toggleSound')

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 1)
end

net.Receive('lrp-radio.toggleSound', function(_, ply)
	local radioActive = net.ReadBool()

	local sound = radioActive and 'npc/combine_soldier/vo/on2.wav' or 'npc/combine_soldier/vo/on1.wav'

	ply:EmitSound(sound, 55)
end)