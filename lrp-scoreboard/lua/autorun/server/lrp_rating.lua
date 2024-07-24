util.AddNetworkString('sb-setRating')

Rating = Rating or {}
net.Receive('sb-setRating', function(len, ply)
    if not ply:IsAdmin() then return end
    local target = net.ReadEntity()
    local bool = net.ReadBool()

    if not Rating[target:SteamID()] then Rating[target:SteamID()] = 0 end

    Rating[target:SteamID()] = tonumber(bool and Rating[target:SteamID()] + 1 or Rating[target:SteamID()] - 1)
    print(Rating[target:SteamID()])
end)