AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()

	self:SetModel(self.AmmoModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetBuoyancyRatio(0)
	end

end

local useDist = 84 * 84

function ENT:Use(ply)

	if not IsValid(ply) or not ply:IsPlayer() then return end

	local tr = ply:GetEyeTrace()
	if tr.Entity ~= self or tr.HitPos:DistToSqr(ply:EyePos()) > useDist then return end

	ply:GiveAmmo(self.AmmoAmount, self.AmmoType)

	local filter = RecipientFilter()
    for _, pl in pairs(player.GetAll()) do
        if pl ~= ply then
            filter:AddPlayer(pl)
        end
    end

	local soundName = math.random(1, 2) == 1 and 'items/ammopickup.wav' or 'items/ammo_pickup.wav'
	ply:EmitSound(soundName, 55, 100, 1, CHAN_AUTO, 0, 1, filter)
	self:Remove()

end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
end
