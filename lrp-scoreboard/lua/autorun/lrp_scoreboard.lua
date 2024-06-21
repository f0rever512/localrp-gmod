if CLIENT then
	CreateClientConVar('lrp_sbtitle', '1', true, false)
	CreateClientConVar("lrp_sbminimal", '1', true, false)

	surface.CreateFont( "ScoreboardFont", {
        font = "Calibri",
        size = 25,
        weight = 300,
        antialias = true,
        extended = true
    })

    surface.CreateFont( "ScoreboardFontBold", {
        font = "Calibri",
        size = 30,
        weight = 500,
        antialias = true,
        extended = true
    })
end

if SERVER then
	function adminstration(cmd, text)
		net.Receive( cmd, function( len, ply )
			local p = net.ReadEntity()
			if ply:IsAdmin() then
				print(ply:GetName(), text, p:GetName())
				if cmd == "kickuser" then
					p:Kick( "Kicked from the server" )
				elseif cmd == "5m" then
					p:Ban( 5, true )
				elseif cmd == "15m" then
					p:Ban( 15, true )
				elseif cmd == "freeze" then
					p:Freeze( true )
				elseif cmd == "unfreeze" then
					p:Freeze( false )
				elseif cmd == "5sec" then
					if p:Alive() then
						p:Ignite(5)
					end
				elseif cmd == "10sec" then
					if p:Alive() then
						p:Ignite(10)
					end
				elseif cmd == "unignite" then
					if p:Alive() then
						p:Extinguish()
					end
				elseif cmd == "5hp" then
					if p:Alive() then
						p:SetHealth(5)
					end
				elseif cmd == "25hp" then
					if p:Alive() then
						p:SetHealth(25)
					end
				elseif cmd == "50hp" then
					if p:Alive() then
						p:SetHealth(50)
					end
				elseif cmd == "100hp" then
					if p:Alive() then
						p:SetHealth(100)
					end
				elseif cmd == "kill" then
					if p:Alive() then
						p:Kill()
					end
				elseif cmd == "silkill" then
					if p:Alive() then
						p:KillSilent()
					end
				elseif cmd == "0ar" then
					if p:Alive() then
						p:SetArmor(0)
					end
				elseif cmd == "25ar" then
					if p:Alive() then
						p:SetArmor(25)
					end
				elseif cmd == "50ar" then
					if p:Alive() then
						p:SetArmor(50)
					end
				elseif cmd == "100ar" then
					if p:Alive() then
						p:SetArmor(100)
					end
				elseif cmd == "resp" then
					p:Spawn()
				else
					return
				end
			end
		end)
	end
	cmdnetwork = {
		"kickuser",
		"5m",
		"15m",
		"freeze",
		"unfreeze",
		"5sec",
		"10sec",
		"unignite",
		"5hp",
		"25hp",
		"50hp",
		"100hp",
		"kill",
		"silkill",
		"0ar",
		"25ar",
		"50ar",
		"100ar",
		"resp",
	}
	for v, k in pairs(cmdnetwork) do
		util.AddNetworkString(k)
	end

	local cmdtable = {}
	cmdtable["kickuser"] = "кикнул"
	cmdtable["5m"] = "забанил на 5 минут"
	cmdtable["15m"] = "забанил на 15 минут"
	cmdtable["freeze"] = "заморозил"
	cmdtable["unfreeze"] = "разморозил"
	cmdtable["5sec"] = "поджег на 5 секунд"
	cmdtable["10sec"] = "поджег на 10 секунд"
	cmdtable["unignite"] = "потушил"
	cmdtable["5hp"] = "установил 5 здоровья"
	cmdtable["25hp"] = "установил 25 здоровья"
	cmdtable["50hp"] = "установил 50 здоровья"
	cmdtable["100hp"] = "установил 100 здоровья"
	cmdtable["kill"] = "убил"
	cmdtable["silkill"] = "тихо убил"
	cmdtable["0ar"] = "установил 0 брони"
	cmdtable["25ar"] = "установил 25 брони"
	cmdtable["50ar"] = "установил 50 брони"
	cmdtable["100ar"] = "установил 100 брони"
	cmdtable["resp"] = "возродил"

	for v, k in pairs(cmdtable) do
		adminstration(v, k)
	end
end

local function ToggleScoreboard(toggle)
	if toggle then
		--gui.EnableScreenClicker( true )
		SBPanel = vgui.Create("DPanel")
		SBPanel:SetSize(ScrW() * .4, ScrH() * .8)
		SBPanel:SetPos(-SBPanel:GetWide(), ScrH() * .5 - SBPanel:GetTall() / 2)
		SBPanel:MoveTo(ScrW() * .5 - SBPanel:GetWide() / 2, ScrH() * .5 - SBPanel:GetTall() / 2, 0.2, 0)
		SBPanel:SetAlpha(0)
		SBPanel:AlphaTo(255, 0.2, 0)
		SBPanel:MakePopup()
		SBPanel.Paint = function(self, w, h)
			draw.RoundedBox( 20, 0, 0, w, h, Color(0, 80, 65, 220) )
			if GetConVarNumber('lrp_sbtitle') == 1 then
				draw.SimpleText('LocalRP - Scoreboard', "ScoreboardFontBold", w / 2, h * .02, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) --GetHostName()
			end
		end

		local scroll = vgui.Create("DScrollPanel", SBPanel)
		scroll:SetPos(0, SBPanel:GetTall() * .04)
		scroll:SetSize(SBPanel:GetWide(), SBPanel:GetTall() * .92)

		local ypos = 0

		for k, v in pairs(player.GetAll()) do
			local plypanel = vgui.Create("DButton", scroll)
			plypanel:SetPos(0, ypos)
			plypanel:SetSize(SBPanel:GetWide(), SBPanel:GetTall() * .06)
			plypanel:SetText("")
			plypanel.DoClick = function()
				local LRPDerma = DermaMenu()

				LRPDerma:AddOption( v:GetName() .. " (" .. v:GetUserGroup() .. ")", function()
					if IsValid(v) then
						v:ShowProfile()
					end
				end):SetIcon( "icon16/user.png" )
					
				local steamid = LRPDerma:AddOption( "Скопировать SteamID", function() SetClipboardText(v:SteamID()) end )
				steamid:SetIcon( "icon16/information.png" )

					if LocalPlayer():IsAdmin() then
						LRPDerma:AddSpacer()

						local KickUser = LRPDerma:AddOption( "Кикнуть", function() net.Start( "kickuser" ) net.WriteEntity( v ) net.SendToServer() end )
						KickUser:SetIcon( "icon16/user_delete.png" )
						
						local BanUser, icon = LRPDerma:AddSubMenu("Забанить")
						icon:SetIcon( "icon16/delete.png" )
						BanUser:AddOption( "5 Минут", function() net.Start( "5m" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/time.png" )
						BanUser:AddOption( "15 Минут", function() net.Start( "15m" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/time.png" )
					
							LRPDerma:AddSpacer()
							
							if v:IsFrozen() == false then
								local FreezeUser = LRPDerma:AddOption( "Заморозить", function() net.Start( "freeze" ) net.WriteEntity( v ) net.SendToServer() end )
								FreezeUser:SetIcon( "icon16/lock.png" )
							else
								local UnFreezeUser = LRPDerma:AddOption( "Разморозить", function() net.Start( "unfreeze" ) net.WriteEntity( v ) net.SendToServer() end )
								UnFreezeUser:SetIcon( "icon16/lock_open.png" )
							end
							
							if v:IsOnFire() == false then
								local IgniteUser, icon = LRPDerma:AddSubMenu("Поджечь")
								icon:SetIcon( "icon16/weather_sun.png" )
								IgniteUser:AddOption( "5 Секунд", function() net.Start( "5sec" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/time.png" )
								IgniteUser:AddOption( "10 Секунд", function() net.Start( "10sec" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/time.png" )
							else
								local UnIgniteUser = LRPDerma:AddOption( "Потушить", function() net.Start( "unignite" ) net.WriteEntity( v ) net.SendToServer() end )
								UnIgniteUser:SetIcon( "icon16/weather_rain.png" )
							end
							
							local DamageUser, icon = LRPDerma:AddSubMenu("Установить здоровье")
							icon:SetIcon( "icon16/heart_add.png" )
							DamageUser:AddOption( "5 HP", function() net.Start( "5hp" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/heart.png" )
							DamageUser:AddOption( "25 HP", function() net.Start( "25hp" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/heart.png" )
							DamageUser:AddOption( "50 HP", function() net.Start( "50hp" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/heart.png" )
							DamageUser:AddOption( "100 HP", function() net.Start( "100hp" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/heart.png" )

							local ArmorUser, icon = LRPDerma:AddSubMenu("Установить броню")
							icon:SetIcon( "icon16/wand.png" )
							ArmorUser:AddOption( "0 AR", function() net.Start( "0ar" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/wand.png" )
							ArmorUser:AddOption( "25 AR", function() net.Start( "25ar" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/wand.png" )
							ArmorUser:AddOption( "50 AR", function() net.Start( "50ar" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/wand.png" )
							ArmorUser:AddOption( "100 AR", function() net.Start( "100ar" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/wand.png" )

							local DeathUser, icon = LRPDerma:AddSubMenu("Убить")
							icon:SetIcon( "icon16/user_red.png" )
							DeathUser:AddOption( "Убить", function() net.Start( "kill" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/heart_delete.png" )
							DeathUser:AddOption( "Тихо убить", function() net.Start( "silkill" ) net.WriteEntity( v ) net.SendToServer() end ):SetIcon( "icon16/heart_delete.png" )

							local RespawnUser = LRPDerma:AddOption( "Возродить", function() net.Start( "resp" ) net.WriteEntity( v ) net.SendToServer() end )
							RespawnUser:SetIcon( "icon16/arrow_refresh.png" )
					end
				
				LRPDerma:Open()
			end

			local name = v:Name()
			local frags = v:Frags()
			local deaths = v:Deaths()
			local ping = v:Ping()
			plypanel.Paint = function(self, w, h)
				if IsValid(v) then
					surface.SetDrawColor(0, 0, 0, 125)
					surface.DrawRect(0, 0, w, h)
					--draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 125) )
					draw.SimpleText(name, "ScoreboardFont", w * .125, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					if GetConVarNumber("lrp_sbminimal") == 0 then
						draw.SimpleText(" Frags: " .. frags .. " | ".. "Deaths: " .. deaths .. " | " .. "Ping: " .. ping, "ScoreboardFont", w * .9, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					else
						draw.SimpleText(frags, "ScoreboardFont", w * .76, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						draw.SimpleText(deaths, "ScoreboardFont", w * .83, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						draw.SimpleText(ping, "ScoreboardFont", w * .9, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				end
			end

			ypos = ypos + plypanel:GetTall() * 1.1
			local img = vgui.Create( "AvatarImage", plypanel )
			img:SetSize(plypanel:GetWide() * .07, plypanel:GetTall())
			img:SetPos( plypanel:GetWide() * .045, plypanel:GetTall() * .01)
			img:SetPlayer( v, 38 )

			local imgb = vgui.Create( "DButton", plypanel )
			imgb:SetText( "" )
			imgb:SetSize(plypanel:GetWide() * .07, plypanel:GetTall())
			imgb:SetPos( plypanel:GetWide() * .045, plypanel:GetTall() * .01)
			imgb.Paint = function( self, w, h )
				if IsValid(v) then
					draw.RoundedBox( 3, 0, 0, w, h, Color( 0, 0, 0, 0 ) )
				end
			end
			imgb.DoClick = function()
				if IsValid(v) then
					v:ShowProfile()
				end
			end

			local mute = vgui.Create( "DImageButton", plypanel )
			mute:SetSize(plypanel:GetWide() * .07, plypanel:GetTall())
			mute:SetPos( plypanel:GetWide() * .93, plypanel:GetTall() * .01)
			mute:SetPlayer( v, 38 )
			if v:IsMuted() == false then
				mute:SetImage( "icon32/unmuted.png" )
			else
				mute:SetImage( "icon32/muted.png" )
			end
			mute.DoClick = function()
				if mute:GetImage() == "icon32/unmuted.png" then
					v:SetMuted( true )
					mute:SetImage( "icon32/muted.png" )
				else
					v:SetMuted( false )
					mute:SetImage( "icon32/unmuted.png" )
				end
			end

			local rangicon = vgui.Create( "DImage", plypanel )
			rangicon:SetSize(plypanel:GetWide() * .02, 16)
			rangicon:SetPos(plypanel:GetWide() * .015, plypanel:GetTall() * .375)
			if v:IsAdmin() then
				rangicon:SetImage("icon16/user_red.png")
			else
				rangicon:SetImage("icon16/user.png")
			end
		end
	else
		SBPanel:AlphaTo(0, 0.2, 0)
		SBPanel:MoveTo(ScrW(), ScrH() * .5 - SBPanel:GetTall() / 2, 0.2, 0)
		--gui.EnableScreenClicker(false)
		if IsValid(SBPanel) then
			timer.Simple( 0.2, function()
				SBPanel:Remove()
			end)
		end
	end
end

hook.Add( "ScoreboardShow", "Scoreboard_Open", function()
    ToggleScoreboard(true)
	return false
end )

hook.Add( "ScoreboardHide", "Scoreboard_Close", function()
	ToggleScoreboard(false)
	CloseDermaMenus()
end )