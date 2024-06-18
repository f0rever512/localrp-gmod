local blacklist = {
	'weapon_physgun',
	'gmod_tool',
	'gmod_camera',
    'localrp_hands'
}

if SERVER then
    util.AddNetworkString( 'dropweapon' )
    
    concommand.Add('lrp_dropweapon', function(ply, cmd, args)
        local wep = ply:GetActiveWeapon()

        if not table.HasValue(blacklist, wep:GetClass()) and not ply:InVehicle() then
            if IsValid(ply) and IsValid(wep) then
                ply:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM, 229)
                ply:DropWeapon()
                -- timer.Simple(1, function() ply:DropWeapon() end)
            end
        else
            net.Start( 'dropweapon' )
            net.Send(ply)
        end
	end)
else
	net.Receive('dropweapon', function(len, ply)
        local ply = LocalPlayer()
        if ply:InVehicle() then
            notification.AddLegacy('В автомобиле нельзя выбросить оружие', NOTIFY_GENERIC, 3 )
            surface.PlaySound( "buttons/lightswitch2.wav" )
        else
            notification.AddLegacy('Это оружие нельзя выбросить', NOTIFY_GENERIC, 3 )
            surface.PlaySound( "buttons/lightswitch2.wav" )
        end
	end)
end