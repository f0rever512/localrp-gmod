hook.Add('AddToolMenuTabs', 'lrp-gamemode.toolMenuTab', function()

	spawnmenu.AddToolTab('LocalRP', 'LocalRP', 'icon16/brick.png')

	spawnmenu.AddToolMenuOption('LocalRP', 'Client Options', 'cl_lrp_gamemode', 'Gamemode', nil, nil, function(pnl)
		pnl:Help('Клиентские настройки режима LocalRP')

		pnl:KeyBinder('Кнопка активации рации', 'cl_lrp_radio_key')

		pnl:CheckBox('Надпись "Толкнуть" у прицела', 'lrp_pushtext')
	end)

	spawnmenu.AddToolMenuOption('LocalRP', 'Server Options', 'sv_lrp_gamemode', 'Gamemode', nil, nil, function(pnl)
		pnl:Help('Серверные настройки режима LocalRP')

		pnl:TextEntry('Время возрождения', 'lrp_respawntime')
		pnl:CheckBox('Перелом ноги', 'lrp_legbreak')
		pnl:CheckBox('Урон при утоплении в воде', 'lrp_drowning')

		pnl:CheckBox('Разрешить noclip всем игрокам', 'sbox_noclip')
	end)

end)