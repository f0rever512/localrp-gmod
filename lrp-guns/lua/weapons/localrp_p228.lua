SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
SWEP.PrintName = 'P228'

SWEP.Passive = 'normal'
SWEP.Sight = 'revolver'

SWEP.ReloadTime = 2.4

SWEP.Primary.Sound = Sound( 'weapons/p228/p228-1.wav' )
SWEP.Primary.Damage = 30
SWEP.Primary.RPM = 600
SWEP.Primary.ClipSize = 13
SWEP.Primary.DefaultClip = 0
SWEP.Primary.KickUp = math.random(2,3)
SWEP.Primary.KickDown = 2
SWEP.Primary.KickHorizontal = math.random(2,3)
SWEP.Primary.Ammo = 'ammo_small'
SWEP.Primary.Automatic = false

SWEP.SlideSound = 'weapons/p228/p228_sliderelease.wav'

SWEP.WorldModel = 'models/weapons/w_pist_p228.mdl'

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.AimPos = Vector(-10.5, -1.165, 4.1)
SWEP.AimAng = Angle(-2, 5, 0)