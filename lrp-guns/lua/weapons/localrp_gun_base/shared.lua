SWEP.Spawnable = false
SWEP.Base = 'weapon_base'
SWEP.Primary.Sound = Sound('')
SWEP.Primary.Damage = 25
SWEP.Primary.Spread = 0.01
SWEP.Primary.NumShots = 1
SWEP.Primary.RPM = 0

SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = 'none'

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = 'none'

SWEP.Passive = 'passive'
SWEP.Sight = 'ar2'

SWEP.HandRecoil = 0.5
SWEP.VerticalRecoil = 4
SWEP.HorizontalRecoil = 0.5

SWEP.LRPGuns = true
SWEP.Silent = false
SWEP.ReloadTime = 2.2

SWEP.ClipoutSound = ''
SWEP.ClipinSound = ''
SWEP.SlideSound = ''

local barrelAngles = {
    _default = {Vector(10, .65, 3.5), Angle(-2, 5, 0)},
   	revolver = {Vector(8, .45, 4), Angle(-2, 5, 0)},
    pistol = {Vector(10, .25, 3.5), Angle(-2.1, 4.9, 0)},
    ar2 = {Vector(25, -1, 7.5), Angle(-9, 0, 0)},
    smg = {Vector(11, -0.9, 7.5), Angle(-8, 1.5, 0)},
    duel = {Vector(9, 1.1, 3.5), Angle(1.5, 11.8, 0)}
}

function SWEP:SetupDataTables()
    self:NetworkVar('Bool', 0, 'Ready')
    self:NetworkVar('Bool', 1, 'Reloading')
end

function SWEP:Initialize()
    self:SetReady(false)
    self:SetReloading(false)
    self.aimProgress = 0
end

function SWEP:Deploy()
    self:SetReady(false)
    self:SetReloading(false)
    return true
end

function SWEP:OnDrop()
	self:Deploy()
end

function SWEP:OnRemove()
    if self:GetReloading() then
        timer.Remove("clipinsound" .. self:GetOwner():SteamID())
        timer.Remove("slidesound" .. self:GetOwner():SteamID())
        timer.Remove("reload_act2" .. self:GetOwner():SteamID())
    end
    self:Deploy()
end

function SWEP:Holster()
    local ply = self:GetOwner()

    timer.Remove("clipinsound" .. ply:SteamID())
    timer.Remove("slidesound" .. ply:SteamID())
    timer.Remove("reload_act2" .. ply:SteamID())
    self:SetReady(false)
    self:SetReloading(false)
    self.aimProgress = 0
    self.visualRecoil = 0
    ply:SetNW2Int("TFALean", 0)
	ply:ManipulateBoneAngles(ply:LookupBone('ValveBiped.Bip01_R_Hand'), Angle(0, 0, 0))
    return true
end

function SWEP:CanFire()
    local ply = self:GetOwner()
    if CurTime() < self:GetNextPrimaryFire() or ply:WaterLevel() == 3 then
        self:EmitSound('Weapon_AR2.Empty')
        self:SetNextPrimaryFire(CurTime() + 2)
        return false
    end

    local e = {}
    e.start = ply:GetShootPos()
    e.endpos = self:GetShootPos()
    e.filter = ply
    return not util.TraceLine(e).Hit
end

function SWEP:GetShootPos()
    local ply = self:GetOwner()
	local att = ply:GetAttachment(ply:LookupAttachment('anim_attachment_rh'))
    if att then
        local mPos, mAng = self.MuzzlePos, self.MuzzleAng
        if not mPos then
            if barrelAngles[self.Sight] then
                mPos, mAng = unpack(barrelAngles[self.Sight])
            else
                mPos, mAng = unpack(barrelAngles._default)
            end
        end

        local pos, ang = LocalToWorld(mPos, mAng, att.Pos, att.Ang)
        return pos, ang:Forward()
    else
        return ply:GetShootPos(), ply:EyeAngles():Forward()
    end
end

function SWEP:GetShootAng()
    local mPos, mAng = self.MuzzlePos, self.MuzzleAng
    if not mPos then
        if barrelAngles[self.Sight] then
            pos, mAng = unpack(barrelAngles[self.Sight])
        else
            pos, mAng = unpack(barrelAngles._default)
        end
    end
	return mAng
end

function SWEP:GunReloading()
    local ply = self:GetOwner()
    if self:Ammo1() == 0 and ply:KeyPressed(IN_RELOAD) then return end

    if self:Clip1() < self.Primary.ClipSize and ply:KeyPressed(IN_RELOAD) and not self:GetReloading() then
        ply:SetAmmo(self:Ammo1() + self:Clip1(), self.Primary.Ammo)
        self:SetClip1(0)
        self:SetReady(false)
        self:EmitSound(self.ClipoutSound, 60, 100)

        timer.Create('reload_act' .. ply:SteamID(), 0.1, 1, function()
            if not IsValid(self) then return end
            timer.Create("clipinsound" .. ply:SteamID(), self.ReloadTime - 1.25, 1, function()
                self:EmitSound(self.ClipinSound, 60, 100)
            end)
            timer.Create("slidesound" .. ply:SteamID(), self.ReloadTime - 0.75, 1, function()
                self:EmitSound(self.SlideSound, 60, 100)
            end )

            self:SetReady(false)
            self:SetReloading(true)
            self:SetHoldType(self.Sight)
            ply:SetAnimation(PLAYER_RELOAD)

            timer.Create('reload_act2' .. ply:SteamID(), self.ReloadTime, 1, function()
                if IsValid(self) and IsValid(ply) and ply:Alive() then
                    self:SetClip1((self:Ammo1() < self.Primary.ClipSize) and self:Ammo1() or self.Primary.ClipSize)
                    ply:SetAmmo(self:Ammo1() - self.Primary.ClipSize, self.Primary.Ammo)
                    self:SetReloading(false)
                end
            end)
        end)
    end
end

function SWEP:Think()
    if self:GetNW2Float("lrp-handRecoil") ~= 0 then
        self:Recoil()
    end
    self.visualRecoil = Lerp(FrameTime() * 10, self.visualRecoil or 0, 0)

    local ply = self:GetOwner()
	if ply:KeyReleased( IN_ATTACK2 ) or self:GetReloading() then
		ply:SetNW2Int("TFALean", 0)
	end

    if IsValid(self) and IsValid(ply) and ply:Alive() then
        self:GunReloading()

        if self:GetReloading() then return end

		self:SetHoldType(self:GetReady() and self.Sight or self.Passive)

        if not self:GetReady() and ply:KeyDown(IN_ATTACK2) then
            self:SetReady(true)
        end

        if self:GetReady() and ply:KeyReleased(IN_ATTACK2) then
            self:SetReady(false)
        end
    end
end

function SWEP:PrimaryAttack()
    if self:GetReloading() then return end
    if not self:GetReady() and self:CanPrimaryAttack() or not self:CanFire() then return end

    local ply = self:GetOwner()
    if IsValid(self) and IsValid(ply) and ply:Alive() then
        self:SetNextPrimaryFire(CurTime() + 1.5 / (self.Primary.RPM / 70))

        if self:Clip1() <= 0 then
            self:EmitSound('Weapon_AR2.Empty')
            self:SetNextPrimaryFire(CurTime() + 2)
            return
        end

        self:MuzzleFlashCustom()
        self:EmitSound(self.Primary.Sound, self.Silent and 75 or 80)
        self:ShotBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Spread)
        self:TakePrimaryAmmo(1)
        self.visualRecoil = (self.visualRecoil or 0) + self.HandRecoil / (self.Sight == 'revolver' and 1 or 5)

        local recoilCoef = ply:IsListenServerHost() and 1.5 or 5
        local recoilAngle = Angle(math.Rand(-self.VerticalRecoil, -self.VerticalRecoil + 2) / 3, math.Rand(-self.HorizontalRecoil, self.HorizontalRecoil) * 4, 0)
        if CLIENT then
            local ang = ply:EyeAngles()
            ang.p = ang.p + (recoilAngle.p / recoilCoef)
            ang.y = ang.y + (recoilAngle.y / recoilCoef)
            ply:SetEyeAngles(ang)
        else
        	ply:ViewPunch(recoilAngle)
        end
        
        self:Recoil()
    end
end

function SWEP:SecondaryAttack() return end
function SWEP:Reload() end

function SWEP:MuzzleFlashCustom()
	if self.Silent or (self.SightPos and handview) then return end

	local effectData = EffectData()
	effectData:SetEntity(self)
	effectData:SetFlags(1)
	util.Effect('MuzzleFlash', effectData)
end

function SWEP:Recoil()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if timer.Exists('smoothRecoil_' .. ply:SteamID()) then return end

    local bone = ply:LookupBone('ValveBiped.Bip01_R_Hand')
    if not bone then return end

    local handRecoilAngle = Angle(self.HandRecoil * 6, 0, 0)
    local steps = 4
    local interval = 0.01
    local incAngle = Angle(
        handRecoilAngle.p / steps,
        handRecoilAngle.y / steps,
        handRecoilAngle.r / steps
    )

    timer.Remove('smoothRecoil_' .. ply:SteamID())

    local currentStep = 0
    timer.Create('smoothRecoil_' .. ply:SteamID(), interval, steps, function()
        if not IsValid(ply) then return end
        currentStep = currentStep + 1
        local curAngle = ply:GetManipulateBoneAngles(bone) or Angle(0, 0, 0)
        ply:ManipulateBoneAngles(bone, curAngle + incAngle)
        -- after last step start recoil restore
        if currentStep == steps then
            self:StartRecoilRestore(ply, bone)
        end
    end)
end

function SWEP:StartRecoilRestore(ply, bone)
    timer.Remove('recoilRestore_' .. ply:SteamID())

    local recoilRestoreSpeed = 5
    timer.Create('recoilRestore_' .. ply:SteamID(), 0.01, 0, function()
        if not IsValid(ply) then return end
        local curAngle = ply:GetManipulateBoneAngles(bone) or Angle(0, 0, 0)
        
        local stepP = recoilRestoreSpeed * math.abs(curAngle.p) * 0.01
        local stepY = recoilRestoreSpeed * math.abs(curAngle.y) * 0.01
        local stepR = recoilRestoreSpeed * math.abs(curAngle.r) * 0.01

        curAngle.p = math.Approach(curAngle.p, 0, stepP)
        curAngle.y = math.Approach(curAngle.y, 0, stepY)
        curAngle.r = math.Approach(curAngle.r, 0, stepR)
        
        ply:ManipulateBoneAngles(bone, curAngle)

        if curAngle.p == 0 and curAngle.y == 0 and curAngle.r == 0 then
            timer.Remove('recoilRestore_' .. ply:SteamID())
        end
    end)
end

function SWEP:FireAnimationEvent( pos, ang, event, options )
    -- Disable animation based muzzle event
	if event == 21 then return true end
    -- Disable thirdperson muzzle flash
	if event == 5003 then return true end
end

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
    -- self:GetOwner():SetAnimation(PLAYER_ATTACK1)
end

hook.Add('SetupMove', 'lrp-guns.setupmove', function(ply, mv)
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.Base == 'localrp_gun_base' and wep:GetReloading() then
        mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() / 1.2)
    end
end)