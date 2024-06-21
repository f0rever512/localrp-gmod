SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
SWEP.PrintName = 'G3SG1'

SWEP.Passive = 'passive'
SWEP.Sight = 'ar2'

SWEP.ReloadTime = 2.2
SWEP.Primary.Sound = Sound( 'weapons/g3sg1/g3sg1-1.wav' )
SWEP.Primary.Damage	= 22
SWEP.Primary.RPM = 450
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 0
SWEP.Primary.KickUp = math.random(3,4)
SWEP.Primary.KickDown = 1.3
SWEP.Primary.KickHorizontal = math.random(2,3)
SWEP.Primary.Spread = 0.001
SWEP.Primary.Ammo = 'ammo_large'

SWEP.ClipoutSound = 'weapons/g3sg1/g3sg1_clipout.wav'
SWEP.ClipinSound = 'weapons/g3sg1/g3sg1_clipin.wav'
SWEP.SlideSound = 'weapons/g3sg1/g3sg1_slide.wav'


SWEP.WorldModel = 'models/weapons/w_snip_g3sg1.mdl'

SWEP.Slot = 3
SWEP.SlotPos = 1

SWEP.AimPos = Vector(-6.25, -0.95, 6.5)
SWEP.AimAng = Angle(-9, 0, 0)
SWEP.SightPos = Vector(-4.2, -0.95, 6.86)
SWEP.SightAng = Angle(0, -90, 100)
SWEP.SightSize = 1.2
SWEP.SightFOV = 15
SWEP.SightMat = Material('materials/scopes/sniper.png')