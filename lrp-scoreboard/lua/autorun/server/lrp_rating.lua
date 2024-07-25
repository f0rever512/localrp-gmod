util.AddNetworkString('sb-setRating')
util.AddNetworkString('sb-clGetRating')
util.AddNetworkString('sb-svGetRating')

playerRating = playerRating or {}

local function SavePlayerRating(data)
    local jsonData = util.TableToJSON(data)
    
    file.Write('lrp_player_rating.txt', jsonData)
end

local function LoadPlayerRating()
    if not file.Exists('lrp_player_rating.txt', "DATA") then return end

    local jsonData = file.Read('lrp_player_rating.txt', "DATA")
    playerRating = util.JSONToTable(jsonData) or {}
end

hook.Add("Initialize", 'LoadPlayerRating', LoadPlayerRating)

Rating = Rating or {}
net.Receive('sb-setRating', function(len, ply)
    if not ply:IsAdmin() then return end
    local target = net.ReadEntity()
    local bool = net.ReadBool()

    target:SetNWInt('rating', bool and target:GetNWInt('rating') + 1 or target:GetNWInt('rating') - 1)
    playerRating[target:SteamID()] = tonumber(target:GetNWInt('rating'))
    SavePlayerRating(playerRating)
end)

net.Receive('sb-clGetRating', function(len, ply)
    if not ply:IsAdmin() then return end
    local target = net.ReadEntity()
    local rating = playerRating[target:SteamID()]
    net.Start('sb-svGetRating')
    net.WriteInt(rating, 12)
    net.Send(ply)
end)