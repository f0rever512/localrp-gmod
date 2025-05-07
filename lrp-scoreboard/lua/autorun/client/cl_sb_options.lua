hook.Add('AddToolMenuTabs', 'scoreboard.tab', function()
	spawnmenu.AddToolTab('LocalRP', 'LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption("LocalRP", "Client Options", 'cl_lrp_sb', "Scoreboard", "", "", function(pnl)
		pnl:ClearControls()
		
		pnl:AddControl("Label", {Text = language.GetPhrase('lrp_sb.options.label')})

		pnl:AddControl("CheckBox", {
			label = language.GetPhrase('lrp_sb.options.checkbox'),
			command = 'cl_lrp_sb_title',
		})
	end)
end)