hook.Add('AddToolMenuTabs', 'switchDelay.tab', function()
	spawnmenu.AddToolTab('LocalRP', 'LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption('LocalRP', 'Client Options', 'Client LocalRP Switch Weapon', 'Switch Weapon', '', '', function(pnl)
		pnl:ClearControls()

		pnl:AddControl('Label', {Text = 'Клиентские настройки смены оружия'})
		pnl:AddControl('CheckBox', {Label = 'Бесшумная смена оружия', Command = 'lrp_silentswitch'})
	end)

	spawnmenu.AddToolMenuOption('LocalRP', 'Server Options', 'Server LocalRP Switch Weapon', 'Switch Weapon', '', '', function(pnl)
		pnl:ClearControls()

		pnl:AddControl('Label', {Text = 'Серверные настройки смены оружия'})
		pnl:AddControl('CheckBox', {Label = 'Бесшумная смена оружия', Command = 'lrp_silentswitch'})
		pnl:AddControl('CheckBox', {Label = 'Запрет Half-Life 2 оружий', Command = 'lrp_silentswitch'})
	end)
end)