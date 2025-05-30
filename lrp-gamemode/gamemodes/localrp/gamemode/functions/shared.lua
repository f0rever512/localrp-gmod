local meta = FindMetaTable('Player')

function meta:NotifySound(text, duration, type, sound)
    if SERVER then
        net.Start('lrp-gamemode.notify')
            net.WriteString(text)
            net.WriteUInt(duration or 2, 4)
            net.WriteUInt(type or NOTIFY_GENERIC, 3)
            net.WriteString(sound or 'buttons/lightswitch2.wav')
        net.Send(self)
    else
        notification.AddLegacy(text, type or NOTIFY_GENERIC, duration or 2)
        surface.PlaySound(sound or 'buttons/lightswitch2.wav')
    end
end