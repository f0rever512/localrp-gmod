util.AddNetworkString('lrp-playerMenu.open')
util.AddNetworkString('lrp-act')
util.AddNetworkString('lrp-respawn')
util.AddNetworkString('lrp-ragdoll')

local showHelpDelay = 1

function GM:ShowHelp(ply)
    ply.NextShowHelp = ply.NextShowHelp or 0

    if ply.NextShowHelp > CurTime() then return end
    ply.NextShowHelp = CurTime() + showHelpDelay

    net.Start('lrp-playerMenu.open')
    net.Send(ply)
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
    timer.Simple(0, function()
        if not IsValid(ply) then return end
        ply:Spawn()
    end)
end)

net.Receive('lrp-ragdoll', function(_, ply)
    ply:SetRagdoll(net.ReadBool())
end)