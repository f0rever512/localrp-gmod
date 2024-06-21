AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Таран"
    SWEP.Slot = 4
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = true
end

CreateConVar("ntfm_canunweld", 0)
CreateConVar("ntfm_canunfreeze", 1)

SWEP.Author = "NathaanTFM"
SWEP.Instructions = "ПКМ + ЛКМ - Выбить"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/c_rpg.mdl")
SWEP.WorldModel = Model("models/weapons/w_rocket_launcher.mdl")

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "LocalRP - Special"

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = 0     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false     -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
    if CLIENT then self.LastIron = CurTime() end
    self:SetHoldType("passive")
end

function SWEP:Holster()
    self:SetIronsights(false)

    return true
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Ironsights")
    self:NetworkVar("Int", 1, "TotalUsedMagCount")
end

-- Check whether an object of this player can be rammed
local function canRam(ply)
    return IsValid(ply) and (ply.warranted == true or ply:isWanted() or ply:isArrested())
end

-- Ram action when ramming a door
local function ramDoor(ply, trace, ent)
    if ply:EyePos():DistToSqr(trace.HitPos) > 2025 then return false end

    local allowed = true
    if CLIENT then return allowed end

    unlock(ent)
    -- ent:Fire("open", "", .6)
    -- ent:Fire("setanimation", "open", .6)

    return true
end

-- Ram action when ramming a vehicle
local function ramVehicle(ply, trace, ent)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end

    if CLIENT then return false end -- Ideally this would return true after ent:GetDriver() check

    local driver = ent:GetDriver()
    if not IsValid(driver) or not driver.ExitVehicle then return false end

    driver:ExitVehicle()
    lock(ent)

    return true
end

-- Ram action when ramming a fading door
local function ramFadingDoor(ply, trace, ent)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end

    if CLIENT then return true end

    if not ent.fadeActive then
        ent:fadeActivate()
        timer.Simple(5, function() if IsValid(ent) and ent.fadeActive then ent:fadeDeactivate() end end)
    end

    return true
end

-- Ram action when ramming a frozen prop
local function ramProp(ply, trace, ent)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end
    if ent:GetClass() ~= "prop_physics" then return false end

    if CLIENT then return true end

    if GetConVar("ntfm_canunweld") then
        constraint.RemoveConstraints(ent, "Weld")
    end

    if GetConVar("ntfm_canunfreeze") then
        ent:GetPhysicsObject():EnableMotion(true)
    end

    return true
end

-- Decides the behaviour of the ram function for the given entity
local function getRamFunction(ply, trace)
    local ent = trace.Entity
    if not IsValid(ent) then return fp{fnId, false} end

    local override = hook.Call("canDoorRam", nil, ply, trace, ent)

    return
        override ~= nil     and fp{fnId, override}                                  or
        isdoor(ent)         and fp{ramDoor, ply, trace, ent}                        or
        ent:IsVehicle()     and fp{ramVehicle, ply, trace, ent}                     or
        ent.fadeActivate    and fp{ramFadingDoor, ply, trace, ent}                  or
        ent:GetPhysicsObject():IsValid() and not ent:GetPhysicsObject():IsMoveable()
                                         and fp{ramProp, ply, trace, ent}           or
        fp{fnId, false} -- no ramming was performed
end

function SWEP:PrimaryAttack()
    if not self:GetIronsights() then return end

    self:SetNextPrimaryFire(CurTime() + 2.5)

    self:GetOwner():LagCompensation(true)
    local trace = self:GetOwner():GetEyeTrace()
    self:GetOwner():LagCompensation(false)

    local hasRammed = getRamFunction(self:GetOwner(), trace)()

    if SERVER then
        hook.Call("onDoorRamUsed", GAMEMODE, hasRammed, self:GetOwner(), trace)
    end
    
    if not hasRammed then return end

    self:SetTotalUsedMagCount(self:GetTotalUsedMagCount() + 1)

    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:GetOwner():EmitSound(self.Sound)
    self:GetOwner():ViewPunch(Angle(-10, math.Round(util.SharedRandom("DoorRam" .. self:EntIndex() .. "_" .. self:GetTotalUsedMagCount(), -5, 5)), 0))
end

function SWEP:SecondaryAttack()
    if CLIENT then self.LastIron = CurTime() end
    self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:GetViewModelPosition(pos, ang)
    local Mul = 1

    if self.LastIron > CurTime() - 0.25 then
        Mul = math.Clamp((CurTime() - self.LastIron) / 0.25, 0, 1)
    end

    if self:GetIronsights() then
        Mul = 1-Mul
    end

    ang:RotateAroundAxis(ang:Right(), - 15 * Mul)
    return pos,ang
end

function SWEP:Think()
    if self:GetOwner():KeyDown(IN_ATTACK2) then
        self:SetIronsights(true)
    elseif !self:GetOwner():KeyDown(IN_ATTACK2) then
        self:SetIronsights(false)
    end

    if self:GetIronsights() then
        self:SetHoldType("shotgun")
    else
        self:SetHoldType("passive")
    end
end

hook.Add("SetupMove", "DoorRamJump", function(ply, mv)
    local wep = ply:GetActiveWeapon()
    if not wep:IsValid() or wep:GetClass() ~= "lrp_battering_ram" or not wep.GetIronsights or not wep:GetIronsights() then return end

    mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
end)

hook.Add("SetupMove", "RamSpeedMovements", function(ply, mv)
    local wep = ply:GetActiveWeapon()
    
    if !ply:Alive() then return end
    if !IsValid(wep) then return end

    if wep:GetClass() == "lrp_battering_ram" and wep:GetIronsights() then
        mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * .9)
    end
end)

hook.Add('CreateMove', 'RamRemoveMovements', function(cmd)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if !ply:Alive() then return end
    if !IsValid(wep) then return end

    if wep:GetClass() == "lrp_battering_ram" and wep:GetIronsights() then
        cmd:RemoveKey(IN_SPEED)
        cmd:RemoveKey(IN_WALK)
    else
        return
    end
end)