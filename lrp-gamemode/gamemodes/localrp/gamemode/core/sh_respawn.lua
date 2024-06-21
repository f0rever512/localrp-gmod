if SERVER then
	CreateConVar('lrp_respawntime', 5, FCVAR_ARCHIVE, 'Set respawn time')
end

local function respawntime(pl)
	return GetConVar('lrp_respawntime'):GetInt()
end

if SERVER then
	util.AddNetworkString("RespawnTimer")
	util.AddNetworkString('timerDestroy')
	--util.AddNetworkString('getRespawnTime')

	hook.Add("PlayerDeath", "RespawnTimer", function(ply)
		ply:SetNWInt('DeadTime', RealTime())
		ply.deadtime = ply:GetNWInt('DeadTime')
		net.Start("RespawnTimer")
			net.WriteInt(respawntime(ply), 13)
		net.Send(ply)
		--[[if ply:IsSuperAdmin() then
			timer.Simple(0, function()
				if ply:IsValid() then
					ply.NextSpawnTime = CurTime()
				end
			end)
		end]]
	end)
	hook.Add("PlayerDeathThink", "RespawnTimer", function(ply)
		if ply.deadtime && RealTime() - ply.deadtime < respawntime(ply) then
			return false
		else
			if ply:KeyDown(IN_ATTACK) or ply:KeyDown(IN_ATTACK2) or ply:KeyDown(IN_JUMP) then
				ply:Spawn()
				hook.Remove("HUDPaint", "RespawnTimerPro")
			end
			
			return true
		end
	end)
	
	hook.Add('PlayerSpawn', 'RespawnTimer_PreSpawn', function(pl)
		net.Start('timerDestroy')
		net.Send(pl)
	end )

end

if CLIENT then
	net.Receive("RespawnTimer", function()
		local respTime = net.ReadInt(13)
		local dead = RealTime()

		hook.Add("HUDPaint", "RespawnTimer", function()
			draw.SimpleTextOutlined("Возродиться можно через " .. math.Round(respTime - RealTime() + dead) .. " секунд", 'lrp-deathfont', ScrW() / 2, ScrH() * 0.975, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		end)

		timer.Create('AfterTimer', respTime, 1, function()
			hook.Add("HUDPaint", "RespawnTimerPro", function()
				draw.SimpleTextOutlined("Нажмите любую клавишу для возрождения", 'lrp-deathfont', ScrW() / 2, ScrH() * 0.975, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
			end)
		end)
		
		timer.Create('TimerRemoveHudDeath', respTime, 1, function()
			hook.Remove("HUDPaint", "RespawnTimer")
			dead = nil
		end)
	end)

	net.Receive('timerDestroy', function()
		timer.Remove('TimerRemoveHudDeath')
		timer.Remove('AfterTimer')
		hook.Remove("HUDPaint", "RespawnTimer")
		hook.Remove("HUDPaint", "RespawnTimerPro")
		dead = nil
	end )
end

-- if SERVER then
-- 	CreateConVar('lrp_respawntime', 5, FCVAR_ARCHIVE, 'Set respawn time')
-- end

-- local function respawntime(pl)
-- 	return GetConVar('lrp_respawntime'):GetInt()
-- end

-- if SERVER then
-- 	util.AddNetworkString("RespawnTimer")
-- 	util.AddNetworkString("TimerDestPlSpawn")

-- 	hook.Add("PlayerDeath", "RespawnTimer", function(ply)
-- 		ply:SetNWInt('DeadTime', RealTime())
-- 		ply.deadtime = ply:GetNWInt('DeadTime')
-- 		net.Start("RespawnTimer")
-- 		net.Send(ply)
-- 		--[[if ply:IsSuperAdmin() then
-- 			timer.Simple(0, function()
-- 				if ply:IsValid() then
-- 					ply.NextSpawnTime = CurTime()
-- 				end
-- 			end)
-- 		end]]
-- 	end)
-- 	hook.Add("PlayerDeathThink", "RespawnTimer", function(ply)
-- 		if ply.deadtime && RealTime() - ply.deadtime < respawntime(ply) then
-- 			return false
-- 		else
-- 			if ply:KeyDown(IN_ATTACK) or ply:KeyDown(IN_ATTACK2) or ply:KeyDown(IN_JUMP) then
-- 				ply:Spawn()
-- 				hook.Remove("HUDPaint", "RespawnTimerPro")
-- 			end
			
-- 			return true
-- 		end
-- 	end)
	
-- 	hook.Add('PlayerSpawn', 'RespawnTimer_PreSpawn', function(pl)
-- 		net.Start('TimerDestPlSpawn')
-- 		net.Send(pl)
-- 	end )

-- end

-- if CLIENT then
-- 	net.Receive("RespawnTimer", function()
-- 		local dead = RealTime()

-- 		hook.Add("HUDPaint", "RespawnTimer", function()
-- 			draw.SimpleTextOutlined("Возродиться можно через " .. math.Round(respawntime() - RealTime() + dead) .. " секунд", 'lrp-deathfont', ScrW() / 2, ScrH() * 0.975, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
-- 		end)

-- 		timer.Create('AfterTimer', respawntime(), 1, function()
-- 			hook.Add("HUDPaint", "RespawnTimerPro", function()
-- 				draw.SimpleTextOutlined("Нажмите любую клавишу для возрождения", 'lrp-deathfont', ScrW() / 2, ScrH() * 0.975, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
-- 			end)
-- 		end)
		
-- 		timer.Create('TimerRemoveHudDeath', respawntime(), 1, function()
-- 			hook.Remove("HUDPaint", "RespawnTimer")
-- 			dead = nil
-- 		end)
-- 	end)

-- 	net.Receive('TimerDestPlSpawn', function()
-- 		timer.Remove('TimerRemoveHudDeath')
-- 		timer.Remove('AfterTimer')
-- 		hook.Remove("HUDPaint", "RespawnTimer")
-- 		hook.Remove("HUDPaint", "RespawnTimerPro")
-- 		dead = nil
-- 	end )
-- end