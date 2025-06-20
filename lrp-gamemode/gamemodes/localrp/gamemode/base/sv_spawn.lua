util.AddNetworkString('lrp-gamemode.sendData')

local cfg = lrp_cfg

function GM:PlayerInitialSpawn(ply)
    if ply:IsBot() then
        ply:SetNW2Int('JobID', 1)
        ply:SetNW2Int('PlayerModel', 1)
        ply:SetNW2Int('PlayerSkin', 0)
    end

	ply:SetCanWalk(false)
	ply:SetCanZoom(false)
    
    ply:SetMaxHealth(100)
    ply:SetWalkSpeed(cfg.walkSpeed)
    ply:SetRunSpeed(cfg.runSpeed)
    ply:SetLadderClimbSpeed(140)
end

function GM:PlayerSpawn(ply)
    ply:SetTeam(ply:GetNW2Int('JobID'))
    
    local plyJob = ply:GetJobTable()
    
    ply:SetHealth(100)
    ply:SetArmor(plyJob.ar or 0)

    hook.Call('PlayerLoadout', self, ply)
    hook.Call('PlayerSetModel', self, ply)
end

function GM:PlayerLoadout(ply)
    self.BaseClass.PlayerLoadout(self, ply)

    for ammoName, amount in pairs(cfg.giveAmmo) do
		ply:GiveAmmo(amount, ammoName, true)
	end

    for wep, _ in pairs(cfg.defaultWeapons) do
		ply:Give(wep)
	end

    local plyJob = ply:GetJobTable()

    for _, wep in pairs(plyJob.weapons) do
		ply:Give(wep)
	end
end

function GM:PlayerSetModel(ply)
    local plyJob = ply:GetJobTable()

    ply:SetModel( plyJob.models[ ply:GetNW2Int('PlayerModel') == 0 and 1 or ply:GetNW2Int('PlayerModel') ] )
    ply:SetSkin(ply:GetNW2Int('PlayerSkin'))
    ply:SetPlayerColor(Vector(plyJob.color.r / 255, plyJob.color.g / 255, plyJob.color.b / 255))

    ply:SetupHands()
end

net.Receive('lrp-gamemode.sendData', function(_, ply)
    if not IsValid(ply) then return end
    local playerData = net.ReadTable()
    local isInit = net.ReadBool()

    ply:SetNW2Int('JobID', playerData.job)
    ply:SetNW2Int('PlayerModel', playerData.model)
    ply:SetNW2Int('PlayerSkin', playerData.skin)

    -- send data only for initialization
    if isInit then
        hook.Call('PlayerSpawn', GAMEMODE, ply)
    end
end)