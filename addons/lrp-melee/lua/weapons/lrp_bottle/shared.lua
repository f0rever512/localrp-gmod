if SERVER then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.PrintName = language.GetPhrase('lrp_melee.Bottle')
	SWEP.Category		= "LocalRP - Melee"
	SWEP.DrawAmmo = false
end

SWEP.Base = 'lrp_melee_base'

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