if SERVER then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.PrintName = "Бутылка"
	SWEP.Category		= "LocalRP - Melee"
	SWEP.DrawAmmo = false
end

SWEP.Base				= "localrp_melee_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.HoldType = "melee"

SWEP.ViewModel		= "models/weapons/HL2meleepack/v_bottle.mdl"
SWEP.WorldModel		= "models/weapons/HL2meleepack/w_bottle.mdl"
SWEP.ViewModelFOV = 65
SWEP.UseHands = true

SWEP.DrawCrosshair = true

SWEP.Weight				= 1 
		 
SWEP.Primary.Damage			= 15
SWEP.Primary.ClipSize		= -1		
SWEP.Primary.Delay			= 1	  
SWEP.Primary.DefaultClip	= 1		 
SWEP.Primary.Automatic		= true		 
SWEP.Primary.Ammo			= "none"	 

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.Delay = 1
SWEP.Secondary.DefaultClip	= -1 
SWEP.Secondary.Automatic		= false		 
SWEP.Secondary.Ammo			= "none"

SWEP.Decal = false

SWEP.Dist = 70

SWEP.ViewPunch = Angle( 0, 5, -1 )

SWEP.MissSound 	= Sound( "WeaponFrag.Roll" )
SWEP.WallSound 	= Sound( "GlassBottle.Break" )
SWEP.PlayerSound = Sound( "GlassBottle.Break" )

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
    local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "draw" ) )
end

function SWEP:PrimaryAttack()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "misscenter1" ) )

	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 50 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	timer.Simple( 0.05, function()
		if IsValid(self.Owner:GetActiveWeapon()) then
			self.Owner:ViewPunch( self.ViewPunch )
		end
	end )

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
		if (SERVER) then
			self.Owner:Give("localrp_brokenbottle")
			self.Owner:SelectWeapon("localrp_brokenbottle")
			self.Owner:StripWeapon("localrp_bottle")
		end
	else
		self.Weapon:EmitSound(self.MissSound,100,math.random(90,120))
		--self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
	end
end

function SWEP:SecondaryAttack()

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self:EmitSound( self.MissSound )

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "misscenter1" ) )

	timer.Create("throwdelay", 0.2, 1, function() self:Throwbottle() end)

	timer.Start( "throwdelay" )
	
end

function SWEP:OnDrop() end

function SWEP:Throwbottle()
	if SERVER then
		local ent = ents.Create( "prop_physics" )

		if ( !IsValid( ent ) ) then return end
		
		ent:SetModel( "models/props_junk/GlassBottle01a.mdl" )
		ent:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 20 ) )
		ent:SetAngles( self.Owner:EyeAngles() - Angle( 0, 50, 190 ) )
		ent:Spawn()

		local phys = ent:GetPhysicsObject();
	
		//local shot_length = tr.HitPos:Length();
		phys:ApplyForceCenter (self.Owner:GetAimVector()*2000 )
		phys:AddAngleVelocity(Vector( -250, -250, 0 ))
	
		self.Owner:StripWeapon("localrp_bottle")
	end
end

function SWEP:Reload() return false end

function SWEP:OnRemove()
	timer.Remove("throwdelay")
	return true
end

function SWEP:Holster() return true end