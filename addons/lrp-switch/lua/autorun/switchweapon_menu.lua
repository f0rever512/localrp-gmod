hook.Add("AddToolMenuTabs", "Switch", function()
	spawnmenu.AddToolTab('LocalRP', '#LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption("LocalRP", "Server Options", "LocalRP Switch Weapon", "Switch Weapon", "", "", function(pnl)
		pnl:ClearControls()

		pnl:AddControl("Label", {Text = "Настройки смены оружия"})
		pnl:AddControl("CheckBox", {Label = "Бесшумная смена оружия", Command = "silentswitch"})
	end)
end)