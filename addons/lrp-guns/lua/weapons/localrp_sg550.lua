SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
SWEP.PrintName = 'SG550'

SWEP.Passive = 'passive'
SWEP.Sight = 'ar2'

SWEP.ReloadTime = 2.2

SWEP.Primary.Sound = Sound( 'weapons/sg550/sg550-1.wav' )
SWEP.Primary.Damage	= 22
SWEP.Primary.RPM = 450
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 0
SWEP.Primary.KickUp = math.random(3,4)
SWEP.Primary.KickDown = 1.3
SWEP.Primary.KickHorizontal = math.random(2,3)
SWEP.Primary.Ammo = 'ammo_snip'

SWEP.ClipoutSound = 'weapons/sg550/sg550_clipout.wav'
SWEP.ClipinSound = 'weapons/sg550/sg550_clipin.wav'
SWEP.SlideSound = 'weapons/sg550/sg550_boltpull.wav'

SWEP.WorldModel = 'models/weapons/w_snip_sg550.mdl'

SWEP.Slot = 3
SWEP.SlotPos = 1

SWEP.AimPos = Vector(-3.5, -0.8, 5.2)
SWEP.AimAng = Angle(-9, 0, 0)
SWEP.SightPos = Vector(-1.5, -0.79, 5.41)
SWEP.SightAng = Angle(0, -90, 100)
SWEP.SightSize = 1.2
SWEP.SightFOV = 12
SWEP.SightMat = Material('materials/scopes/sniper.png')