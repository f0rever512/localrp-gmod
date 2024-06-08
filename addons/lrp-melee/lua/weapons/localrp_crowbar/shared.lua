if SERVER then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.PrintName	                = "Монтировка"
	SWEP.Category		= "LocalRP - Melee"
	SWEP.DrawAmmo                  = false
end

SWEP.Base				= "localrp_melee_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.HoldType = "melee"

SWEP.ViewModel		= "models/weapons/v_crowbar.mdl" 
SWEP.WorldModel		= "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFOV = 55
SWEP.UseHands	= true

SWEP.DrawCrosshair = true

SWEP.Weight				= 1 
		 
SWEP.Primary.Damage = 40
SWEP.Primary.ClipSize		= -1		
SWEP.Primary.Delay			= 1.5
SWEP.Primary.DefaultClip	= 1		 
SWEP.Primary.Automatic		= true		 
SWEP.Primary.Ammo			= "none"	 

SWEP.Secondary.ClipSize		= -1			
SWEP.Secondary.DefaultClip	= -1 
SWEP.Secondary.Automatic		= false		 
SWEP.Secondary.Ammo			= "none"

SWEP.Decal = false

SWEP.Dist = 70

SWEP.ViewPunch = Angle( 0, 5, -1 )

SWEP.MissSound 	= Sound( "WeaponFrag.Roll" )
SWEP.WallSound 	= Sound( "Canister.ImpactHard" )
SWEP.PlayerSound = Sound( "Flesh.ImpactHard" )