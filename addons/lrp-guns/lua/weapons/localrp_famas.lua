SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
SWEP.PrintName = 'FAMAS'

SWEP.Passive = 'passive'
SWEP.Sight = 'ar2'

SWEP.ReloadTime = 2.2

SWEP.Primary.Sound = Sound( 'weapons/famas/famas-1.wav' )
SWEP.Primary.Damage = 23
SWEP.Primary.RPM = 950
SWEP.Primary.ClipSize = 25
SWEP.Primary.DefaultClip = 0
SWEP.Primary.KickUp = math.random(2,3)
SWEP.Primary.KickDown = 2.3
SWEP.Primary.KickHorizontal = 2
SWEP.Primary.Ammo = 'ammo_large'

SWEP.ClipoutSound = 'weapons/famas/famas_clipout.wav'
SWEP.ClipinSound = 'weapons/famas/famas_clipin.wav'
SWEP.SlideSound = 'weapons/famas/famas_forearm.wav'

SWEP.WorldModel = 'models/weapons/w_rif_famas.mdl'

SWEP.Slot			= 3
SWEP.SlotPos			= 1

SWEP.MuzzlePos = Vector(20, -1, 7.4)
SWEP.MuzzleAng = Angle(-8, 0, 0)
SWEP.AimPos = Vector(-6, -0.91, 7.6)
SWEP.AimAng = Angle(-8, 0, 0)