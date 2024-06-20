if SERVER then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.PrintName = language.GetPhrase('lrp_melee.Shovel')
	SWEP.Category		= "LocalRP - Melee"
	SWEP.DrawAmmo                  = false
end

SWEP.Base = 'lrp_melee_base'

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.HoldType = "melee2"

SWEP.ViewModel		= "models/weapons/HL2meleepack/v_shovel.mdl"	 
SWEP.WorldModel		= "models/weapons/HL2meleepack/w_shovel.mdl"
SWEP.ViewModelFOV = 70
SWEP.UseHands				= true

SWEP.DrawCrosshair              = true

SWEP.Weight				= 1 
		 
SWEP.Primary.Damage	= 40
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