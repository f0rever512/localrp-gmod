if (SERVER) then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.PrintName = "LocalRP Melee"
	SWEP.Author	= "forever512"
	SWEP.Category = "LocalRP - Melee"
	SWEP.Slot = 0
	SWEP.SlotPos = 2
	SWEP.DrawAmmo = false
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.HoldType = "melee2"

SWEP.ViewModel		= "models/weapons/HL2meleepack/v_axe.mdl"	 
SWEP.WorldModel		= "models/weapons/HL2meleepack/w_axe.mdl"
SWEP.ViewModelFOV = 68
SWEP.UseHands				= true

SWEP.DrawCrosshair = true

SWEP.Weight	= 1
		 
SWEP.Primary.Damage			= 10			  
SWEP.Primary.ClipSize		= -1		
SWEP.Primary.Delay			= 1
SWEP.Primary.DefaultClip	= 1		 
SWEP.Primary.Automatic		= true		 
SWEP.Primary.Ammo			= "none"	 

SWEP.Secondary.ClipSize		= -1			
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic		= false		 
SWEP.Secondary.Ammo			= "none"

SWEP.Dist = 50

SWEP.MissSound 	= Sound( "WeaponFrag.Roll" )
SWEP.WallSound 	= Sound( "Canister.ImpactHard" )
SWEP.PlayerSound = Sound("npc/ministrider/flechette_flesh_impact1.wav")

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
    local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "draw" ) )
end

function SWEP:PrimaryAttack()
	local wp = self.Owner:GetActiveWeapon()
	local vm = self.Owner:GetViewModel()
	if wp:GetClass() == 'localrp_knife' then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("midslash1"))
	else
		vm:SendViewModelMatchingSequence(vm:LookupSequence("misscenter1"))
	end

	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * self.Dist )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine(tr)

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:SetHoldType(self.HoldType)

	timer.Simple(0.1, function()
		if IsValid(wp) then
			self.Owner:ViewPunch(self.ViewPunch)
		end
	end)

	if trace.Hit then
		if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(), "npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 1
			bullet.Damage = self.Primary.Damage
			self.Owner:FireBullets(bullet)
			self.Weapon:EmitSound( self.PlayerSound )		
		else
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 1
			bullet.Damage = self.Primary.Damage
			self.Owner:FireBullets(bullet)
			self.Weapon:EmitSound( self.WallSound )	
			if self.Decal == true then
				util.Decal("ManhackCut", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
			end
		end
		if SERVER then
			if IsValid(wp) and wp:GetClass() == 'localrp_bottle' then
				self.Owner:Give("localrp_brokenbottle")
				self.Owner:SelectWeapon("localrp_brokenbottle")
				self.Owner:StripWeapon("localrp_bottle")
			end
		end
	else
		self.Weapon:EmitSound(self.MissSound, 100, math.random(90, 120))
		--self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
	end
end

function SWEP:SecondaryAttack() return false end

function SWEP:Reload() return false end

function SWEP:OnRemove() return true end

function SWEP:Holster() return true end