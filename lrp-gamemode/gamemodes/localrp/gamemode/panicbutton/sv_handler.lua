util.AddNetworkString('lrp-panicButton')

net.Receive('lrp-panicButton', function(_, ply)

    local plyJob = ply:GetJobTable()
    if not plyJob.gov then return end

    local button = {
        owner = ply:GetName(),
        pos = ply:GetPos() + ply:OBBCenter(),
        time = CurTime() + 15 * 60, -- 15 min
    }

    net.Start('lrp-panicButton')
    net.WriteTable(button)
    net.Broadcast()

end)