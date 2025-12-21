AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('sh_leans.lua')
include('shared.lua')
include('sh_leans.lua')

SWEP.WorldModel = ''

util.AddNetworkString('lrp-muzzleFlash')

function SWEP:MuzzleFlashCustom()
	if self.Silent then return end
    net.Start('lrp-muzzleFlash')
        net.WriteEntity(self)
    net.SendPVS(self:GetShootPos())
end

function SWEP:Equip() self:SetReady(false) end

function SWEP:Reload()

	if self:Clip1() >= self:GetMaxClip1() or self:Ammo1() < 1 or self:GetReloading() then return end

	self:SetNextPrimaryFire(CurTime() + self.ReloadTime)

    local ply = self:GetOwner()

	self:SetReady(false)
    self:SetReloading(true)
    self:SetHoldType(self.Sight)

    timer.Simple(0, function()
        self:EmitSound(self.ClipoutSound, 60, 100)
        self.Weapon:DefaultReload(ACT_VM_RELOAD)
    end)

    timer.Create('lrp-guns.timer.clipInSound' .. ply:SteamID(), self.ReloadTime - 1.25, 1, function()
        self:EmitSound(self.ClipinSound, 60, 100)
    end)
    
    timer.Create('lrp-guns.timer.slideSound' .. ply:SteamID(), self.ReloadTime - 0.75, 1, function()
        self:EmitSound(self.SlideSound, 60, 100)
    end)

    timer.Create('lrp-guns.timer.reloadEnd' .. ply:SteamID(), self.ReloadTime, 1, function()
        self:SetReloading(false)
    end)

end

local function disableSounds(ply)
    if not IsValid(ply) then return end

    timer.Remove('lrp-guns.timer.clipInSound' .. ply:SteamID())
    timer.Remove('lrp-guns.timer.slideSound' .. ply:SteamID())
    timer.Remove('lrp-guns.timer.reloadEnd' .. ply:SteamID())
end

function SWEP:Holster()

    local ply = self:GetOwner()

    disableSounds(ply)
    ply:SetNW2Int('TFALean', 0)

    return true
    
end

function SWEP:OnRemove()
    local ply = self:GetOwner()
    disableSounds(ply)

    self:SetReady(false)
    self:SetReloading(false)
end

function SWEP:OnDrop(ply)
    disableSounds(ply)

    self:SetReady(false)
    self:SetReloading(false)
end