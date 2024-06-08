SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
SWEP.PrintName = 'XM1014'

SWEP.Passive = 'passive'
SWEP.Sight = 'ar2'

SWEP.Primary.Sound = Sound( 'weapons/xm1014/xm1014-1.wav' )
SWEP.Primary.Damage = 6.5
SWEP.Primary.RPM = 200
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 0
SWEP.Primary.NumShots = 8
SWEP.Primary.KickUp = 6 
SWEP.Primary.KickDown = 7
SWEP.ReloadTime = 2.3
SWEP.Primary.KickHorizontal = math.random(10,15)
SWEP.Primary.Spread = 0.09
SWEP.Primary.Ammo = 'ammo_shot'
SWEP.Primary.Automatic = true

SWEP.ClipoutSound = ''
SWEP.ClipinSound = 'weapons/xm1014/xm1014_insertshell.wav'
SWEP.SlideSound = ''

SWEP.Icon = 'icons/guns/shotgun.png'
SWEP.WorldModel = 'models/weapons/w_shot_xm1014.mdl'

SWEP.Slot = 2
SWEP.SlotPos = 1

SWEP.AimPos = Vector(-5, -0.78, 4.25)
SWEP.AimAng = Angle(-9, 0, 0)