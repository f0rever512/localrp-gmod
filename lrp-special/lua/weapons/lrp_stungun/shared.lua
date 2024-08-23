STUNGUN = {}

include("config.lua")

SWEP.Instructions = 'ПКМ + ЛКМ - Выстрелить'
SWEP.Category = 'LocalRP - Special'
SWEP.Passive = 'normal'
SWEP.Sight = 'revolver'

SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cg_ocrp2/v_taser.mdl"
SWEP.WorldModel = "models/weapons/cg_ocrp2/w_taser.mdl"

SWEP.UseHands = false

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Uncharging = false
SWEP.Range = 200
SWEP.AimPos = Vector(-13, 0.9, 4.1)
SWEP.AimAng = Angle(-2.5, -0.65, -10)
SWEP.LRPGuns = true

function SWEP:SetupDataTables()
    self:NetworkVar('Bool', 0, 'Ready')
	self:NetworkVar('Bool', 1, 'Reloading')
end

function SWEP:Initialize()
    self:SetReady(false)
	self.aimProgress = 0
end

function SWEP:Deploy()
    self:SetReady(false)
    return true
end

function SWEP:OnDrop()
	self:Deploy()
end

function SWEP:OnRemove()
    self:Deploy()
end

function SWEP:Holster()
    self:SetReady(false)
    self.aimProgress = 0
    return true
end

function SWEP:DoEffect(tr)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetStart(self.Owner:GetShootPos())
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self )
	util.Effect("ToolTracer", effectdata)
end

function SWEP:CanFire()
    if CurTime() < self:GetNextPrimaryFire() or self.Owner:WaterLevel() == 3 then
        self:EmitSound('weapons/clipempty_pistol.wav', 100)
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
        local pos, dir = LocalToWorld(Vector(6, 0.6, 4), Angle(-2.5, -0.6, 5), att.Pos, att.Ang)
        return pos, dir:Forward()
    else
        return ply:GetShootPos(), (ply.viewAngs or ply:EyeAngles()):Forward()
    end
end

function SWEP:PrimaryAttack()
	if not self:GetReady() and not self:CanPrimaryAttack() or not self:CanFire() then return end
	-- if self.Charge < 100 then return end

	if self.Charge < 100 then
		if SERVER then
			self.Owner:EmitSound('weapons/clipempty_pistol.wav', 60)
		end

		self:SetNextPrimaryFire(CurTime() + 1)
		return
	end

	self.Uncharging = true

	-- local tr = util.TraceLine(util.GetPlayerTrace( self.Owner ))
	self.Owner:LagCompensation(true)
	local pos, pos2 = self:GetShootPos()
	local tr = util.TraceLine( {
		start = self:GetShootPos(),
		endpos = pos + pos2 * self.Range
	} )
	self.Owner:LagCompensation(false)

	self:DoEffect(tr)

	if SERVER then
		self.Owner:EmitSound('npc/turret_floor/shoot' .. math.random(1, 2) .. '.wav', 80, 100)
	end

	local ent = tr.Entity

	if CLIENT then return end

	-- Don't proceed if we don't hit any player
	if not IsValid(ent) or not ent:IsPlayer() then return end
	if IsValid(ent.tazeragdoll) then return end
	-- if self.Owner:GetShootPos():Distance(tr.HitPos) > self.Range then return end

	if not STUNGUN.IsPlayerImmune(ent) and (STUNGUN.AllowFriendlyFire or not STUNGUN.SameTeam(self.Owner, ent)) then
		-- Damage
		if (STUNGUN.StunDamage and STUNGUN.StunDamage > 0) and not ent.tazeimmune then
			local dmginfo = DamageInfo()
				dmginfo:SetDamage(STUNGUN.StunDamage)
				dmginfo:SetAttacker(self.Owner)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamageType(DMG_SHOCK)
				dmginfo:SetDamagePosition(tr.HitPos)
				dmginfo:SetDamageForce(self.Owner:GetAimVector() * 30)
			ent:TakeDamageInfo(dmginfo)
		end

		hook.Run("PlayerTazed", ent, self.Owner)

		--The player might have died while getting tazed
		if ent:Alive() then
			-- Electrolute the player
			STUNGUN.Electrolute( ent, (ent:GetPos() - self.Owner:GetPos()):GetNormal() )
		end
	end
end

local chargeinc

function SWEP:Think()
	if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():Alive() then
        self:SetHoldType(self:GetReady() and self.Sight or self.Passive)

        if not self:GetReady() and self:GetOwner():KeyDown(IN_ATTACK2) then
            self:SetReady(true)
        end

        if self:GetReady() and self:GetOwner():KeyReleased(IN_ATTACK2) then
            self:SetReady(false)
        end
    end

	-- In charge of charging the swep
	-- Since we got the same in-sensitive code both client and serverside we don't need to network anything.
	if SERVER or (CLIENT and IsFirstTimePredicted()) then
		if not chargeinc then
			-- Calculate how much we should increase charge every tick based on how long we want it to take.
			chargeinc = ((100 / self.RechargeTime) * engine.TickInterval())
		end

		local inc = self.Uncharging and (-5) or chargeinc

		local oldCharge = self.Charge
		self.Charge = math.min(self.Charge + inc, 100)
		if oldCharge ~= 100 and self.Charge >= 100 then
			self.Owner:EmitSound('ambient/energy/spark' .. math.random(1,4) .. '.wav', 60, 100, 0.3)
		end
		if self.Charge < 0 then
			self.Uncharging = false
			self.Charge = 0
		end
	end
end

function SWEP:DrawHUD()
	local ply = self.Owner
	local pos, pos2 = self:GetShootPos()
    local e = {}
    e.start = pos
    e.endpos = pos + pos2 * 200
    e.filter = ply

	local pos = util.TraceLine(e).HitPos:ToScreen()
	if ply:GetViewEntity() == ply and self:GetReady() and not GetConVar('lrp_view'):GetBool() then
		draw.RoundedBox(20, pos.x - 4, pos.y - 4, 8, 8, Color( 0, 0, 0))
		draw.RoundedBox(20, pos.x - 3, pos.y - 3, 6, 6, Color( 255, 255, 255 ))
	end
end

function SWEP:SecondaryAttack() return end

function SWEP:Reload() return end

local shoulddisable = {} -- Disables muzzleflashes and ejections
shoulddisable[21] = true
shoulddisable[5003] = true
shoulddisable[6001] = true
function SWEP:FireAnimationEvent( pos, ang, event, options )
	if shoulddisable[event] then return true end
end

hook.Add("PhysgunPickup", "Tazer", function(_,ent)
	if not STUNGUN.AllowPhysgun and IsValid(ent:GetNWEntity("plyowner")) then return false end
end)
hook.Add("CanTool", "Tazer", function(_,tr,_)
	if not STUNGUN.AllowToolgun and IsValid(tr.Entity) and IsValid(tr.Entity:GetNWEntity("plyowner")) then return false end
end)

hook.Add("StartCommand", "Tazer", function(ply, cmd)
	if ply:GetNWBool("tazefrozen", false) == false then return end

	cmd:ClearMovement()
	cmd:RemoveKey(IN_ATTACK)
	cmd:RemoveKey(IN_ATTACK2)
	cmd:RemoveKey(IN_RELOAD)
	cmd:RemoveKey(IN_USE)
	cmd:RemoveKey(IN_DUCK)
	cmd:RemoveKey(IN_JUMP)
end)

hook.Add('CreateMove', 'lrp-stungun.createmove', function(cmd)
	local wp = LocalPlayer():GetActiveWeapon()
	if not IsValid(wp) then return end
	if wp:GetClass() == 'lrp_stungun' and wp:GetVar('Ready') then
		cmd:RemoveKey(IN_SPEED)
		cmd:RemoveKey(IN_JUMP)
		cmd:RemoveKey(IN_USE)
	end
end)