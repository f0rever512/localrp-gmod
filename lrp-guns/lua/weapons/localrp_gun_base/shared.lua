if SERVER then
	AddCSLuaFile('leans.lua')
end
include('leans.lua')

SWEP.PrintName = 'LocalRP Gun'
SWEP.WorldModel = ''

SWEP.Author = 'Octothorp Team | forever512'
SWEP.Instructions = 'ПКМ + ЛКМ - Выстрелить\nСКМ - Сменить прицеливание\nALT - Проверить магазин\nЙ / У - Наклониться'

SWEP.Base = 'weapon_base'
SWEP.Passive = 'passive'
SWEP.Sight = 'ar2'
SWEP.Primary.Sound = Sound('')
SWEP.Primary.Damage = 100
SWEP.Primary.Spread = 0.01
SWEP.Primary.NumShots = 1
SWEP.Primary.RPM = 0

SWEP.Primary.KickUp = 0
SWEP.Primary.KickDown = 0
SWEP.Primary.KickHorizontal = 0

SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = 'none'

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = 'none'

SWEP.LRPGuns = true
SWEP.Silent = false
SWEP.ShootAnimOff = false
SWEP.ReloadTime = 1

SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.Spawnable = false

local barrelAngles = {
    _default = {Vector(10, .65, 3.5), Angle(-2, 5, 0)},
   	revolver = {Vector(8, .65, 4), Angle(-2, 5, 0)},
    pistol = {Vector(10, .25, 3.5), Angle(-2, 5, 0)},
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
    timer.Remove("clipinsound" .. self:GetOwner():SteamID())
    timer.Remove("slidesound" .. self:GetOwner():SteamID())
    timer.Remove("reload_act2" .. self:GetOwner():SteamID())
    self:Deploy()
end

function SWEP:Holster()
    timer.Remove("clipinsound" .. self:GetOwner():SteamID())
    timer.Remove("slidesound" .. self:GetOwner():SteamID())
    timer.Remove("reload_act2" .. self:GetOwner():SteamID())
    self:SetReady(false)
    self:SetReloading(false)
    self:GetOwner():SetNW2Int("TFALean", 0)
    self.aimProgress = 0
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

        self:EmitSound(self.Primary.Sound)
        self:ShotBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Spread)
        self:TakePrimaryAmmo(1)
    end
end

function SWEP:SecondaryAttack() return end

if SERVER then
    util.AddNetworkString('custommuzzle')
else
    net.Receive('custommuzzle', function()
        local weap = net.ReadEntity()
        if not IsValid(weap) then return end

        local dlight = DynamicLight( weap:EntIndex() )
        if dlight then
            dlight.pos = weap:GetShootPos()
            dlight.r = 255
            dlight.g = 145
            dlight.b = 10
            dlight.brightness = 1
            dlight.Decay = 5000
            dlight.Size = 256
            dlight.DieTime = CurTime() + 0.2
        end
    end)
end

function SWEP:MuzzleFlashCustom()
	if self.Silent then return end
	if SERVER then
		net.Start('custommuzzle')
			net.WriteEntity(self)
		net.SendPVS(self:GetShootPos())

		return
	end

	local effectData = EffectData()
	effectData:SetEntity(self)
	effectData:SetFlags(1)

	util.Effect('MuzzleFlash', effectData)
end

function SWEP:FireAnimationEvent( pos, ang, event, options )
	if event == 21 then return true end	
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
	if not self.ShootAnimOff then
    	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	end
	self:MuzzleFlashCustom()
    
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

hook.Add('SetupMove', 'lrp-guns.setupmove', function(ply, mv)
    local w = ply:GetActiveWeapon()

    if IsValid(ply) and IsValid(w) and ply:Alive() then
        if w.LRPGuns and not w:GetReady() and w:GetReloading() then
            mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() / 1.2)
        end
    end
end)

hook.Add('CreateMove', 'lrp-guns.createmove', function(cmd)
    local ply = LocalPlayer()
    local w = ply:GetActiveWeapon()

    if IsValid(ply) and IsValid(w) and ply:Alive() then
        if w.LRPGuns and w:GetReady() and not w:GetReloading() then
            cmd:RemoveKey(IN_SPEED)
            cmd:RemoveKey(IN_JUMP)
            cmd:RemoveKey(IN_USE)
        else
            return
        end
    end
end)

-- if CLIENT then
--     hook.Add('WepTrace', 'wepTrace', function()

--         local wep = LocalPlayer():GetActiveWeapon()
--         if not IsValid(wep) then return end
    
--         local pos, dir = wep:GetShootPos()
--         return util.TraceLine({
--             start = pos,
--             endpos = pos + dir * 2000,
--             filter = function(ent)
--                 return ent ~= ply and ent:GetRenderMode() ~= RENDERMODE_TRANSALPHA
--             end
--         })
    
--     end)
    
--     function SWEP:DrawWorldModel()
--         self:DrawModel()
    
--         local pos, dir = self:GetShootPos()
--         render.DrawLine(pos, pos + dir * 200, color_white, true)
--         render.DrawWireframeSphere(pos, 1, 5, 5, color_white, true)
--     end
-- end