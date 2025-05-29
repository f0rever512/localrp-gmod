util.AddNetworkString( 'dropweapon' )

local dropBlacklist = lrp_cfg.dropBlacklist

local meta = FindMetaTable('Player')

function meta:DropWeaponAnim()
    local ply = self
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and dropBlacklist[wep:GetClass()] or ply:InVehicle() then
        net.Start( 'dropweapon' )
        net.Send(ply)
        return
    end

    if not IsValid(ply) or not IsValid(wep) then return end

    ply:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM, 229)
    timer.Simple(1, function() ply:DropWeapon(wep) end)
end

concommand.Add('lrp_dropweapon', function(ply, cmd, args) ply:DropWeaponAnim() end)