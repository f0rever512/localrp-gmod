include('lrp_rating_menu.lua')

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


local function SendCommand(cmd, target)
    net.Start(cmd)
    net.WriteEntity(target)
    net.SendToServer()
end

function LRPDerma(pl)
    local lrpDerma = DermaMenu()

    addMenuOption(lrpDerma, pl:GetName() .. " (" .. pl:GetUserGroup() .. ")", "icon16/user.png", function()
        if IsValid(pl) then
            pl:ShowProfile()
        end
    end)

    addMenuOption(lrpDerma, "Скопировать SteamID", "icon16/information.png", function() 
        SetClipboardText(pl:SteamID()) 
    end)

    if LocalPlayer():IsAdmin() then
        lrpDerma:AddSpacer()
        addMenuOption(lrpDerma, "Кикнуть", "icon16/user_delete.png", function() SendCommand('kickUser', pl) end)
        local banMenu = addSubMenu(lrpDerma, "Забанить", "icon16/delete.png")
        addMenuOption(banMenu, "5 минут", "icon16/time.png", function() SendCommand('5m', pl) end)
        addMenuOption(banMenu, "15 минут", "icon16/time.png", function() SendCommand('15m', pl) end)

        if pl ~= LocalPlayer() then
            lrpDerma:AddSpacer()
            addMenuOption(lrpDerma, 'К игроку', 'icon16/arrow_right.png', function() SendCommand('goto', pl) end)
            addMenuOption(lrpDerma, 'Игрока к себе', 'icon16/arrow_left.png', function() SendCommand('bring', pl) end)
        end

        lrpDerma:AddSpacer()
        if pl:IsFrozen() then
            addMenuOption(lrpDerma, "Разморозить", "icon16/lock_open.png", function() SendCommand("unfreeze", pl) end)
        else
            addMenuOption(lrpDerma, "Заморозить", "icon16/lock.png", function() SendCommand("freeze", pl) end)
        end
        if pl:IsOnFire() then
            addMenuOption(lrpDerma, "Потушить", "icon16/weather_rain.png", function() SendCommand("unignite", pl) end)
        else
            local igniteSub = addSubMenu(lrpDerma, "Поджечь", "icon16/weather_sun.png")
            addMenuOption(igniteSub, "5 секунд", "icon16/time.png", function() SendCommand("5sec", pl) end)
            addMenuOption(igniteSub, "10 секунд", "icon16/time.png", function() SendCommand("10sec", pl) end)
        end
        local healthSub = addSubMenu(lrpDerma, "Здоровье", "icon16/heart.png")
        for _, hp in ipairs({5, 25, 50, 100}) do
            addMenuOption(healthSub, hp .. " HP", "icon16/heart_add.png", function() SendCommand(tostring(hp).."hp", pl) end)
        end
        local armorSub = addSubMenu(lrpDerma, "Броня", "icon16/shield.png")
        for _, ar in ipairs({0, 25, 50, 100}) do
            addMenuOption(armorSub, ar .. " AR", "icon16/shield_add.png", function() SendCommand(tostring(ar).."ar", pl) end)
        end
        local deathSub = addSubMenu(lrpDerma, "Убийство", "icon16/user_red.png")
        addMenuOption(deathSub, "Обычное", "icon16/heart_delete.png", function() SendCommand("kill", pl) end)
        addMenuOption(deathSub, "Тиxое", "icon16/heart_delete.png", function() SendCommand("silkill", pl) end)

        addMenuOption(lrpDerma, "Возродить", "icon16/arrow_refresh.png", function() SendCommand("resp", pl) end)

        lrpDerma:AddSpacer()
        addMenuOption(lrpDerma, 'Оценить игрока', "icon16/add.png", function()
            ToggleScoreboard(false)
            RatingMenu(pl)
        end)
    end

    lrpDerma:Open()
end