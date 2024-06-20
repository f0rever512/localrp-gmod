SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
SWEP.PrintName = 'P90'

SWEP.Passive = 'passive'
SWEP.Sight = 'smg'

SWEP.ReloadTime = 2.2

SWEP.Primary.Sound = Sound( 'weapons/p90/p90-1.wav' )
SWEP.Primary.Damage = 19
SWEP.Primary.RPM	= 1000
SWEP.Primary.ClipSize	= 50
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.KickUp = math.random(1,3)
SWEP.Primary.KickDown = 4
SWEP.Primary.KickHorizontal = 2
SWEP.Primary.Spread = 0.05
SWEP.Primary.Ammo = 'ammo_small'

SWEP.ClipoutSound = 'weapons/p90/p90_clipout.wav'
SWEP.ClipinSound = 'weapons/p90/p90_clipin.wav'
SWEP.SlideSound = 'weapons/p90/p90_boltpull.wav'

SWEP.WorldModel = 'models/weapons/w_smg_p90.mdl'

SWEP.Slot = 2
SWEP.SlotPos = 1

SWEP.MuzzlePos = Vector(15, -0.25, 6)
SWEP.MuzzleAng = Angle(-9.5, 2.3, 0)
SWEP.AimPos = Vector(-5, -1, 8.5)
SWEP.AimAng = Angle(-9, 2.2, 0)