local function SetSightResolution(_, _, int)
	GetConVar('cl_lrp_sight_resolution'):SetInt(int)
end

hook.Add("AddToolMenuTabs", 'LRPGuns', function()
	spawnmenu.AddToolTab('LocalRP', '#LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption("LocalRP", "Client Options", 'lrp_guns', 'Guns', "", "", function(pnl)
		pnl:ClearControls()
	
		pnl:AddControl("Label", {Text = 'Клиентские настройки оружия'})

		local resolutionList = pnl:AddControl("listbox", {
			Label = 'Разрешение прицела'
		})
		resolutionList:SetSortItems(false)

		local resolutionsList = {128, 256, 512, 1024}
		for a = 1, #resolutionsList do
			local resolution = resolutionsList[a]
			local optionName = resolution .. ' x ' .. resolution

			resolutionList:AddOption(optionName, {
				cl_lrp_sight_resolution = resolution
			})
		end
	end)

	cvars.AddChangeCallback('cl_lrp_sight_resolution', SetSightResolution, 'setSightResolution')
	SetSightResolution(_, _, GetConVar('cl_lrp_sight_resolution'):GetInt())
end)