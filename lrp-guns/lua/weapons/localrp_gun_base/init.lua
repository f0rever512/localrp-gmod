AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('sh_leans.lua')
include('shared.lua')
include('sh_leans.lua')

SWEP.WorldModel = ''

util.AddNetworkString('lrp-muzzleFlash')
-- util.AddNetworkString('lrp-oldShooting')

-- CreateConVar('sv_lrp_oldshoot', 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Enable/disable old shooting')

-- cvars.AddChangeCallback('sv_lrp_oldshoot', function(convar, oldValue, newValue)
--     net.Start('lrp-oldShooting')
--     net.WriteInt(newValue, 3)
--     net.Broadcast()
-- end)

function SWEP:MuzzleFlashCustom()
	if self.Silent then return end
    net.Start('lrp-muzzleFlash')
        net.WriteEntity(self)
    net.SendPVS(self:GetShootPos())
end