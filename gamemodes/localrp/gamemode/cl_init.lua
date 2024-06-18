include('shared.lua')

local function includeFiles(folder) -- by nsfw (https://steamcommunity.com/id/NsfwS)
    local files, folders = file.Find(folder .. "/*", "LUA")
    
    for _, f in ipairs(files) do
        local fullPath = folder .. "/" .. f
        if string.StartWith(f, "cl_") or string.StartWith(f, 'sh') then
            include(fullPath)
        end
    end

    for _, f in ipairs(folders) do
        includeFiles(folder .. "/" .. f)
    end
end

includeFiles('localrp/gamemode/core')
includeFiles('localrp/gamemode/damage')
includeFiles("localrp/gamemode/other")
includeFiles('localrp/gamemode/vgui')
includeFiles("localrp/gamemode/voicechat")

function GM:Initialize()
	MsgN('LocalRP Gamemode initialized on client')
end

hook.Add("AddToolMenuTabs", "LRPGamemode", function()
	spawnmenu.AddToolTab('LocalRP', '#LocalRP', 'icon16/brick.png')
	spawnmenu.AddToolMenuOption("LocalRP", "Client Options", "Client LocalRP Gamemode", "Gamemode", "", "", function(pnl)
		pnl:ClearControls()
		pnl:AddControl('label', {Text = "Клиентские настройки режима LocalRP"})
		pnl:AddControl('checkbox', {Label = "Надпись 'Толкнуть' у прицела", Command = 'lrp_pushtext'})
	end)
	spawnmenu.AddToolMenuOption("LocalRP", "Server Options", "Server LocalRP Gamemode", "Gamemode", "", "", function(pnl)
		pnl:ClearControls()
		pnl:AddControl('label', {Text = "Серверные настройки режима LocalRP"})
		pnl:AddControl('textbox', {Label = 'Время возрождения', Command = 'lrp_respawntime'})
		pnl:AddControl("slider", {
			label = 'Класс игроков',
			command = 'lrp_class',
			min = 0,
			max = 4
		})
		pnl:AddControl('label', {Text = '0 - Гражданин | 1 - Бездомный | 2 - Офицер полиции | 3 - Детектив | 4 - Оперативник спецназа'})
		pnl:AddControl('checkbox', {Label = 'Перелом ноги', Command = 'lrp_legbreak'})
		pnl:AddControl('checkbox', {Label = 'Урон при утоплении в воде', Command = 'lrp_drowning'})
	end)
end)