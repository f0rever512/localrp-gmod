SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair = false
SWEP.PrintName = 'Пневмат. пистолет'

SWEP.Passive = 'normal'
SWEP.Sight = 'revolver'

SWEP.ReloadTime = 2.45
SWEP.Primary.Sound = Sound( 'weapons/glock/glock_slideback.wav' )
SWEP.Primary.Damage = 2.5
SWEP.Primary.RPM = 750
SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 0
SWEP.Primary.KickUp = 1
SWEP.Primary.KickDown = 1
SWEP.Primary.KickHorizontal = 0
SWEP.Primary.Ammo = 'ammo_air'
SWEP.Primary.Automatic	= false

SWEP.ClipoutSound = ''
SWEP.ClipinSound = ''
SWEP.SlideSound = ''

SWEP.Icon = 'icons/guns/air.png'
SWEP.WorldModel = 'models/weapons/w_pistol.mdl'

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.AimPos = Vector(-10.5, 0, 3.95)
SWEP.AimAng = Angle(-4, 1.85, -5)

function SWEP:FireAnimationEvent( pos, ang, event, options )
	if ( event == 21 ) then return true end	
	if ( event == 5003 ) then return true end
end