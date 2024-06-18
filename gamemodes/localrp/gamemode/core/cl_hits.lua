local hitnotify = {
	'Вы попали',
	'Попадание!',
	'Вы ранили человека',
	'Метко!',
	'В точку!'
}

gameevent.Listen("player_hurt")

hook.Add("player_hurt", 'lrp-hits', function( data )
    local pl = LocalPlayer()
	local attacker = Player(data.attacker)

	if IsValid(attacker) and attacker:Alive() and attacker == pl then
		notification.AddLegacy(table.Random(hitnotify), NOTIFY_GENERIC, 3)
		
		pl:EmitSound('npc/turret_floor/click1.wav', 40, 100 )
	end
end)