SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
if CLIENT then

	SWEP.PrintName = language.GetPhrase('lrp_guns.weapons.air_shotgun')

end
SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.WorldModel = 'models/weapons/w_shotgun.mdl'

SWEP.Primary.Sound = Sound( 'weapons/scout/scout_clipout.wav' )
SWEP.Primary.Damage = 0.5
SWEP.Primary.RPM = 200
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 0
SWEP.Primary.NumShots = 7
SWEP.Primary.Spread = 0.1
SWEP.Primary.Ammo = 'ammo_air'
SWEP.Primary.Automatic	= true

SWEP.Passive = 'passive'
SWEP.Sight = 'ar2'

SWEP.HandRecoil = 1.5
SWEP.VerticalRecoil = 4
SWEP.HorizontalRecoil = 0.5

SWEP.Silent = true
SWEP.ReloadTime = 2.4

SWEP.MuzzlePos = Vector(25.5, -0.7, 7.5)
SWEP.MuzzleAng = Angle(-6.8, -0.65, -3)
SWEP.AimPos = Vector(-5.3, -0.25, 6.1)
