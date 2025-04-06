local function addMenuOption(menu, text, icon, func)
    local option = menu:AddOption(text, func)
    option:SetIcon(icon)
    return option
end

local function addSubMenu(menu, text, icon)
    local subMenu, subMenuIcon = menu:AddSubMenu(text)
    subMenuIcon:SetIcon(icon)
    return subMenu
end

function LRPDerma(pl)
    local lrpDerma = DermaMenu()
    local localPlayer = LocalPlayer()

    addMenuOption(lrpDerma, pl:GetName() .. " (" .. pl:GetUserGroup() .. ")", "icon16/user.png", function()
        pl:ShowProfile()
    end)

    addMenuOption(lrpDerma, "Скопировать SteamID", "icon16/information.png", function() 
        SetClipboardText(pl:SteamID()) 
    end)

    if localPlayer:IsAdmin() then
        lrpDerma:AddSpacer()
        local adminSection = addSubMenu(lrpDerma, "Администрирование", "icon16/shield.png")
        local moderation = addSubMenu(adminSection, "Модерация", "icon16/error.png")
        addMenuOption(moderation, "Кикнуть", "icon16/user_delete.png", function() 
            net.Start("kickuser") 
            net.WriteEntity(pl) 
            net.SendToServer() 
        end)
        
        local banMenu = addSubMenu(moderation, "Забанить", "icon16/delete.png")
        addMenuOption(banMenu, "5 Минут", "icon16/time.png", net.SendCommand("5m", pl))
        addMenuOption(banMenu, "15 Минут", "icon16/time.png", net.SendCommand("15m", pl))
        local teleportMenu = addSubMenu(adminSection, "Телепортация", "icon16/arrow_switch.png")
        addMenuOption(teleportMenu, "К игроку", "icon16/arrow_merge.png", net.SendCommand("teleport_to", pl))
        addMenuOption(teleportMenu, "К точке прицела", "icon16/map_go.png", net.SendCommand("teleport_to_point", pl))
        local stateMenu = addSubMenu(adminSection, "Состояние", "icon16/status_online.png")
        if pl:IsFrozen() then
            addMenuOption(stateMenu, "Разморозить", "icon16/lock_open.png", net.SendCommand("unfreeze", pl))
        else
            addMenuOption(stateMenu, "Заморозить", "icon16/lock.png", net.SendCommand("freeze", pl))
        end
        if pl:IsOnFire() then
            addMenuOption(stateMenu, "Потушить", "icon16/weather_rain.png", net.SendCommand("unignite", pl))
        else
            local igniteSub = addSubMenu(stateMenu, "Поджечь", "icon16/weather_sun.png")
            addMenuOption(igniteSub, "5 Секунд", "icon16/time.png", net.SendCommand("5sec", pl))
            addMenuOption(igniteSub, "10 Секунд", "icon16/time.png", net.SendCommand("10sec", pl))
        end
        local healthSub = addSubMenu(stateMenu, "Здоровье", "icon16/heart.png")
        for _, hp in ipairs({5, 25, 50, 100}) do
            addMenuOption(healthSub, hp .. " HP", "icon16/heart_add.png", net.SendCommand(tostring(hp).."hp", pl))
        end
        local armorSub = addSubMenu(stateMenu, "Броня", "icon16/shield.png")
        for _, ar in ipairs({0, 25, 50, 100}) do
            addMenuOption(armorSub, ar .. " AR", "icon16/shield_add.png", net.SendCommand(tostring(ar).."ar", pl))
        end
        local deathSub = addSubMenu(stateMenu, "Убийство", "icon16/user_red.png")
        addMenuOption(deathSub, "Обычное", "icon16/heart_delete.png", net.SendCommand("kill", pl))
        addMenuOption(deathSub, "Тиxое", "icon16/heart_delete.png", net.SendCommand("silkill", pl))

        addMenuOption(stateMenu, "Возродить", "icon16/arrow_refresh.png", net.SendCommand("resp", pl))

        adminSection:AddSpacer()
    end

    lrpDerma:Open()
end

function net.SendCommand(cmd, target)
    return function()
        net.Start(cmd)
        net.WriteEntity(target)
        net.SendToServer()
    end
end
