util.AddNetworkString('lrp.menu-main')
util.AddNetworkString('lrp-act')
util.AddNetworkString('lrp-respawn')

local nextKeyDown = 0
function GM:ShowHelp(ply)
	local delay = 0.8
	local timeLeft = nextKeyDown - CurTime()
	if timeLeft < 0 then
		net.Start('lrp.menu-main')
		net.Send(ply)
		nextKeyDown = CurTime() + delay
	end
end

net.Receive('lrp-act', function(len, ply)
	local freezeTime = net.ReadInt(5)
    ply:Freeze(true)
	timer.Simple(freezeTime, function()
		ply:Freeze(false)
	end)
end)

net.Receive('lrp-respawn', function(len, ply)
    ply:KillSilent()
	timer.Simple(0.1, function()
		ply:Spawn()
	end)
end)