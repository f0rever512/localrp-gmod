local resolutionsList = {128, 256, 512, 1024}
hook.Add("AddToolMenuTabs", 'lrp-guns.tab', function()
	spawnmenu.AddToolTab('LocalRP', '#LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption("LocalRP", "Client Options", 'cl_lrp_guns', 'Guns', "", "", function(pnl)
		pnl:ClearControls()

		pnl:AddControl("Label", {text = language.GetPhrase('lrp_guns.options.label_cl')})

		local resolutionList = pnl:AddControl("listbox", {
			label = language.GetPhrase('lrp_guns.options.sight_res'),
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

	-- spawnmenu.AddToolMenuOption("LocalRP", 'Server Options', 'sv_lrp_guns', 'Guns', "", "", function(pnl)
	-- 	pnl:ClearControls()
	-- 	pnl:AddControl("Label", {Text = 'Серверные настройки оружия'})
	-- 	pnl:AddControl("CheckBox", {Label = 'Старая стрельба', Command = 'sv_lrp_oldshoot'})
	-- end)
end)
