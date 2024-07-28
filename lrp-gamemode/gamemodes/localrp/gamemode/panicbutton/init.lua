util.AddNetworkString("PanicButtonConnect")

net.Receive("PanicButtonConnect", function(_, ply)
    local plyJob = ply:GetJob()
    if not plyJob.panicButton then return end

    local name = ply:GetName()
    local pos = ply:GetPos() + ply:OBBCenter()
    local button = {name, pos}

    net.Start("PanicButtonConnect")
        net.WriteTable(button)
    net.Broadcast()
end)