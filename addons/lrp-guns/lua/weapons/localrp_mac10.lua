SWEP.Base = 'localrp_gun_base'
SWEP.Category = 'LocalRP - Guns'
SWEP.Spawnable = true
SWEP.DrawCrosshair		= false
SWEP.PrintName = 'Mac-10'

SWEP.Passive = 'normal'
SWEP.Sight = 'pistol'

SWEP.ReloadTime = 1.9
SWEP.Primary.Sound = Sound( 'weapons/mac10/mac10-1.wav' )
SWEP.Primary.Damage = 21
SWEP.Primary.RPM = 950
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 0
SWEP.Primary.KickUp = 6
SWEP.Primary.KickDown = 3
SWEP.Primary.KickHorizontal = 2
SWEP.Primary.Ammo = 'ammo_smg'

SWEP.ClipoutSound = 'weapons/mac10/mac10_clipout.wav'
SWEP.ClipinSound = 'weapons/mac10/mac10_clipin.wav'
SWEP.SlideSound = 'weapons/mac10/mac10_boltpull.wav'

SWEP.Icon = 'icons/guns/smg.png'
SWEP.WorldModel = 'models/weapons/w_smg_mac10.mdl'

SWEP.Slot = 2
SWEP.SlotPos = 1

SWEP.AimPos = Vector(-12, -1.622, 5.4)
SWEP.AimAng = Angle(-2, 5, 0)

function SWEP:ShotBullet(dmg, numbul, cone)
    if not IsValid(self:GetOwner()) then return end

    numbul = numbul or 1
    cone = cone or 0.01

    local bullet = {}
    local pos, dir = self:GetShootPos()
    bullet.Num = numbul or 1
    bullet.Src = pos -- self:GetOwner():GetShootPos()
    bullet.Dir = dir -- self.Owner:GetEyeTraceNoCursor().Normal --self.Owner:GetAimVector()
    bullet.Spread = Vector(cone, cone, 0)
    bullet.Tracer = 4
    bullet.Force = 5
    bullet.Damage = dmg

    self:GetOwner():FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():MuzzleFlash()
    --self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    
    local anglo1 = Angle(math.Rand(-self.Primary.KickDown, -self.Primary.KickUp), math.Rand(-self.Primary.KickHorizontal, self.Primary.KickHorizontal), 0)
    self.Owner:ViewPunch(anglo1)

    if SERVER and game.SinglePlayer() and not self.Owner:IsNPC() then
        local offlineeyes = self.Owner:EyeAngles()
        offlineeyes.pitch = offlineeyes.pitch + anglo1.pitch
        offlineeyes.yaw = offlineeyes.yaw + anglo1.yaw
        self.Owner:SetEyeAngles(offlineeyes)
    end

    if CLIENT and not game.SinglePlayer() and not self.Owner:IsNPC() then
        local anglo = Angle(math.Rand(-self.Primary.KickDown, -self.Primary.KickUp), math.Rand(-self.Primary.KickHorizontal, self.Primary.KickHorizontal), 0)
        local eyes = self.Owner:EyeAngles()
        eyes.pitch = eyes.pitch + (anglo.pitch / 3)
        eyes.yaw = eyes.yaw + (anglo.yaw / 3)
        self.Owner:SetEyeAngles(eyes)
    end
end