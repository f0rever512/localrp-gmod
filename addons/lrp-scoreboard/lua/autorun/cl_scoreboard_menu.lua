hook.Add("AddToolMenuTabs", "LRPScoreboard", function()
	spawnmenu.AddToolTab('LocalRP', '#LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption("LocalRP", "Client Options", "LocalRP Scoreboard", "Scoreboard", "", "", function(pnl)
		pnl:ClearControls()
		
		pnl:AddControl("Label", {Text = "Настройки таблицы счета (таба)"})

		pnl:AddControl("CheckBox", {Label = "Минималистичное отображение счета", Command = "lrp_sbminimal"})
		pnl:AddControl("CheckBox", {Label = "Заголовок LocalRP", Command = "lrp_sbtitle"})
	end)
end)