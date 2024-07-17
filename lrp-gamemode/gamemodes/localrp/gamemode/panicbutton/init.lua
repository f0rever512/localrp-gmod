util.AddNetworkString("PanicButtonConnect")

net.Receive("PanicButtonConnect", function(_, ply)
    local team = ply:Team()
    if team ~= 3 and team ~= 4 and team ~= 5 then return end

    local name = ply:GetName()
    local pos = ply:GetPos() + ply:OBBCenter()
    local button = {name, pos}

    for k, v in pairs(player.GetAll()) do
        net.Start("PanicButtonConnect")
        net.WriteTable(button)
        net.Send(v)
    end
end)