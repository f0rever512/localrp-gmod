net.Receive('notifydmg', function(len)
    local hitgroup = net.ReadString()
    notification.AddLegacy( 'Ваша ' .. hitgroup .. ' повреждена', NOTIFY_GENERIC, 5 )
end)