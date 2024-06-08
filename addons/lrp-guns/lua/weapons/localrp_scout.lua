SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
SWEP.PrintName = 'Scout'

SWEP.Passive = 'passive'
SWEP.Sight = 'ar2'

SWEP.ReloadTime = 2.4
SWEP.Primary.Sound = Sound( 'weapons/scout/scout_fire-1.wav' )
SWEP.Primary.Damage = 70
SWEP.Primary.RPM = 60
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 0
SWEP.Primary.KickUp = 10
SWEP.Primary.KickDown = 2.3
SWEP.Primary.KickHorizontal = math.random(2,3)
SWEP.Primary.Ammo = 'ammo_snip'
SWEP.Primary.Automatic = false

SWEP.ClipoutSound = 'weapons/scout/scout_clipout.wav'
SWEP.ClipinSound = 'weapons/scout/scout_clipin.wav'
SWEP.SlideSound = 'weapons/scout/scout_bolt.wav'

SWEP.Icon = 'icons/guns/sniper.png'
SWEP.WorldModel = 'models/weapons/w_snip_scout.mdl'

SWEP.Slot = 3
SWEP.SlotPos = 1

SWEP.AimPos = Vector(-0.5, -0.98, 5.8)
SWEP.AimAng = Angle(-9, 0, 0)
SWEP.SightPos = Vector(1.6, -0.99, 6.17)
SWEP.SightAng = Angle(0, -90, 100)
SWEP.SightSize = 1.2
SWEP.SightFOV = 10
SWEP.SightZNear = 12
SWEP.SightMat = Material('materials/scopes/sniper.png')