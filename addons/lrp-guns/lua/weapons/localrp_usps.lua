SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
SWEP.PrintName = 'USP-S'

SWEP.Passive = 'normal'
SWEP.Sight = 'revolver'

SWEP.ReloadTime = 2.4
SWEP.Primary.Sound = Sound( 'weapons/usp/usp1.wav' )
SWEP.Primary.Damage = 27
SWEP.Primary.RPM = 700
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 0
SWEP.Primary.KickUp = 2
SWEP.Primary.KickDown = 2
SWEP.Primary.KickHorizontal = 2
SWEP.Primary.Ammo = 'ammo_pist'
SWEP.Primary.Automatic = false

SWEP.ClipoutSound = ''
SWEP.ClipinSound = ''
SWEP.SlideSound = 'weapons/usp/usp_slideback2.wav'

SWEP.Icon = 'icons/guns/pistol.png'
SWEP.WorldModel = 'models/weapons/w_pist_usp_silencer.mdl'

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.AimPos = Vector(-10.5, -1.1, 4.05)
SWEP.AimAng = Angle(-2, 5, 0)

function SWEP:FireAnimationEvent( pos, ang, event, options )
	if ( event == 21 ) then return true end	
	if ( event == 5003 ) then return true end
end