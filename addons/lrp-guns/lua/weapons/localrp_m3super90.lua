SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
SWEP.PrintName = 'M3 Super 90'

SWEP.Passive = 'passive'
SWEP.Sight = 'ar2'

SWEP.Primary.Sound = Sound( 'weapons/m3/m3-1.wav' )
SWEP.Primary.Damage = 10
SWEP.Primary.RPM = 100
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 0
SWEP.Primary.NumShots = 8
SWEP.Primary.KickUp = 10
SWEP.Primary.KickDown = 7.8
SWEP.ReloadTime = 2.3
SWEP.Primary.KickHorizontal = math.random(15,19)
SWEP.Primary.Spread = 0.1
SWEP.Primary.Ammo = 'ammo_shot'
SWEP.Primary.Automatic = false

SWEP.ClipoutSound = ''
SWEP.ClipinSound = 'weapons/m3/m3_insertshell.wav'
SWEP.SlideSound = 'weapons/m3/m3_pump.wav'

SWEP.Icon = 'icons/guns/shotgun.png'
SWEP.WorldModel = 'models/weapons/w_shot_m3super90.mdl'

SWEP.Slot = 2
SWEP.SlotPos = 1

SWEP.AimPos = Vector(-5, -0.9, 4.6)
SWEP.AimAng = Angle(-9, 0, 0)