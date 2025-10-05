hook.Add('AddToolMenuTabs', 'lrp-view.toolMenuTab', function()

    spawnmenu.AddToolTab('LocalRP', 'LocalRP', 'icon16/brick.png')

    spawnmenu.AddToolMenuOption('LocalRP', 'Client Options', 'cl_lrp_view', 'View', nil, nil, function(pnl)
        pnl:Help(language.GetPhrase('lrp_view.options.label'))

        pnl:CheckBox(language.GetPhrase('lrp_view.options.toggle'), 'lrp_view')

        pnl:CheckBox(language.GetPhrase('lrp_view.options.lock_toggle'), 'cl_lrp_view_lock')

		pnl:NumSlider(language.GetPhrase('lrp_view.options.lock_max'), 'cl_lrp_view_max_lock', 75, 90, 0)

		pnl:CheckBox(language.GetPhrase('lrp_view.options.crosshair'), 'cl_cl_lrp_view_crosshair')

		pnl:AddControl('Color', {
			label = language.GetPhrase('lrp_view.options.crosshair_color'),
			red = 'cl_lrp_view_crosshair_color_r',
			green = 'cl_lrp_view_crosshair_color_g', 
			blue = 'cl_lrp_view_crosshair_color_b'
		})

		local viewMod = pnl:AddControl('listbox', {label = language.GetPhrase('lrp_view.options.mod_title')})
		viewMod:SetSortItems(false)

		viewMod:AddOption(language.GetPhrase('lrp_view.options.mod_disabled'), {
			cl_lrp_view_mod = 0
		})
        
		for id, data in pairs(lrpView.mods) do
			viewMod:AddOption(data.name, {
				cl_lrp_view_mod = id
			})
		end
    end)

end)