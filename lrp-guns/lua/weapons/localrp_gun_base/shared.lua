SWEP.Spawnable = false
SWEP.Base = 'weapon_base'
SWEP.Primary.Sound = Sound('')
SWEP.Primary.Damage = 100
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
SWEP.ShootAnimOff = false
SWEP.ReloadTime = 1

local barrelAngles = {
    _default = {Vector(10, .65, 3.5), Angle(-2, 5, 0)},
   	revolver = {Vector(8, .45, 4), Angle(-2, 5, 0)},
    pistol = {Vector(10, .25, 3.5), Angle(-2.1, 4.9, 0)},
    ar2 = {Vector(25, -1, 7.5), Angle(-9, 0, 0)},
    smg = {Vector(11, -0.9, 7.5), Angle(-8, 1.5, 0)},
    duel = {Vector(9, 1, 3.5), Angle(0, 11, 0)}
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
    ply:SetNW2Int("TFALean", 0)

	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"), Vector(0, 0, 0), true)
    ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"), Angle(0, 0, 0), true)
    ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Finger1"), Angle(0, 0, 0), true)
	ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(0, 0, 0), true)
    return true
end

function SWEP:CanFire()
    if CurTime() < self:GetNextPrimaryFire() or self.Owner:WaterLevel() == 3 then
        self:EmitSound('weapons/clipempty_rifle.wav')
        self:SetNextPrimaryFire(CurTime() + 2)
        return false
    end
    local t = self.Owner
    local e = {}
    e.start = t:GetShootPos()
    e.endpos = self:GetShootPos()
    e.filter = t
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
        local pos, dir = LocalToWorld(mPos, mAng, att.Pos, att.Ang)
        --local pos, dir = LocalToWorld(mPos, mAng, att.Pos, ply:EyeAngles())
        return pos, dir:Forward()
    else
        return ply:GetShootPos(), (ply.viewAngs or ply:EyeAngles()):Forward()
    end
end

function SWEP:Reload() return end

function SWEP:GunReloading()
    if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():Alive() then
        if self:Ammo1() == 0 and self:GetOwner():KeyPressed(IN_RELOAD) then return end

        if self:Clip1() < self.Primary.ClipSize and self:GetOwner():KeyPressed(IN_RELOAD) and not self:GetReloading() then
            self:GetOwner():SetAmmo(self:Ammo1() + self:Clip1(), self.Primary.Ammo)
            self:SetClip1(0)
            self:SetReady(false)
            self:EmitSound(self.ClipoutSound or '', 60, 100)

            timer.Create('reload_act' .. self:GetOwner():SteamID(), 0.1, 1, function()
                if not IsValid(self) then return end
				timer.Create("clipinsound" .. self:GetOwner():SteamID(), self.ReloadTime - 1.25, 1, function()
					self:EmitSound(self.ClipinSound or '', 60, 100)
				end)
				timer.Create("slidesound" .. self:GetOwner():SteamID(), self.ReloadTime - 0.75, 1, function()
					self:EmitSound(self.SlideSound or '', 60, 100)
				end )

				self:SetReady(false)
				self:SetReloading(true)
				self:SetHoldType(self.Sight)
				self:GetOwner():SetAnimation(PLAYER_RELOAD)

				timer.Create('reload_act2' .. self:GetOwner():SteamID(), self.ReloadTime, 1, function()
					if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():Alive() then
                        self:SetClip1((self:Ammo1() < self.Primary.ClipSize) and self:Ammo1() or self.Primary.ClipSize)
						self:GetOwner():SetAmmo(self:Ammo1() - self.Primary.ClipSize, self.Primary.Ammo)

						if self:GetOwner():KeyDown(IN_ATTACK2) then
							self:SetReady(true)
							self:SetReloading(false)
						end

						if not self:GetOwner():KeyDown(IN_ATTACK2) then
							self:SetReady(false)
							self:SetReloading(false)
						end
					end
				end)
            end)
        end
    end
end

function SWEP:Think()
    if self:GetNW2Float("lrp-handRecoil") ~= 0 then
        self:Recoil()
    end

	if self:GetOwner():KeyReleased( IN_ATTACK2 ) or self:GetReloading() then
		self:GetOwner():SetNW2Int("TFALean", 0)
	end

    if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():Alive() then
        self:GunReloading()

        if self:GetReloading() then return end

		self:SetHoldType(self:GetReady() and self.Sight or self.Passive)

        if not self:GetReady() and self:GetOwner():KeyDown(IN_ATTACK2) then
            self:SetReady(true)
        end

        if self:GetReady() and self:GetOwner():KeyReleased(IN_ATTACK2) then
            self:SetReady(false)
        end
    end
end

function SWEP:PrimaryAttack()
    if self:GetReloading() then return end
    if not self:GetReady() and self:CanPrimaryAttack() or not self:CanFire() then return end

    if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():Alive() then
        self:SetNextPrimaryFire(CurTime() + 1.5 / (self.Primary.RPM / 70))

        if self:Clip1() <= 0 then
            self:EmitSound('weapons/clipempty_rifle.wav')
            self:SetNextPrimaryFire(CurTime() + 2)

            return
        end

        self:MuzzleFlashCustom()
        self:EmitSound(self.Primary.Sound, 80)
        self:ShotBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Spread)
        self:TakePrimaryAmmo(1)

        verticalRecoil = math.random(self.VerticalRecoil, self.VerticalRecoil + 2)
        horizontalRecoil = math.random(-self.HorizontalRecoil, self.HorizontalRecoil)
        self:SetNW2Float("lrp-handRecoil", self:GetNW2Float("lrp-handRecoil") + self.HandRecoil)

        local recoilAngle = Angle(-verticalRecoil / 5, -horizontalRecoil / 2, 0)
        self.Owner:ViewPunch(recoilAngle)

        local eyes = self.Owner:EyeAngles()
        eyes.pitch = eyes.pitch + (recoilAngle.pitch / 3)
        eyes.yaw = eyes.yaw + (recoilAngle.yaw / 3)
        self.Owner:SetEyeAngles(eyes)
    end
end

function SWEP:SecondaryAttack() return end

function SWEP:MuzzleFlashCustom()
	if self.Silent or (self.SightPos and handview) then return end

	local effectData = EffectData()
	effectData:SetEntity(self)
    effectData:SetAttachment(1)
	effectData:SetFlags(1)
    -- if SERVER then
    --     effectData:SetEntIndex('muzzle' .. self:GetOwner():SteamID())
    -- end
	util.Effect('MuzzleFlash', effectData)
end

verticalRecoil = verticalRecoil or 0
horizontalRecoil = horizontalRecoil or 0
function SWEP:Recoil()
	self.animProg = self:GetNW2Float("lrp-handRecoil") or 0
	self.animLerp = self.animLerp or Angle(0, 0, 0)
	self.animLerp = LerpAngle(0.25, self.animLerp, Angle(verticalRecoil, horizontalRecoil, self.Sight == 'revolver' and 0 or -2) * self.animProg)
	local ply = self:GetOwner()
	if self:GetNW2Float("lrp-handRecoil") > 0 then
		if self.Sight ~= "revolver" and self.Sight ~= 'pistol' then
			ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"), Vector(0, -self.animLerp.x / 3, -self.animLerp.x / 3), false)
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"), Angle(0, 0, -self.animLerp.x), false)
		end
        ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Finger1"), LerpAngle(1, self.animLerp, Angle(0, -20, self.Sight == "revolver" and 10 or -2) * math.min(self.animProg, 0.5)), false)
		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), self.animLerp * 2, false)

		self:SetNW2Float("lrp-handRecoil", Lerp(FrameTime() * 8, self:GetNW2Float("lrp-handRecoil") or 0, 0))

        if self:GetNW2Float("lrp-handRecoil") <= 0.01 then
            self:SetNW2Float("lrp-handRecoil", 0)
        end
	end
end

function SWEP:FireAnimationEvent( pos, ang, event, options )
    -- Disables animation based muzzle event
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
    --self:GetOwner():MuzzleFlash()
	-- if not self.ShootAnimOff then
    -- 	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	-- end
end

hook.Add('SetupMove', 'lrp-guns.setupmove', function(ply, mv)
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.Base == 'localrp_gun_base' and wep:GetReloading() then
        mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() / 1.2)
    end
end)