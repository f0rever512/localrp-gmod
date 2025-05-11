hook.Add('AddToolMenuTabs', 'switchDelay.tab', function()
	spawnmenu.AddToolTab('LocalRP', 'LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption('LocalRP', 'Client Options', 'cl_lrp_switch', 'Switch Delay', nil, nil, function(pnl)
		pnl:ClearControls()

		pnl:AddControl('Label', {text = 'Клиентские настройки смены оружия'})
		pnl:AddControl('CheckBox', {
			label = 'Бесшумная смена оружия',
			command = 'cl_lrp_silent_switch'
		})
	end)

	spawnmenu.AddToolMenuOption('LocalRP', 'Server Options', 'sv_lrp_switch', 'Switch Delay', nil, nil, function(pnl)
		pnl:ClearControls()

		pnl:AddControl('Label', {text = 'Серверные настройки смены оружия'})
		pnl:AddControl('CheckBox', {
			label = 'Запрет Half-Life 2 оружия',
			command = 'sv_lrp_switch_block'
		})
	end)
end)