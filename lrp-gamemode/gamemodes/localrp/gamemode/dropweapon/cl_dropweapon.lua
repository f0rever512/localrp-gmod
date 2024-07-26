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