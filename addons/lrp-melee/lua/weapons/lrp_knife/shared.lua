if SERVER then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.PrintName = language.GetPhrase('lrp_melee.Knife')
	SWEP.Category = "LocalRP - Melee"
	SWEP.DrawAmmo                  = false
end

SWEP.Base = 'lrp_melee_base'

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