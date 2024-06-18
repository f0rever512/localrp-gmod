util.AddNetworkString('lrpmenu')
util.AddNetworkString('lrp-act')

function GM:ShowHelp(ply)
	net.Start('lrpmenu')
	net.Send(ply)
end

net.Receive('lrp-act', function(len, ply)
	local time = net.ReadInt(5)
    ply:Freeze(true)
	timer.Simple(time, function()
		ply:Freeze(false)
	end)
end)