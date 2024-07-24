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

        addMenuOption(lrpDerma, "Кикнуть", "icon16/user_delete.png", function() 
            net.Start("kickuser") 
            net.WriteEntity(pl) 
            net.SendToServer() 
        end)

        local banUser = addSubMenu(lrpDerma, "Забанить", "icon16/delete.png")
        addMenuOption(banUser, "5 Минут", "icon16/time.png", function() 
            net.Start("5m") 
            net.WriteEntity(pl) 
            net.SendToServer() 
        end)
        addMenuOption(banUser, "15 Минут", "icon16/time.png", function() 
            net.Start("15m") 
            net.WriteEntity(pl) 
            net.SendToServer() 
        end)

        lrpDerma:AddSpacer()

        if not pl:IsFrozen() then
            addMenuOption(lrpDerma, "Заморозить", "icon16/lock.png", function() 
                net.Start("freeze") 
                net.WriteEntity(pl) 
                net.SendToServer() 
            end)
        else
            addMenuOption(lrpDerma, "Разморозить", "icon16/lock_open.png", function() 
                net.Start("unfreeze") 
                net.WriteEntity(pl) 
                net.SendToServer() 
            end)
        end

        if not pl:IsOnFire() then
            local igniteUser = addSubMenu(lrpDerma, "Поджечь", "icon16/weather_sun.png")
            addMenuOption(igniteUser, "5 Секунд", "icon16/time.png", function() 
                net.Start("5sec") 
                net.WriteEntity(pl) 
                net.SendToServer() 
            end)
            addMenuOption(igniteUser, "10 Секунд", "icon16/time.png", function() 
                net.Start("10sec") 
                net.WriteEntity(pl) 
                net.SendToServer() 
            end)
        else
            addMenuOption(lrpDerma, "Потушить", "icon16/weather_rain.png", function() 
                net.Start("unignite") 
                net.WriteEntity(pl) 
                net.SendToServer() 
            end)
        end

        local damageUser = addSubMenu(lrpDerma, "Установить здоровье", "icon16/heart_add.png")
        for _, hp in ipairs({5, 25, 50, 100}) do
            addMenuOption(damageUser, hp .. " HP", "icon16/heart.png", function() 
                net.Start(tostring(hp) .. "hp") 
                net.WriteEntity(pl) 
                net.SendToServer() 
            end)
        end

        local armorUser = addSubMenu(lrpDerma, "Установить броню", "icon16/shield_add.png")
        for _, ar in ipairs({0, 25, 50, 100}) do
            addMenuOption(armorUser, ar .. " AR", "icon16/shield.png", function() 
                net.Start(tostring(ar) .. "ar") 
                net.WriteEntity(pl) 
                net.SendToServer() 
            end)
        end

        -- local setJob = addSubMenu(lrpDerma, 'Установить профессию', "icon16/wrench.png")
        -- for int, job in ipairs({'Гражданин', 'Бездомный', 'Офицер полиции', 'Детектив', 'Оперативник спецназа', 'Медик'}) do
        --     addMenuOption(setJob, job, "icon16/status_offline.png", function()
        --         net.Start('sb-setJob')
        --         net.WriteInt(int, 5)
        --         net.WriteEntity(pl)
        --         net.SendToServer()
        --     end)
        -- end

        local deathUser = addSubMenu(lrpDerma, "Убить", "icon16/user_red.png")
        addMenuOption(deathUser, "Убить", "icon16/heart_delete.png", function() 
            net.Start("kill") 
            net.WriteEntity(pl) 
            net.SendToServer() 
        end)
        addMenuOption(deathUser, "Тихо убить", "icon16/heart_delete.png", function() 
            net.Start("silkill") 
            net.WriteEntity(pl) 
            net.SendToServer() 
        end)

        addMenuOption(lrpDerma, "Возродить", "icon16/arrow_refresh.png", function() 
            net.Start("resp") 
            net.WriteEntity(pl) 
            net.SendToServer() 
        end)

        lrpDerma:AddSpacer()
        addMenuOption(lrpDerma, 'Оценить игрока', "icon16/add.png", function()
            ToggleScoreboard(false)
            RatingMenu(pl)
        end)
    end

    lrpDerma:Open()
end
