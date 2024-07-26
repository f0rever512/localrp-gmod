local dropBlacklist = {
    ['weapon_physgun'] = true,
    ['gmod_tool'] = true,
    ['gmod_camera'] = true,
    ['localrp_hands'] = true
} -- Позже вынести в отдельный конфиг-файл
playerMeta = FindMetaTable('Player')

util.AddNetworkString( 'dropweapon' ) -- В будущем будем инициализировать где-то в другом месте, например: sv(sh)_nets.lua

function playerMeta:dropWeapon()
    local ply = self
    local wep = ply:GetActiveWeapon()

    if dropBlacklist[wep:GetClass()] or ply:InVehicle() then
        net.Start( 'dropweapon' )
        net.Send(ply)
        return
    end

    if not IsValid(ply) or not IsValid(wep) then return end

    ply:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM, 229)
    ply:DropWeapon()
end

concommand.Add('lrp_dropweapon', function(ply, cmd, args) dropWeapon(ply) end)