SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
SWEP.PrintName = 'Elite'

SWEP.Passive = 'normal'
SWEP.Sight = 'revolver'

SWEP.ReloadTime = 2.4
SWEP.Primary.Sound = Sound( 'weapons/elite/elite-1.wav' )
SWEP.Primary.Damage = 27
SWEP.Primary.RPM = 500
SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 0
SWEP.Primary.KickUp = math.random(2,4)
SWEP.Primary.KickDown = 2.3
SWEP.Primary.KickHorizontal = math.random(1,2)
SWEP.Primary.Spread = 0.01
SWEP.Primary.Ammo = 'ammo_small'
SWEP.Primary.Automatic = false

SWEP.SlideSound = 'weapons/elite/elite_sliderelease.wav'


SWEP.WorldModel = 'models/weapons/w_pist_elite_single.mdl'

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.AimPos = Vector(-13, -1.55, 4.6)
SWEP.AimAng = Angle(-2, 5, 0)
SWEP.hRight = 0.09
SWEP.hUp = 0.04