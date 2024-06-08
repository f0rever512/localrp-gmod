if SERVER then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.PrintName	                = "Сломанная бутылка"
	SWEP.Category		= "LocalRP - Melee"
	SWEP.DrawAmmo                  = false
end

SWEP.Base				= "localrp_melee_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.HoldType = "knife"

SWEP.ViewModel		= "models/weapons/HL2meleepack/v_brokenbottle.mdl"
SWEP.WorldModel		= "models/weapons/HL2meleepack/w_brokenbottle.mdl"
SWEP.ViewModelFOV = 65
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

SWEP.MissSound 	= Sound( "WeaponFrag.Roll" )
SWEP.WallSound 	= Sound( "GlassBottle.ImpactHard" )
SWEP.PlayerSound = Sound( "Flesh_Bloody.ImpactHard" )