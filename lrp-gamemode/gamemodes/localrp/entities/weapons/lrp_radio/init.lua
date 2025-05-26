include('shared.lua')
AddCSLuaFile('shared.lua')

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 1)
end