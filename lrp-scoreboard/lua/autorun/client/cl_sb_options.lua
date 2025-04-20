hook.Add("AddToolMenuTabs", "LRPScoreboard", function()
	spawnmenu.AddToolTab('LocalRP', '#LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption("LocalRP", "Client Options", "LocalRP Scoreboard", "Scoreboard", "", "", function(pnl)
		pnl:ClearControls()
		
		pnl:AddControl("Label", {Text = "Настройки Scoreboard"})

		pnl:AddControl("CheckBox", {Label = "Заголовок LocalRP", Command = 'cl_lrp_sb_title'})
	end)
end)