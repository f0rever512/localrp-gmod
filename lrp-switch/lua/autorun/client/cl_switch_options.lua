hook.Add('AddToolMenuTabs', 'switchDelay.tab', function()
	spawnmenu.AddToolTab('LocalRP', 'LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption('LocalRP', 'Client Options', 'cl_switchDelay', 'Switch Delay', nil, nil, function(pnl)
		pnl:ClearControls()

		pnl:AddControl('Label', {text = language.GetPhrase('lrp_switch.options.label_cl')})
		pnl:AddControl('CheckBox', {
			label = language.GetPhrase('lrp_switch.options.silent'),
			command = 'cl_lrp_silent_switch'
		})
	end)

	spawnmenu.AddToolMenuOption('LocalRP', 'Server Options', 'sv_switchDelay', 'Switch Delay', nil, nil, function(pnl)
		pnl:ClearControls()

		pnl:AddControl('Label', {text = language.GetPhrase('lrp_switch.options.label_sv')})
		pnl:AddControl('CheckBox', {
			label = language.GetPhrase('lrp_switch.options.block'),
			command = 'sv_lrp_switch_block'
		})
	end)
end)