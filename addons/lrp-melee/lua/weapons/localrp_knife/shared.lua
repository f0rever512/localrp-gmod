if SERVER then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.PrintName = "Нож"
	SWEP.Category = "LocalRP - Melee"
	SWEP.DrawAmmo                  = false
end

SWEP.Base				= "localrp_melee_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.HoldType = "knife"

SWEP.ViewModel		= "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel		= "models/weapons/w_knife_t.mdl"
SWEP.ViewModelFOV = 60
SWEP.UseHands				= true

SWEP.DrawCrosshair              = true

SWEP.Weight				= 1 
		 
SWEP.Primary.Damage			= 20
SWEP.Primary.ClipSize		= -1		
SWEP.Primary.Delay			= 0.5
SWEP.Primary.DefaultClip	= 1		 
SWEP.Primary.Automatic		= true		 
SWEP.Primary.Ammo			= "none"	 

SWEP.Secondary.ClipSize		= -1			
SWEP.Secondary.DefaultClip	= -1 
SWEP.Secondary.Automatic		= false		 
SWEP.Secondary.Ammo			= "none"

SWEP.Decal = true

SWEP.Dist = 60

SWEP.ViewPunch = Angle( 0, 2, -2 )

SWEP.MissSound = Sound( "Weapon_Knife.Slash" )
SWEP.WallSound = Sound( "Weapon_Knife.HitWall" )
SWEP.PlayerSound = Sound( "Weapon_Knife.Hit" )

function SWEP:PrimaryAttack()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "midslash1" ) )

	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 50 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if ( trace.Hit ) then

		if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
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
	else
		self.Weapon:EmitSound(self.MissSound,100,math.random(90,120))
		--self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
	end
	
	timer.Simple( 0.05, function()
		self.Owner:ViewPunch( self.ViewPunch )
	end )
end