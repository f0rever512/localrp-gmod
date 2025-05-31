net.Receive('lrp-gamemode.notify', function()
    local text = net.ReadString()
    local duration = net.ReadUInt(4)
    local type = net.ReadUInt(3)
    local sound = net.ReadString()

    notification.AddLegacy(text, type, duration)
    surface.PlaySound(sound)
end)

net.Receive('lrp-gamemode.anim', function()
    local animID = net.ReadUInt(12)

    ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, animID, true)
end)

lrp = lrp or {}

function lrp.lang(key, ...)
    local text = language.GetPhrase(key)
    local args = {...}

    if #args > 0 then
        return string.format(text, unpack(args))
    else
        return text
    end
end