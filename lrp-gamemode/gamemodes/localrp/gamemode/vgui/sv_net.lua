util.AddNetworkString('lrp.menu-main')
util.AddNetworkString('lrp-act')
util.AddNetworkString('lrp-respawn')

local nextKeyDown = 0
local keyDownDelay = 0.8

function GM:ShowHelp(ply)
    if CurTime() >= nextKeyDown then
        net.Start('lrp.menu-main')
        net.Send(ply)
        nextKeyDown = CurTime() + keyDownDelay
    end
end

net.Receive('lrp-act', function(_, ply)
    local freezeTime = net.ReadInt(5)
    ply:Freeze(true)
    timer.Simple(freezeTime, function()
        if not IsValid(ply) then return end
        ply:Freeze(false)
    end)
end)

net.Receive('lrp-respawn', function(_, ply)
    ply:KillSilent()
    timer.Simple(0.1, function()
        if not IsValid(ply) then return end
        ply:Spawn()
    end)
end)
