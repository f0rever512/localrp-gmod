SWEP.PrintName = 'LocalRP Gun'
SWEP.WorldModel = ''

SWEP.Author = 'Octothorp Team | forever512'
SWEP.Instructions = 'ПКМ + ЛКМ - Выстрелить\nСКМ - Сменить прицеливание\nALT - Проверить магазин\nЙ / У - Наклониться'

SWEP.Base = 'weapon_base'
SWEP.Passive = 'passive'
SWEP.Sight = 'ar2'
SWEP.Primary.Sound = Sound('')
SWEP.Primary.Cone = 0.2
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
end

function SWEP:Holster()
    timer.Remove( "clipinsound" .. self:GetOwner():SteamID())
    timer.Remove( "slidesound" .. self:GetOwner():SteamID())
    timer.Remove( "reload_act2" .. self:GetOwner():SteamID())
    self:SetReady(false)
    self:SetReloading(false)

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
            if self:GetClass() == 'localrp_air_pistol' then
                mPos, mAng = Vector(5.5, 0.5, 5),Angle(-3.75, 1.9, 0)
            elseif self:GetClass() == 'localrp_air_revolver' then
                mPos, mAng = Vector(10, -1, 5.3),Angle(-3.75, -0.6, 0)
            elseif self:GetClass() == 'localrp_air_shotgun' then
                mPos, mAng = Vector(25, -0.9, 7.5),Angle(-6, -1.2, 0)
            elseif self:GetClass() == 'localrp_air_smg' then
                mPos, mAng = Vector(14, -0.25, 8),Angle(-10, 0, 0)
            elseif barrelAngles[self.Sight] then
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
    if (IsValid(self) and IsValid(self:GetOwner())) and self:GetOwner():Alive() and IsValid(self:GetOwner():GetActiveWeapon()) then
        if self:Ammo1() == 0 and self:GetOwner():KeyPressed(IN_RELOAD) then return end

        if self:Clip1() < self.Primary.ClipSize and self:GetOwner():KeyPressed(IN_RELOAD) and self:GetReloading() == false then
            self:GetOwner():SetAmmo(self:Ammo1() + self:Clip1(), self.Primary.Ammo)
            self:SetClip1(0)
            self:SetReady(false)
            self:EmitSound(self.ClipoutSound, 60, 100)

            timer.Create('reload_act' .. self:GetOwner():SteamID(), 0.1, 1, function()
                timer.Create("clipinsound" .. self:GetOwner():SteamID(), self.ReloadTime - 1.25, 1, function()
                    self:EmitSound(self.ClipinSound, 60, 100)
                end)
                timer.Create("slidesound" .. self:GetOwner():SteamID(), self.ReloadTime - 0.75, 1, function()
                    self:EmitSound(self.SlideSound, 60, 100)
                end )

                self:SetReady(false)
                self:SetReloading(true)
                self:SetHoldType(self.Sight)
                self:GetOwner():SetAnimation(PLAYER_RELOAD)

                timer.Create('reload_act2' .. self:GetOwner():SteamID(), self.ReloadTime, 1, function()
                    if self:Ammo1() < self.Primary.ClipSize then
                        self:SetClip1(self:Ammo1())
                    else
                        self:SetClip1(self.Primary.ClipSize)
                    end

                    self:GetOwner():SetAmmo(self:Ammo1() - self.Primary.ClipSize, self.Primary.Ammo)

                    if self:GetOwner():KeyDown(IN_ATTACK2) then
                        self:SetReady(true)
                        self:SetReloading(false)
                    end

                    if not self:GetOwner():KeyDown(IN_ATTACK2) then
                        self:SetReady(false)
                        self:SetReloading(false)
                    end
                end)
            end)
        end
    end
end

function SWEP:Think()
    if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():Alive() then
        self:GunReloading()

        if self:GetReloading() then return end

        if self:GetReady() then
            self:SetHoldType(self.Sight)
        else
            self:SetHoldType(self.Passive)
        end

        if not self:GetReady() and self:GetOwner():KeyDown(IN_ATTACK2) then
            self.aimProgress = 0
            self:SetReady(true)
        end

        if self:GetReady() and self:GetOwner():KeyReleased(IN_ATTACK2) then
            self.aimProgress = 0
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

function SWEP:SecondaryAttack()
    return
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
    self:GetOwner():MuzzleFlash()
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    
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

--[[function SWEP:MuzzleFlashCustom()
	if SERVER then
		net.Start('qwb.muzzleFlashLight')
			net.WriteEntity(self)
		net.SendPVS(self:GetBulletSourcePos())

		return
	end

	local effectData = EffectData()
	effectData:SetEntity(self)
	effectData:SetFlags(1)

	util.Effect('MuzzleFlash', effectData)
end
SWEP.ShellType = '9mm'

function SWEP:ShellEffect()
	if SERVER then return end
	if self.NoShell then return end

	local shellType = self.ShellType

	local effectData = EffectData()

	local pos = self:GetPos()
	if self.ShellOffset then
		local att = self:GetAttachment( self:LookupAttachment('muzzle') )
		if att then
			pos = LocalToWorld(self.ShellOffset, angle_zero, att.Pos, att.Ang)
		end
	end

	effectData:SetOrigin(pos)
	effectData:SetFlags(self.ShellVelocity or 75)

	util.Effect('EjectBrass_' .. shellType, effectData)
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
    self:GetOwner():MuzzleFlash()
    self:MuzzleFlashCustom()
	self:ShellEffect()
    self.RecoilAnimBack = nil
	self:GetOwner().RecoilAnim = true
    
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
end]]

hook.Add('SetupMove', 'WeaponSetupMove', function(ply, mv)
    local w = ply:GetActiveWeapon()

    if IsValid(ply) and IsValid(w) and ply:Alive() then
        if w.LRPGuns and not w:GetReady() and w:GetReloading() then
            mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() / 1.2)
        end
    end
end)

hook.Add('CreateMove', 'WeaponCreateMove', function(cmd)
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

local LeanOffset = 0

--[[Shared]]
local function MetaInitLean()
	local PlayerMeta = FindMetaTable("Player")
	PlayerMeta.LeanGetShootPosOld = PlayerMeta.LeanGetShootPosOld or PlayerMeta.GetShootPos
	PlayerMeta.LeanEyePosOld = PlayerMeta.LeanEyePosOld or PlayerMeta.GetShootPos
	PlayerMeta.GetNW2Int = PlayerMeta.GetNW2Int or PlayerMeta.GetNWFloat
	PlayerMeta.SetNW2Int = PlayerMeta.SetNW2Int or PlayerMeta.SetNWFloat

	function PlayerMeta:GetShootPos()
		if not IsValid(self) or not self.LeanGetShootPosOld then return end
		local ply = self
		local status = ply.TFALean or ply:GetNW2Int("TFALean")
		local off = Vector(0, status * -LeanOffset, 0)
		off:Rotate(self:EyeAngles())
		local gud, ret = pcall(self.LeanGetShootPosOld, self)

		if gud then
			return ret + off
		else
			return off
		end
	end

	function PlayerMeta:GetShootPos()
		if not IsValid(self) or not self.LeanGetShootPosOld then return end
		local ply = self
		local status = ply.TFALean or ply:GetNW2Int("TFALean")
		local off = Vector(0, status * -LeanOffset, 0)
		off:Rotate(self:EyeAngles())
		local gud, ret = pcall(self.LeanGetShootPosOld, self)

		if gud then
			return ret + off
		else
			return off
		end
	end

	function PlayerMeta:EyePos()
		if not IsValid(self) then return end
		local gud, pos, ang = pcall(self.GetShootPos, self)

		if gud then
			return pos, ang
		else
			return vector_origin, angle_zero
		end
	end

	hook.Add("ShutDown", "TFALeanPMetaCleanup", function()
		if PlayerMeta.LeanGetShootPosOld then
			PlayerMeta.GetShootPos = PlayerMeta.LeanGetShootPosOld
			PlayerMeta.LeanGetShootPosOld = nil
		end
	end)

	MetaOverLean = true
end

pcall(MetaInitLean)

hook.Add("PlayerSpawn", "TFALeanPlayerSpawn", function(ply)
	ply:SetNW2Int("TFALean", 0)
	ply.TFALean = 0
end)

--[[Lean Calculations]]
local targ
local traceRes, traceResLeft, traceResRight

local traceData = {
	["mask"] = MASK_SOLID,
	["collisiongroup"] = COLLISION_GROUP_DEBRIS,
	["mins"] = Vector(-4, -4, -4),
	["maxs"] = Vector(4, 4, 4)
}

local function AngleOffset(new, old)
	local _, ang = WorldToLocal(vector_origin, new, vector_origin, old)

	return ang
end

local function RollBone(ply, bone, roll)
	ply:ManipulateBoneAngles(bone, angle_zero)

	if CLIENT then
		ply:SetupBones()
	end

	local boneMat = ply:GetBoneMatrix(bone)
	local boneAngle = boneMat:GetAngles()
	local boneAngleOG = boneMat:GetAngles()
	boneAngle:RotateAroundAxis(ply:EyeAngles():Forward(), roll)
	ply:ManipulateBoneAngles(bone, AngleOffset(boneAngle, boneAngleOG))

	if CLIENT then
		ply:SetupBones()
	end
end

function TFALeanModel()
	for k, ply in ipairs(player.GetAll()) do
		ply.TFALean = Lerp(FrameTime() * 5, ply.TFALean or 0, ply:GetNW2Int("TFALean")) --unpredicted lean which gets synched with our predicted lean status
		local lean = ply.TFALean
		local bone = ply:LookupBone("ValveBiped.Bip01_Spine")

		if bone then
			RollBone(ply, bone, lean * 15)
		end

		bone = ply:LookupBone("ValveBiped.Bip01_Spine1")

		if bone then
			RollBone(ply, bone, lean * 15)
		end
	end
end

hook.Add( "PlayerButtonDown", "LeanBtnDown", function( ply, button )
	local wep = ply:GetActiveWeapon()

	if ply:KeyReleased( IN_ATTACK2 ) or not wep.LRPGuns or wep:GetReloading() then
		ply:SetNW2Int("TFALean", 0)
	end

	if (button != KEY_Q and button != KEY_E) then return end

	if wep.LRPGuns and ply:KeyDown(IN_ATTACK2) and ply:KeyDownLast(IN_ATTACK2) and wep:GetReloading() == false then
		targ = (button == KEY_Q and -1 or (button == KEY_E and 1 or 0))

		ply:SetNW2Int("TFALean", targ)
	end
	if SERVER then
		for _, v in ipairs(player.GetAll()) do
			v.TFALean = Lerp(FrameTime() * 10, v.TFALean or 0, v:GetNW2Int("TFALean")) --unpredicted lean which gets synched with our predicted lean status
		end
	end
end)

hook.Add("PlayerButtonUp", "LeanBtnUp", function( ply, button )
	local wep = ply:GetActiveWeapon()
	if !wep.LRPGuns or (button != KEY_Q and button != KEY_E) then return end

	if button == KEY_Q or button == KEY_E then
		ply:SetNW2Int("TFALean", 0)
	end
end)

if SERVER and not game.SinglePlayer() then
	timer.Create("TFALeanSynch", 0.2, 0, function()
		for k, v in ipairs(player.GetAll()) do
			local lean = v:GetNW2Int("TFALean")
			v.OldLean = v.OldLean or lean

			if lean ~= v.OldLean then
				v.OldLean = lean
				local bone = v:LookupBone("ValveBiped.Bip01_Spine")

				if bone then
					RollBone(v, bone, lean * 15)
				end

				bone = v:LookupBone("ValveBiped.Bip01_Spine1")

				if bone then
					RollBone(v, bone, lean * 15)
				end
			end
		end
	end)
end

--[[Projectile Redirection]]
local PlayerPosEntities = {
	["rpg_missile"] = true,
	["crossbow_bolt"] = true,
	["npc_grenade_frag"] = true,
	["apc_missile"] = true,
	["viewmodel_predicted"] = true
}

hook.Add("OnEntityCreated", "TFALeanOnEntCreated", function(ent)
	local ply = ent.Owner or ent:GetOwner()
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if ent:IsPlayer() then return end
	local headposold
	local gud, ret = pcall(ply.LeanGetShootPosOld, ply)

	if gud then
		headposold = ret
	else
		headposold = ply:EyePos()
	end

	local entpos
	entpos = ent:GetPos()

	if PlayerPosEntities[ent:GetClass()] or (math.floor(entpos.x) == math.floor(headposold.x) and math.floor(entpos.y) == math.floor(headposold.y) and math.floor(entpos.z) == math.floor(headposold.z)) then
		ent:SetPos(ply:EyePos())
	end
end)


local ISPATCHING = false
hook.Add("EntityFireBullets", "zzz_LeanFireBullets", function(ply, bul, ...)
	if ISPATCHING then return end
	local bak = table.Copy(bul)
	ISPATCHING = true
	local call = hook.Run("EntityFireBullets", ply, bul, ...)
	ISPATCHING = false
	if call == false then
		return false
	elseif call == nil then
		table.Empty(bul)
		table.CopyFromTo(bak,bul)
	end
	if ply:IsWeapon() and ply.Owner then
		ply = ply.Owner
	end

	if not ply:IsPlayer() then return end
	local wep = ply:GetActiveWeapon()

	if (not wep.Base) and ply.LeanGetShootPosOld and bul.Src == ply:LeanGetShootPosOld() then
		bul.Src = ply:GetShootPos()
	end

	return true
end)

--[[CLIENTSIDE]]
hook.Add("PreRender", "TFALeanPreRender", function()
	TFALeanModel()
end)

local minvec = Vector(-6, -6, -6)
local maxvec = Vector(6, 6, 6)

local function filterfunc(ent)
	if (ent:IsPlayer() or ent:IsNPC() or ent:IsWeapon() or PlayerPosEntities[ent:GetClass()]) then
		return false
	else
		return true
	end
end

local function bestcase(pos, endpos, ply)
	local off = endpos - pos
	local trace = {}
	trace.start = pos
	trace.endpos = pos + off
	trace.mask = MASK_SOLID
	trace.filter = filterfunc
	trace.ignoreworld = false
	trace.maxs = maxvec
	trace.mins = minvec
	local traceres = util.TraceHull(trace)

	return pos + off:GetNormalized() * math.Clamp(traceres.Fraction, 0, 1) * off:Length()
end

function LeanCalcView(ply, pos, angles, fov)
	local view = {}
	view.origin = pos
	view.angles = angles
	view.fov = fov
	if not ply:Alive() or ply:Health() <= 0 then return view end
	local status = ply.TFALean or 0
	local off = Vector(0, status * -LeanOffset, 0)
	off:Rotate(angles)
	view.angles:RotateAroundAxis(view.angles:Forward(), status * 3)
	view.origin = bestcase(view.origin, view.origin + off, ply)

	return view
end

local ISLEANINGCV = false

hook.Add("CalcView", "TFALeanCalcView", function(ply, pos, angles, fov, ...)
	if ISLEANINGCV then return end
	if GetViewEntity() ~= ply then return end
	if not ply:Alive() then return end
	if ply:InVehicle() then return end
	ISLEANINGCV = true
	local preTable = hook.Run("CalcView", ply, pos, angles, fov) or {}
	ISLEANINGCV = false
	preTable.origin = preTable.origin or pos
	preTable.angles = preTable.angles or angles
	preTable.fov = preTable.fov or fov
	--[[
	local wep = ply:GetActiveWeapon()
	if wep.CalcView then
		local p,a,f = wep.CalcView(wep,ply,preTable.origin,preTable.angles,preTable.fov)
		preTable.origin = p or preTable.origin
		preTable.angles = a or preTable.angles
		preTable.fov = f or preTable.fov
	end
	]]
	--
	local finalTable = LeanCalcView(ply, preTable.origin, preTable.angles, preTable.fov, ...)
	for k, v in pairs(preTable) do
		if finalTable[k] == nil then
			finalTable[k] = v
		end
	end

	return finalTable
end)

local ISLEANINGCV_VM = false

function LeanCalcVMView(wep, vm, oldPos, oldAng, pos, ang, ...)
	if ISLEANINGCV_VM then return end
	local ply = LocalPlayer()
	if GetViewEntity() ~= ply then return end

	if not ply.tfacastoffset or ply.tfacastoffset <= 0.001 then
		local status = ply.TFALean or 0

		if math.abs(status) > 0.001 then
			local off = Vector(0, status * -LeanOffset, 0)
			off:Rotate(ang)
			ang:RotateAroundAxis(ang:Forward(), status * 12 * (wep.ViewModelFlip and -1 or 1))
			pos = bestcase(pos, pos + off, ply)
			ISLEANINGCV_VM = true
			local tpos, tang = hook.Run("CalcViewModelView", wep, vm, oldPos, oldAng, pos, ang, ...)
			ISLEANINGCV_VM = false

			if tpos then
				pos = tpos
			end

			if tang then
				ang = tang
			end

			return pos, ang
		end
	end
end

hook.Add("CalcViewModelView", "TFALeanCalcVMView", LeanCalcVMView)