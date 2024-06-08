hook.Add("AddToolMenuTabs", "LRPChatbox", function()
	spawnmenu.AddToolTab('LocalRP', '#LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption("LocalRP", "Client Options", "LocalRP Chatbox", "Chatbox", "", "", function(pnl)
		pnl:ClearControls()

		pnl:AddControl("Label", {Text = "Настройки чата"})

		pnl:AddControl("slider", {
			label = "Ширина",
			command = "lrp_chatsize_w",
			min = 10,
			max = 90,
			decimals = 0
		})
		
		pnl:AddControl("slider", {
			label = "Высота",
			command = "lrp_chatsize_h",
			min = 10,
			max = 50,
			decimals = 0
		})

		pnl:AddControl("CheckBox", {Label = "Заголовок LocalRP", Command = "lrp_chattitle"})

		pnl:AddControl("Button", {Label = "Обновить чат", Command = "lrp_updatechat"})

		pnl:AddControl("Button", {Label = "Сбросить настройки", Command = "lrp_defaultchat"})
	end)
end)