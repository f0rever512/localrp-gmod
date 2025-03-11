RunConsoleCommand('mp_show_voice_icons', '0')

util.AddNetworkString('TalkIconChat')

net.Receive('TalkIconChat', function(_, ply)
    local bool = net.ReadBool()
    ply:SetNW2Bool('ti_istyping', (bool ~= nil) and bool or false)
end)