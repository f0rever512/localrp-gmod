SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
if CLIENT then

	SWEP.PrintName = language.GetPhrase('lrp_guns.weapons.air_revolver')

end
SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.WorldModel = 'models/weapons/w_357.mdl'

SWEP.Primary.Sound = Sound( 'weapons/p228/p228_slideback.wav' )
SWEP.Primary.Damage = 4
SWEP.Primary.RPM = 300
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Ammo = 'ammo_air'
SWEP.Primary.Automatic	= false

SWEP.Passive = 'normal'
SWEP.Sight = 'revolver'

SWEP.HandRecoil = 1
SWEP.VerticalRecoil = 4
SWEP.HorizontalRecoil = 0.5

SWEP.Silent = true
SWEP.ReloadTime = 2.4

SWEP.MuzzlePos = Vector(10, -1, 5.3)
SWEP.MuzzleAng = Angle(-3.5, -0.6, 5)
SWEP.AimPos = Vector(-10.5, -0.745, 4.75)
