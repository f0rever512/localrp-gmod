util.AddNetworkString('lrp-gamemode.notify')

local dropBlacklist = lrp_cfg.dropBlacklist

local meta = FindMetaTable('Player')

function meta:DropWeaponAnim()
    local ply = self
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and dropBlacklist[wep:GetClass()] or ply:InVehicle() then
        ply:NotifySound(ply:InVehicle() and 'В автомобиле нельзя выбросить оружие' or 'Это оружие нельзя выбросить', 3, NOTIFY_ERROR)

        return
    end

    if not IsValid(ply) or not IsValid(wep) then return end

    ply:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM, 229)
    timer.Simple(1, function() ply:DropWeapon(wep) end)
end

concommand.Add('lrp_dropweapon', function(ply, cmd, args) ply:DropWeaponAnim() end)

-- enums
NOTIFY_GENERIC	= 0
NOTIFY_ERROR    = 1
NOTIFY_UNDO		= 2
NOTIFY_HINT		= 3
NOTIFY_CLEANUP	= 4