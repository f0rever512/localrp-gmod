hook.Add("AddToolMenuTabs", "LRPView", function()
	spawnmenu.AddToolTab('LocalRP', '#LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption("LocalRP", "Client Options", "LocalRP View", "View", "", "", function(pnl)
		pnl:ClearControls()
	
		pnl:AddControl("Label", {Text = "Настройки вида от первого лица"})
		pnl:AddControl("CheckBox", {Label = "Вид от первого лица", Command = "lrp_view"})

		pnl:AddControl("CheckBox", {Label = "Блокировка вида", Command = "lrp_view_lock"})

		pnl:AddControl("slider", {
			label = "Максимальная блокировка (смотря вниз)",
			command = "lrp_view_lock_max",
			min = 75,
			max = 90
		})
		
		pnl:AddControl("CheckBox", {Label = "Прицел", Command = "lrp_view_crosshair"})
		pnl:AddControl("Color", {Label = "Цвет прицела", Red = "lrp_view_crosshair_color_r", Green = "lrp_view_crosshair_color_g", Blue = "lrp_view_crosshair_color_b", ShowAlpha = false, ShowHSV = true, ShowRGB = true, NumberMultiplier = "1"})
	end)
end)