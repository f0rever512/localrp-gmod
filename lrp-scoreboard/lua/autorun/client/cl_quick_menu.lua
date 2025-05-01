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
        local cmdTarget = target:IsBot() and target:Nick() or ('"' .. target:SteamID() .. '"')

        if amount then
            return ply:ConCommand('lrp_admin ' .. cmdName .. ' ' .. cmdTarget .. ' ' .. amount)
        else
            return ply:ConCommand('lrp_admin ' .. cmdName .. ' ' .. cmdTarget)
        end
    end

    local lrpDerma = DermaMenu()

    addMenuOption(lrpDerma, target:GetName() .. " (" .. target:GetUserGroup() .. ")", 'icon16/status_offline.png', function()
        if IsValid(target) then
            target:ShowProfile()
        end
    end)

    addMenuOption(lrpDerma, language.GetPhrase('lrp_sb.quick.copy') .. ' SteamID', "icon16/information.png", function() 
        SetClipboardText('"' .. target:SteamID() .. '"')
    end)

    if ply:IsAdmin() then
        if target ~= ply then
            lrpDerma:AddSpacer()
            addMenuOption(lrpDerma, language.GetPhrase('lrp_sb.quick.goto'), 'icon16/arrow_right.png', function() runCommand('goto') end)
            addMenuOption(lrpDerma, language.GetPhrase('lrp_sb.quick.bring'), 'icon16/arrow_left.png', function() runCommand('bring') end)
        end

        lrpDerma:AddSpacer()
        local healthSub = addSubMenu(lrpDerma, language.GetPhrase('lrp_sb.quick.hp'), "icon16/heart.png")
        for _, hp in ipairs({5, 25, 50, 100}) do
            addMenuOption(healthSub, hp .. " HP", "icon16/heart_add.png", function() runCommand('hp', hp) end)
        end
        addMenuOption(healthSub, language.GetPhrase('lrp_sb.quick.choose'), 'icon16/heart_add.png', function()
            InputMenu(
                language.GetPhrase('lrp_sb.input.hp.title'), 
                string.format(language.GetPhrase('lrp_sb.input.hp.subtitle'), target:Nick()),
                '',
                function(text) runCommand('hp', tonumber(text)) end
            )
        end)

        local armorSub = addSubMenu(lrpDerma, language.GetPhrase('lrp_sb.quick.ar'), "icon16/shield.png")
        for _, ar in ipairs({0, 25, 50, 100}) do
            addMenuOption(armorSub, ar .. " AR", "icon16/shield_add.png", function() runCommand('ar', ar) end)
        end
        addMenuOption(armorSub, language.GetPhrase('lrp_sb.quick.choose'), 'icon16/shield_add.png', function()
            InputMenu(
                language.GetPhrase('lrp_sb.input.ar.title'), 
                string.format(language.GetPhrase('lrp_sb.input.ar.subtitle'), target:Nick()),
                '',
                function(text) runCommand('ar', tonumber(text)) end
            )
        end)

        local deathSub = addSubMenu(lrpDerma, language.GetPhrase('lrp_sb.quick.kill'), "icon16/user_red.png")
        addMenuOption(deathSub, language.GetPhrase('lrp_sb.quick.kill_normal'), "icon16/heart_delete.png", function() runCommand('kill') end)
        addMenuOption(deathSub, language.GetPhrase('lrp_sb.quick.kill_silent'), "icon16/heart_delete.png", function() runCommand('killsilent') end)
        
        addMenuOption(lrpDerma, language.GetPhrase('lrp_sb.quick.respawn'), "icon16/arrow_refresh.png", function() runCommand('respawn') end)

        lrpDerma:AddSpacer()
        if target:IsFrozen() then
            addMenuOption(lrpDerma, language.GetPhrase('lrp_sb.quick.unfreeze'), 'icon16/lock_add.png', function() runCommand('unfreeze') end)
        else
            addMenuOption(lrpDerma, language.GetPhrase('lrp_sb.quick.freeze'), 'icon16/lock_delete.png', function() runCommand('freeze') end)
        end
        if target:IsOnFire() then
            addMenuOption(lrpDerma, language.GetPhrase('lrp_sb.quick.unignite'), "icon16/weather_rain.png", function() runCommand('unignite') end)
        else
            local igniteSub = addSubMenu(lrpDerma, language.GetPhrase('lrp_sb.quick.ignite'), "icon16/weather_sun.png")
            addMenuOption(igniteSub, '5 ' .. language.GetPhrase('lrp_sb.quick.seconds'), "icon16/time.png", function() runCommand('ignite', 5) end)
            addMenuOption(igniteSub, '10 ' .. language.GetPhrase('lrp_sb.quick.seconds'), "icon16/time.png", function() runCommand('ignite', 10) end)
            addMenuOption(igniteSub, language.GetPhrase('lrp_sb.quick.choose'), 'icon16/time_add.png', function()
                InputMenu(
                    language.GetPhrase('lrp_sb.input.ignite.title'), 
                    string.format(language.GetPhrase('lrp_sb.input.ignite.subtitle'), target:Nick()),
                    '',
                    function(text) runCommand('ignite', tonumber(text)) end
                )
            end)
        end

        if target ~= ply then
            addMenuOption(lrpDerma, language.GetPhrase('lrp_sb.quick.message'), 'icon16/wand.png', function() runCommand('message') end)

            lrpDerma:AddSpacer()
            addMenuOption(lrpDerma, language.GetPhrase('lrp_sb.quick.kick'), "icon16/user_delete.png", function() runCommand('kick') end)
            local banMenu = addSubMenu(lrpDerma, language.GetPhrase('lrp_sb.quick.ban'), "icon16/delete.png")
            addMenuOption(banMenu, '5 ' .. language.GetPhrase('lrp_sb.quick.minutes'), "icon16/time.png", function() runCommand('ban', 5) end)
            addMenuOption(banMenu, '15 ' .. language.GetPhrase('lrp_sb.quick.minutes'), "icon16/time.png", function() runCommand('ban', 15) end)
            addMenuOption(banMenu, language.GetPhrase('lrp_sb.quick.permanent'), 'icon16/time.png', function() runCommand('ban', 0) end)
            addMenuOption(banMenu, language.GetPhrase('lrp_sb.quick.choose'), 'icon16/time_add.png', function()
                InputMenu(
                    language.GetPhrase('lrp_sb.input.ban.title'), 
                    string.format(language.GetPhrase('lrp_sb.input.ban.subtitle'), target:Nick()),
                    '',
                    function(text) runCommand('ban', tonumber(text)) end
                )
            end)
        end
    end

    lrpDerma:Open()
end