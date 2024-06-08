SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
SWEP.PrintName = 'Пневмат. револьвер'

SWEP.Passive = 'normal'
SWEP.Sight = 'revolver'

SWEP.ReloadTime = 2.5
SWEP.Primary.Sound = Sound( 'weapons/p228/p228_slideback.wav' )
SWEP.Primary.Damage = 3.5
SWEP.Primary.RPM = 300
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 0
SWEP.Primary.KickUp = 2.5
SWEP.Primary.KickDown = 1.25
SWEP.Primary.KickHorizontal = 0
SWEP.Primary.Ammo = 'ammo_air'
SWEP.Primary.Automatic	= false

SWEP.ClipoutSound = ''
SWEP.ClipinSound = ''
SWEP.SlideSound = ''

SWEP.Icon = 'icons/guns/air.png'
SWEP.WorldModel = 'models/weapons/w_357.mdl'

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.AimPos = Vector(-10.5, -0.75, 4.75)
SWEP.AimAng = Angle(-3.75, -0.5, 5)

function SWEP:FireAnimationEvent( pos, ang, event, options )
	if ( event == 21 ) then return true end	
	if ( event == 5003 ) then return true end
end