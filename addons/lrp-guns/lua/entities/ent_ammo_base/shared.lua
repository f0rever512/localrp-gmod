ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "LocalRP Ammo"
ENT.Author 				= "forever512"
ENT.Information 		= ""

ENT.Spawnable 			= false
ENT.AdminSpawnable		= false
ENT.Category			= "LocalRP - Ammo"

AddCSLuaFile()

ENT.AmmoType 			= ""
ENT.AmmoAmount 			= 0
ENT.AmmoModel			= ""

function ENT:Initialize()
	if SERVER then
		self:SetModel(self.AmmoModel)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetTrigger( true )

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetBuoyancyRatio(0)
		end
	end
end

function ENT:Use(activator)
	if (activator:IsPlayer()) and not self.Planted then
		activator:GiveAmmo(self.AmmoAmount,self.AmmoType)
		self:EmitSound("items/ammopickup.wav")
		self.Entity:Remove()
	end
end

function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end

if CLIENT then
	surface.CreateFont('AmmoFont', {
		font = 'Calibri',
		size = 43,
		weight = 300,
		antialias = true,
		extended = true
	})

	function ENT:Draw()
		self.Entity:DrawModel()

		if self.AmmoModel == "models/Items/BoxSRounds.mdl" then
			TargetPos = self.Entity:GetPos() + (self.Entity:GetUp() * 11.6)
		elseif self.AmmoModel == "models/Items/BoxMRounds.mdl" then
			TargetPos = self.Entity:GetPos() + (self.Entity:GetUp() * 13.5)
		elseif self.AmmoModel == "models/Items/BoxBuckshot.mdl" then
			TargetPos = self.Entity:GetPos() + (self.Entity:GetUp() * 6) + (self.Entity:GetRight() * -0.4) + (self.Entity:GetForward() * 1.1)
		end

		local FixAngles = self.Entity:GetAngles()
		local FixRotation = Vector(90, 90, 90)
		
		FixAngles:RotateAroundAxis(FixAngles:Right(), FixRotation.x)
		FixAngles:RotateAroundAxis(FixAngles:Up(), FixRotation.y)
		FixAngles:RotateAroundAxis(FixAngles:Forward(), FixRotation.z)
		
		cam.Start3D2D(TargetPos, FixAngles, .07)
			if self.AmmoModel == "models/Items/BoxBuckshot.mdl" then
				draw.RoundedBox(15, -60, -25, 120, 50, Color( 0, 100, 80, 220))
			else
				draw.RoundedBox(15, -125, -25, 250, 50, Color( 0, 100, 80, 220))
			end
			draw.SimpleText(self.PrintName, "AmmoFont", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end