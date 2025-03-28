hook.Add("AddToolMenuTabs", 'lrpHud.tab', function()
	spawnmenu.AddToolTab('LocalRP', '#LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption("LocalRP", "Client Options", 'cl_lrp_hud', "HUD & Overhead", "", "", function(pnl)
		pnl:ClearControls()
		
		pnl:AddControl('label', {text = 'Клиентские настройки HUD & Overhead'})

		local hudType = pnl:AddControl('listbox', {label = 'Тип HUD'})
		hudType:SetSortItems(false)
        
		local hudOptions = {'Чистый', 'Стандартный (HL2)', 'LocalRP HUD'}
		for id, typeName in ipairs(hudOptions) do
			hudType:AddOption(typeName, {
				cl_lrp_hud_type = id - 1
			})
		end

		pnl:AddControl("CheckBox", {Label = "Информация над головой игрока", Command = "cl_lrp_overhead"})
	end)
end)