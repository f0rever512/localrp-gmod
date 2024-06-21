hook.Add("AddToolMenuTabs", "LRPHud", function()
	spawnmenu.AddToolTab('LocalRP', '#LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption("LocalRP", "Client Options", "LocalRP HUD & Overhead", "HUD & Overhead", "", "", function(pnl)
		pnl:ClearControls()
		
		pnl:AddControl("Label", {Text = "Настройки HUD"})

		pnl:AddControl("slider", {
			label = "Тип HUD",
			command = "hud_type",
			min = 0,
			max = 2
		})

		pnl:AddControl("Label", {Text = "0 - Чистый | 1 - Стандартный | 2 - LocalRP"})

		-- local type = pnl:AddControl("listbox", {label = "Тип HUD"})
		-- type:AddOption("Чистый", {
		-- 	GetConVar( "hud_type" ):SetInt( 0 )
		-- })
		-- type:AddOption("Стандартный", {
		-- 	GetConVar( "hud_type" ):SetInt( 1 )
		-- })
		-- type:AddOption("LocalRP", {
		-- 	GetConVar( "hud_type" ):SetInt( 2 )
		-- })

		pnl:AddControl("CheckBox", {Label = "Информация над головой игрока", Command = "lrp_overhead"})
	end)
end)