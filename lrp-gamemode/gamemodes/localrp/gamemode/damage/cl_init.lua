net.Receive('notifydmg', function()
    local hitgroup = net.ReadString()
    if hitgroup and hitgroup ~= "" then -- На всякий
        notification.AddLegacy('Ваша ' .. hitgroup .. ' повреждена', NOTIFY_GENERIC, 5)
	else
		notification.AddLegacy('Вы получили повреждение', NOTIFY_GENERIC, 5)
    end
end)

local hitnotify = {
    'Вы попали',
    'Попадание!',
    'Вы ранили человека',
    'Метко!',
    'В точку!'
}

gameevent.Listen("player_hurt")

hook.Add("player_hurt", 'lrp-hits', function(data)
    local pl = LocalPlayer()
    local attacker = Player(data.attacker)

    if IsValid(attacker) and attacker:Alive() and attacker == pl then
        notification.AddLegacy(hitnotify[math.random(#hitnotify)], NOTIFY_GENERIC, 3)
        pl:EmitSound('npc/turret_floor/click1.wav', 40, 100)
    end
end)