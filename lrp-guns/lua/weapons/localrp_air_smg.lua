SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
if CLIENT then
    SWEP.PrintName = 'Пневмат. ПП'
end

SWEP.Passive = 'passive'
SWEP.Sight = 'smg'

SWEP.Silent = true
SWEP.ReloadTime = 2.3

SWEP.Primary.Sound = Sound( 'weapons/p228/p228_sliderelease.wav' )
SWEP.Primary.Damage = 1.25
SWEP.Primary.RPM = 725
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 0
SWEP.Primary.KickUp = 2
SWEP.Primary.KickDown = 1.5
SWEP.Primary.KickHorizontal = 0
SWEP.Primary.Spread = 0.05
SWEP.Primary.Ammo = 'ammo_air'
SWEP.Primary.Automatic	= true

SWEP.ClipoutSound = ''
SWEP.ClipinSound = ''
SWEP.SlideSound = ''

SWEP.WorldModel = 'models/weapons/w_smg1.mdl'

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.AimPos = Vector(-7.5, -0.15, 5.9)
SWEP.AimAng = Angle(-10, 0, -3)