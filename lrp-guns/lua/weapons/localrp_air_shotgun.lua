SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
if CLIENT then
    SWEP.PrintName = 'Пневмат. дробовик'
end

SWEP.Passive = 'passive'
SWEP.Sight = 'ar2'

SWEP.Silent = true
SWEP.ReloadTime = 2.45

SWEP.Primary.Sound = Sound( 'weapons/scout/scout_clipout.wav' )
SWEP.Primary.Damage = 0.4
SWEP.Primary.RPM = 200
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 0
SWEP.Primary.NumShots = 7
SWEP.Primary.KickUp = 3
SWEP.Primary.KickDown = 1
SWEP.Primary.KickHorizontal = 0
SWEP.Primary.Spread = 0.1
SWEP.Primary.Ammo = 'ammo_air'
SWEP.Primary.Automatic	= true

SWEP.WorldModel = 'models/weapons/w_shotgun.mdl'

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.MuzzlePos = Vector(25, -0.9, 7.5)
SWEP.MuzzleAng = Angle(-6, -1.2, 0)
SWEP.AimPos = Vector(-5.3, -0.1, 6.4)
SWEP.AimAng = Angle(-5.6, -1.3, -3)