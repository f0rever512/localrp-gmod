function LRPDerma(pl)
	local lrpDerma = DermaMenu()

	lrpDerma:AddOption( pl:GetName() .. " (" .. pl:GetUserGroup() .. ")", function()
		if IsValid(pl) then
			pl:ShowProfile()
		end
	end):SetIcon( "icon16/user.png" )
		
	local steamid = lrpDerma:AddOption( "Скопировать SteamID", function() SetClipboardText(pl:SteamID()) end )
	steamid:SetIcon( "icon16/information.png" )

	if LocalPlayer():IsAdmin() then
		lrpDerma:AddSpacer()

		local KickUser = lrpDerma:AddOption( "Кикнуть", function() net.Start( "kickuser" ) net.WriteEntity(pl) net.SendToServer() end )
		KickUser:SetIcon( "icon16/user_delete.png" )
		
		local BanUser, icon = lrpDerma:AddSubMenu("Забанить")
		icon:SetIcon( "icon16/delete.png" )
		BanUser:AddOption( "5 Минут", function() net.Start( "5m" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/time.png" )
		BanUser:AddOption( "15 Минут", function() net.Start( "15m" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/time.png" )
	
		-- Acts
		lrpDerma:AddSpacer()
		if pl:IsFrozen() == false then
			local FreezeUser = lrpDerma:AddOption( "Заморозить", function() net.Start( "freeze" ) net.WriteEntity(pl) net.SendToServer() end )
			FreezeUser:SetIcon( "icon16/lock.png" )
		else
			local UnFreezeUser = lrpDerma:AddOption( "Разморозить", function() net.Start( "unfreeze" ) net.WriteEntity(pl) net.SendToServer() end )
			UnFreezeUser:SetIcon( "icon16/lock_open.png" )
		end
		
		if pl:IsOnFire() == false then
			local IgniteUser, icon = lrpDerma:AddSubMenu("Поджечь")
			icon:SetIcon( "icon16/weather_sun.png" )
			IgniteUser:AddOption( "5 Секунд", function() net.Start( "5sec" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/time.png" )
			IgniteUser:AddOption( "10 Секунд", function() net.Start( "10sec" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/time.png" )
		else
			local UnIgniteUser = lrpDerma:AddOption( "Потушить", function() net.Start( "unignite" ) net.WriteEntity(pl) net.SendToServer() end )
			UnIgniteUser:SetIcon( "icon16/weather_rain.png" )
		end
		
		local DamageUser, icon = lrpDerma:AddSubMenu("Установить здоровье")
		icon:SetIcon( "icon16/heart_add.png" )
		DamageUser:AddOption( "5 HP", function() net.Start( "5hp" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/heart.png" )
		DamageUser:AddOption( "25 HP", function() net.Start( "25hp" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/heart.png" )
		DamageUser:AddOption( "50 HP", function() net.Start( "50hp" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/heart.png" )
		DamageUser:AddOption( "100 HP", function() net.Start( "100hp" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/heart.png" )

		local ArmorUser, icon = lrpDerma:AddSubMenu("Установить броню")
		icon:SetIcon( "icon16/shield_add.png" )
		ArmorUser:AddOption( "0 AR", function() net.Start( "0ar" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/shield.png" )
		ArmorUser:AddOption( "25 AR", function() net.Start( "25ar" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/shield.png" )
		ArmorUser:AddOption( "50 AR", function() net.Start( "50ar" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/shield.png" )
		ArmorUser:AddOption( "100 AR", function() net.Start( "100ar" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/shield.png" )

		local DeathUser, icon = lrpDerma:AddSubMenu("Убить")
		icon:SetIcon( "icon16/user_red.png" )
		DeathUser:AddOption( "Убить", function() net.Start( "kill" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/heart_delete.png" )
		DeathUser:AddOption( "Тихо убить", function() net.Start( "silkill" ) net.WriteEntity(pl) net.SendToServer() end ):SetIcon( "icon16/heart_delete.png" )

		local RespawnUser = lrpDerma:AddOption( "Возродить", function() net.Start( "resp" ) net.WriteEntity(pl) net.SendToServer() end )
		RespawnUser:SetIcon( "icon16/arrow_refresh.png" )
	end
	lrpDerma:Open()
end