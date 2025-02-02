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