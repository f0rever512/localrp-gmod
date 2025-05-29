util.AddNetworkString('lrp-loadData')
util.AddNetworkString('lrp-sendData')

function GM:PlayerInitialSpawn(ply)
	ply:SetCanWalk(false)
	ply:SetCanZoom(false)
end

local cfg = lrp_cfg

function GM:PlayerSpawn(ply)
    if not ply:IsBot() then
        net.Start('lrp-loadData')
        net.Send(ply)
        net.Receive('lrp-sendData', function(_, ply)
            local playerData = net.ReadTable()
            ply:SetJob(playerData.job)
        end)
    else
        ply:SetJob(1)
    end

    for ammoName, amount in pairs(cfg.giveAmmo) do
		ply:GiveAmmo(amount, ammoName, true)
	end

    ply:SetupHands()

	return true
end