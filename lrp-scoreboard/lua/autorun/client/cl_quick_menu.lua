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

local function InputMenu(title, subTitle, defaultText, callback)
    ToggleScoreboard(false)
    Derma_StringRequest(
        title, 
        subTitle,
        defaultText,
        function(text) callback(text) end
    )
end

function LRPDerma(target)
    local ply = LocalPlayer()

    local function runCommand(cmdName, amount)
        if amount then
            return ply:ConCommand('lrp_admin ' .. cmdName .. ' ' .. (target:IsBot() and target:Nick() or target:SteamID()) .. ' ' .. amount)
        else
            return ply:ConCommand('lrp_admin ' .. cmdName .. ' ' .. (target:IsBot() and target:Nick() or target:SteamID()))
        end
    end

    local lrpDerma = DermaMenu()

    addMenuOption(lrpDerma, target:GetName() .. " (" .. target:GetUserGroup() .. ")", 'icon16/status_offline.png', function()
        if IsValid(target) then
            target:ShowProfile()
        end
    end)

    addMenuOption(lrpDerma, "Скопировать SteamID", "icon16/information.png", function() 
        SetClipboardText('"' .. target:SteamID() .. '"')
    end)

    if ply:IsAdmin() then
        if target ~= ply then
            lrpDerma:AddSpacer()
            addMenuOption(lrpDerma, 'К игроку', 'icon16/arrow_right.png', function() runCommand('goto') end)
            addMenuOption(lrpDerma, 'Игрока к себе', 'icon16/arrow_left.png', function() runCommand('bring') end)
        end

        lrpDerma:AddSpacer()
        local healthSub = addSubMenu(lrpDerma, "Здоровье", "icon16/heart.png")
        for _, hp in ipairs({5, 25, 50, 100}) do
            addMenuOption(healthSub, hp .. " HP", "icon16/heart_add.png", function() runCommand('hp', hp) end)
        end
        addMenuOption(healthSub, 'Выбрать', 'icon16/heart_add.png', function()
            InputMenu(
                'Выдача здоровья', 
                'Введите количество здоровья, которое будет выдано игроку ' .. target:Nick(),
                '',
                function(text) runCommand('hp', tonumber(text)) end
            )
        end)

        local armorSub = addSubMenu(lrpDerma, "Броня", "icon16/shield.png")
        for _, ar in ipairs({0, 25, 50, 100}) do
            addMenuOption(armorSub, ar .. " AR", "icon16/shield_add.png", function() runCommand('ar', ar) end)
        end
        addMenuOption(armorSub, 'Выбрать', 'icon16/shield_add.png', function()
            InputMenu(
                'Выдача брони', 
                'Введите количество брони, которое будет выдано игроку ' .. target:Nick(),
                '',
                function(text) runCommand('ar', tonumber(text)) end
            )
        end)

        local deathSub = addSubMenu(lrpDerma, "Убийство", "icon16/user_red.png")
        addMenuOption(deathSub, "Обычное", "icon16/heart_delete.png", function() runCommand('kill') end)
        addMenuOption(deathSub, "Тиxое", "icon16/heart_delete.png", function() runCommand('killsilent') end)
        
        addMenuOption(lrpDerma, "Возродить", "icon16/arrow_refresh.png", function() runCommand('respawn') end)

        lrpDerma:AddSpacer()
        if target:IsFrozen() then
            addMenuOption(lrpDerma, "Разморозить", 'icon16/lock_add.png', function() runCommand('unfreeze') end)
        else
            addMenuOption(lrpDerma, "Заморозить", 'icon16/lock_delete.png', function() runCommand('freeze') end)
        end
        if target:IsOnFire() then
            addMenuOption(lrpDerma, "Потушить", "icon16/weather_rain.png", function() runCommand('unignite') end)
        else
            local igniteSub = addSubMenu(lrpDerma, "Поджечь", "icon16/weather_sun.png")
            addMenuOption(igniteSub, "5 секунд", "icon16/time.png", function() runCommand('ignite', 5) end)
            addMenuOption(igniteSub, "10 секунд", "icon16/time.png", function() runCommand('ignite', 10) end)
            addMenuOption(igniteSub, 'Выбрать', 'icon16/time_add.png', function()
                InputMenu(
                    'Поджёг игрока', 
                    'Введите время (в секундах), на которое игрок ' .. target:Nick() .. ' будет подожжён',
                    '',
                    function(text) runCommand('ignite', tonumber(text)) end
                )
            end)
        end

        if target ~= ply then
            lrpDerma:AddSpacer()
            addMenuOption(lrpDerma, "Кикнуть", "icon16/user_delete.png", function() runCommand('kick') end)
            local banMenu = addSubMenu(lrpDerma, "Забанить", "icon16/delete.png")
            addMenuOption(banMenu, "5 минут", "icon16/time.png", function() runCommand('ban', 5) end)
            addMenuOption(banMenu, "15 минут", "icon16/time.png", function() runCommand('ban', 15) end)
            addMenuOption(banMenu, 'Навсегда', 'icon16/time.png', function() runCommand('ban', 0) end)
            addMenuOption(banMenu, 'Выбрать', 'icon16/time_add.png', function()
                InputMenu(
                    'Выдать бан', 
                    'Введите время (в минутах), на которое игрок ' .. target:Nick() .. ' будет забанен',
                    '',
                    function(text) runCommand('ban', tonumber(text)) end
                )
            end)
        end
    end

    lrpDerma:Open()
end