AddCSLuaFile()

SWEP.PrintName = "Руки"
SWEP.Slot = 0
SWEP.SlotPos = 1

SWEP.Author = "Blyatman & Mechanical Mind & Chessnut & Biozeminade"
SWEP.Instructions	= "ЛКМ - Указать / Схватить / Закрыть\nПКМ - Открыть\n К - Стучать в дверь"
SWEP.Category = "LocalRP - Special"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.HoldTypePassive = "normal"
SWEP.HoldTypePoint = "pistol"
SWEP.HoldTypeCarry = "magic"

SWEP.ViewModel = ""
SWEP.WorldModel	= ""

SWEP.IsAlwaysRaised = true
SWEP.UseHands = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.FireWhenLowered = true

SWEP.CarryDistance = 100
SWEP.NextReloadFire = 0
SWEP.cd = CurTime()

SWEP.IronSightsPos  = Vector(5, -1, -5)
SWEP.IronSightsAng  = Vector(12, 6, -2)

SWEP.SoundDoor = "doors/door_latch3.wav"
SWEP.unlockcar = "keys.mp3"
SWEP.lockcar = "keys2.mp3"
SWEP.alarmcar = 'keys3.mp3'

local CarryClass = {
	["prop_ragdoll"] = false,
	["prop_physics"] = false,
	["prop_physics_multiplayer"] = false,
	["func_breakable_surf"] = true,
	["func_breakable"] = true,
	["prop_dynamic"] = true,
	["player"] = true,
	["gmod_sent_vehicle_fphysics_wheel"] = true,
	['gmod_sent_vehicle_fphysics_base'] = true
}

local DoorClass = {
	"func_door",
	"func_door_rotating",
	"prop_door_rotating",
	"func_movelinear"
}

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextIdle")
	self:NetworkVar("Bool", 2, "Fists")
	self:NetworkVar("Float", 1, "NextDown")
	self:NetworkVar("Bool", 3, "Blocking")
end

function SWEP:Initialize()
	self:SetNextIdle(CurTime()+5)
	self:SetNextDown(CurTime()+5)
	self:SetHoldType(self.HoldTypePassive)
end

function SWEP:Deploy()
	if not(IsFirstTimePredicted())then
		--self:DoBFSAnimation("fists_draw")
		return
	end
	self:SetNextPrimaryFire(CurTime()+.1)

	--self:SetNextDown(CurTime())
	--self:DoBFSAnimation("fists_draw")
	return true
end

function SWEP:Holster()
	self:OnRemove()
	return true
end

function SWEP:Trace()
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = tr.start + self.Owner:GetAimVector() * 500
	tr.filter = function(ent) if ent.IsSimfphyscar then return true end end
	tr = util.TraceLine(tr)
	
	return tr.Entity
end

function SWEP:MakeSound(sound)
    if SERVER then
        self.Owner:EmitSound(sound)
    end
end

local function lookingAtLockable(ply, ent)
    local eyepos = ply:EyePos()
    return IsValid(ent) and (isdoor(ent) and eyepos:DistToSqr(ent:GetPos()) < 4200)
end

local function lockUnlockAnimation(ply, snd)
    ply:EmitSound("npc/metropolice/gear" .. math.floor(math.Rand(1,7)) .. ".wav")
    timer.Simple(0.9, function() if IsValid(ply) then ply:EmitSound(snd) end end)
    
    umsg.Start("anim_keys")
    umsg.Entity(ply)
    umsg.String("usekeys")
    umsg.End()
    
    ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
end

function SWEP:Lock(ent)
    if SERVER then
		if not ent:Lock() then
			return
		end
		if ent.alarm then
            self:MakeSound(self.alarmcar)
            ent.alarm = false
            return
        end
        ent:Lock()
        ent:SetLightsEnabled(true)
        timer.Simple(.1, function()
            ent:SetLightsEnabled(false)
            timer.Simple(.2, function()
                ent:SetLightsEnabled(true)
                timer.Simple(.1, function()
                    ent:SetLightsEnabled(false)
                end)
            end)
        end)
		--lockUnlockAnimation(self:GetOwner(), self.lockcar)
    end
end

function SWEP:UnLock(ent)
    if SERVER then
		if ent:Lock() then
			return
		end
		if ent.alarm then
            self:MakeSound(self.alarmcar)
            ent.alarm = false
            return
        end
        ent:UnLock()
        ent:SetLightsEnabled(true)
        timer.Simple(.5, function()
            ent:SetLightsEnabled(false)
        end)
		--lockUnlockAnimation(self:GetOwner(), self.unlockcar)
    end
end

function SWEP:CanPickup(ent)
	if ent:IsNPC() then return false end
	if(ent.IsLoot)then return true end
	local class=ent:GetClass()
	if CarryClass[class] then return end
	return true
end

local function doKnock(ply, sound)
    ply:EmitSound(sound, 100, math.random(90, 110))
    
    umsg.Start("anim_keys")
    umsg.Entity(ply)
    umsg.String("knocking")
    umsg.End()
end

function SWEP:PrimaryAttack()
	local eyetrace = self:GetOwner():GetEyeTrace()
	if IsValid(eyetrace.Entity) and table.HasValue(DoorClass, eyetrace.Entity:GetClass()) then
		
		if not lookingAtLockable(self:GetOwner(), eyetrace.Entity) then return end
		
		self:SetNextPrimaryFire(CurTime() + 2)

		if CLIENT then return nil end
		
		lock(eyetrace.Entity)
		lockUnlockAnimation(self:GetOwner(), self.SoundDoor)
	end

	if not(IsFirstTimePredicted())then return end
 
	local tr = self.Owner:GetEyeTraceNoCursor()

	if SERVER then
		self:SetCarrying()
		if IsValid(tr.Entity) and self:CanPickup(tr.Entity) and not tr.Entity:IsPlayer() then
			local Dist=(self.Owner:GetShootPos()-tr.HitPos):Length()
			if (Dist < self.CarryDistance) then
				if (tr.Entity.ContactPoisoned) then
					if(self.Owner.Murderer)then
						self.Owner:PrintMessage(HUD_PRINTTALK,"This is poisoned!")
						return
					else
						tr.Entity.ContactPoisoned=false
						HMCD_Poison(self.Owner,tr.Entity.Poisoner)
					end
				end
				self:SetCarrying(tr.Entity,tr.PhysicsBone,tr.HitPos,Dist)
				tr.Entity.Touched=true
				self:ApplyForce()
			end
		end
	end

	if self.cd > CurTime() then return end
    self.cd = CurTime() + 1

    local ent = self:Trace()
    if !IsValid(ent) then return end
    self:Lock(ent)
end

function SWEP:SecondaryAttack()
	local eyetrace = self:GetOwner():GetEyeTrace()
	if IsValid(eyetrace.Entity) and table.HasValue(DoorClass, eyetrace.Entity:GetClass()) then
		if not lookingAtLockable(self:GetOwner(), eyetrace.Entity) then return end
		
		self:SetNextSecondaryFire(CurTime() + 2)

		if CLIENT then return nil end
		
		unlock(eyetrace.Entity)
		lockUnlockAnimation(self:GetOwner(), self.SoundDoor)
	end

	if self.cd > CurTime() then return end
    self.cd = CurTime() + 1

    local ent = self:Trace()
    if !IsValid(ent) then return end
    self:UnLock(ent)
end

function SWEP:Reload()
	local eyetrace = self:GetOwner():GetEyeTrace()
	if IsValid(eyetrace.Entity) and table.HasValue(DoorClass, eyetrace.Entity:GetClass()) then
		if self.NextReloadFire > CurTime() then return end
		local eyetrace = self:GetOwner():GetEyeTrace()

		if not lookingAtLockable(self:GetOwner(), eyetrace.Entity) then return end

		self.NextReloadFire = CurTime() + 0.8

		if CLIENT then return nil end
		
		doKnock(self:GetOwner(), "physics/wood/wood_crate_impact_hard3.wav")
	end

	if not(IsFirstTimePredicted())then return end
end

local function KeysAnims(um)
    local ply = um:ReadEntity()
    if not IsValid(ply) then return end
    local Type = um:ReadString()
    ply[Type] = true
end

usermessage.Hook("anim_keys", KeysAnims)


hook.Add("CalcMainActivity", "animations", function(ply, velocity)
    if CLIENT and ply.knocking then
        ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
        ply.knocking = nil
    end

    if CLIENT and ply.usekeys then
        ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
        ply.usekeys = nil
    end
end)

function SWEP:ApplyForce()
	local target = self.Owner:GetAimVector() * self.CarryDist + self.Owner:GetShootPos()
	local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)
	if IsValid(phys) and not (self.CarryEnt:GetClass()=="prop_ragdoll") then
		local TargetPos=phys:GetPos()
		if(self.CarryPos)then TargetPos=self.CarryEnt:LocalToWorld(self.CarryPos) end
		local vec = target - TargetPos
		local len,mul = vec:Length(),self.CarryEnt:GetPhysicsObject():GetMass()
		if (len > self.CarryDistance) or (mul > 500) then
			self:SetCarrying()
			self:SetHoldType(self.HoldTypePassive)
			return
		end
		--if(self.CarryEnt:GetClass()=="prop_ragdoll")then mul=mul*2 end
		vec:Normalize()
		local avec,velo=vec*len,phys:GetVelocity()-self.Owner:GetVelocity()
		local CounterDir,CounterAmt=velo:GetNormalized(),velo:Length()
		if(self.CarryPos)then
			phys:ApplyForceOffset((avec-velo/2)*mul,self.CarryEnt:LocalToWorld(self.CarryPos))
		else
			phys:ApplyForceCenter((avec-velo/2)*mul)
		end
		phys:ApplyForceCenter(Vector(0,0,mul))
		phys:AddAngleVelocity(-phys:GetAngleVelocity()/10)
	end


--Ragdoll force
	local ragtarget = self.Owner:GetAimVector() * (self.CarryDistance - 30) + self.Owner:GetShootPos()
	local ragphys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)
	
	if IsValid(ragphys) and (self.CarryEnt:GetClass()=="prop_ragdoll") then
		local ragvec = ragtarget - ragphys:GetPos()
		local raglen = ragvec:Length()
		if raglen > 75 then
			self:SetCarrying()
			self:SetHoldType(self.HoldTypePassive)
			return
		end
		ragvec:Normalize()
		
		local ragtvec = ragvec * raglen * 15
		local ragavec = ragtvec - ragphys:GetVelocity()
		ragavec = ragavec:GetNormal() * math.min(37, ragavec:Length())
		ragavec = ragavec / ragphys:GetMass() * 15
		
		ragphys:AddVelocity(ragavec)
	end
end

function SWEP:OnRemove()
end

function SWEP:GetCarrying()
	return self.CarryEnt
end

function SWEP:SetCarrying(ent,bone,pos,dist)
	if IsValid(ent) then
		self.CarryEnt = ent
		self.CarryBone = bone
		self.CarryDist=dist
		if not (ent:GetClass()=="prop_ragdoll") then
			self.CarryPos=ent:WorldToLocal(pos)
		else
			self.CarryPos=nil
		end
	else
		self.CarryEnt = nil
		self.CarryBone = nil
		self.CarryPos = nil
		self.CarryDist=nil
	end
	--self.Owner:CalculateSpeed()
end
 
function SWEP:Think()
	if((IsValid(self.Owner))and(self.Owner:KeyDown(IN_ATTACK)))then
		if IsValid(self.CarryEnt) then
			self:ApplyForce()
		end
	elseif self.CarryEnt then
		self:SetCarrying()
	end

	if ((IsValid(self.CarryEnt)) or (self.CarryEnt)) and self.Owner:KeyDown(IN_ATTACK) then
		self:SetHoldType(self.HoldTypeCarry or self.HoldTypePassive)
	elseif self.Owner:KeyPressed(IN_ATTACK) then 
		self:SetHoldType(self.HoldTypePoint or self.HoldTypePassive)
	end

	if not self.Owner:KeyDown(IN_ATTACK) then
		self:SetHoldType(self.HoldTypePassive)
	end
end

function SWEP:IsEntSoft(ent)
	return ((ent:IsNPC())or(ent:IsPlayer()))
end

-- hook.Add("SetupMove", "HandsSpeed", function(ply, mv)
--     local wep = ply:GetActiveWeapon()
    
--     if !ply:Alive() then return end
--     if !IsValid(wep) then return end

--     if wep:GetClass() == 'localrp_hands' and wep.GetCarrying && wep:GetCarrying() then
--         mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * .8)
--     end
-- end)

-- local playerMeta = FindMetaTable( "Player" )

-- function playerMeta:CalculateSpeed()
--     local walk = 75
--     local run = 190
-- 	local wep = self:GetActiveWeapon()
-- 	if IsValid(wep) then
-- 		if wep.GetCarrying && wep:GetCarrying() then
-- 			walk = walk
-- 			run = walk
-- 		end
-- 	end
-- 	self:SetWalkSpeed(walk)
-- 	self:SetRunSpeed(run)
-- end

--[[
	function playerMeta:CalculateSpeed()
	// set the defaults
    local walk = 85-- nut.config.get("walkSpeed", default)
    local run = 115



	local wep = self:GetActiveWeapon()
	if IsValid(wep) then
		if wep.GetCarrying && wep:GetCarrying() then
			walk = walk * 0.5
			run = run * 0.4

		end
	end 

	// set out new speeds

	self:SetWalkSpeed(walk)
	self:SetRunSpeed(run)


end
]]