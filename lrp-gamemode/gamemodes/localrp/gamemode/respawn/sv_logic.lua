local RESP_MSG = "RespawnTimer" -- Временно
local TIMER_DESTROY_MSG = 'timerDestroy' -- Временно

util.AddNetworkString(RESP_MSG) -- В будущем будем инициализировать где-то в другом месте, например: sv(sh)_nets.lua
util.AddNetworkString(TIMER_DESTROY_MSG) -- В будущем будем инициализировать где-то в другом месте, например: sv(sh)_nets.lua

local function sendRespawnTimer(ply)
    net.Start("RespawnTimer")
    net.WriteInt(respawntime(), 13)
    net.Send(ply)
end

hook.Add("PlayerDeath", "RespawnTimer", function(ply)
    local deadTime = RealTime()
    ply:SetNWInt('DeadTime', deadTime)
    ply.deadtime = deadTime
    sendRespawnTimer(ply)
end)

hook.Add("PlayerDeathThink", RESP_MSG, function(ply)
    local deadtime = ply.deadtime
    local respawnTime = getRespawnTime()
    if deadtime and RealTime() - deadtime < respawnTime then
        return false
    else
        if ply:KeyDown(IN_ATTACK) or ply:KeyDown(IN_ATTACK2) or ply:KeyDown(IN_JUMP) then
            ply:Spawn()
            hook.Remove("HUDPaint", "RespawnTimerEnd")
        end
        return true
    end
end)

hook.Add('PlayerSpawn', 'RespawnTimer_PreSpawn', function(pl)
    net.Start(TIMER_DESTROY_MSG)
    net.Send(pl)
end)