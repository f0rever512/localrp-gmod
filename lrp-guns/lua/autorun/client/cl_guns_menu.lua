local resolutionsList = {128, 256, 512, 1024}
hook.Add("AddToolMenuTabs", 'lrp-guns.tab', function()
	spawnmenu.AddToolTab('LocalRP', '#LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption("LocalRP", "Client Options", 'lrp_guns', 'Guns', "", "", function(pnl)
		pnl:ClearControls()
	
		pnl:AddControl("Label", {Text = 'Клиентские настройки оружия'})

		local resolutionList = pnl:AddControl("listbox", {
			Label = 'Разрешение прицела'
		})
		resolutionList:SetSortItems(false)

		for int = 1, #resolutionsList do
			local resolution = resolutionsList[int]
			local optionName = resolution .. ' x ' .. resolution

			resolutionList:AddOption(optionName, {
				cl_lrp_sight_resolution = resolution
			})
		end
	end)
end)