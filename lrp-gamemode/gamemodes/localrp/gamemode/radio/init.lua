util.AddNetworkString('lrp-radio.toggle')

local on = 'localrp/radio_on.wav'
local off = 'localrp/radio_off.wav'

net.Receive('lrp-radio.toggle', function(_, ply)
    local isStart = net.ReadBool()
    
    ply:SetNW2Bool('UsingRadio', isStart)
    ply:EmitSound(isStart and on or off, 40, 100)
end)