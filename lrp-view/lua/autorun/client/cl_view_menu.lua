hook.Add('AddToolMenuTabs', 'lrp-view.toolMenuTab', function()

    spawnmenu.AddToolTab('LocalRP', 'LocalRP', 'icon16/brick.png')

    spawnmenu.AddToolMenuOption('LocalRP', 'Client Options', 'cl_lrp_view', 'View', nil, nil, function(pnl)
        pnl:Help(language.GetPhrase('lrp_view.options.label')) -- Настройки вида от первого лица

        pnl:CheckBox(language.GetPhrase('lrp_view.options.toggle'), 'lrp_view') -- Вид от первого лица

        pnl:CheckBox(language.GetPhrase('lrp_view.options.lock_toggle'), 'cl_lrp_view_lock') -- Блокировка вида

		pnl:NumSlider(language.GetPhrase('lrp_view.options.lock_max'), 'cl_lrp_view_max_lock', 75, 90, 0) -- Максимальная блокировка (смотря вниз)

		pnl:CheckBox(language.GetPhrase('lrp_view.options.crosshair'), 'cl_cl_lrp_view_crosshair') -- Прицел

		pnl:AddControl('Color', {
			label = language.GetPhrase('lrp_view.options.crosshair_color'), -- Цвет прицела
			red = 'cl_lrp_view_crosshair_color_r',
			green = 'cl_lrp_view_crosshair_color_g', 
			blue = 'cl_lrp_view_crosshair_color_b'
		})
    end)

end)