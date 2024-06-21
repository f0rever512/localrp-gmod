local function LRPCMenu()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if not ply:Alive() then return end

    local menu = vgui.Create('DMenu')
    menu:MakePopup()
    menu:SetPos(-180, ScrH() * .44)
    menu:MoveTo(10, ScrH() * .44, 0.2, 0)
    menu:SetAlpha(0)
    menu:AlphaTo(255, 0.3, 0)
    input.SetCursorPos( 250, ScrH() * .5 )

    local gunSub, gun = menu:AddSubMenu( "Оружие:" )
    gun:SetIcon('icon16/gun.png')
    local dropweapon = gunSub:AddOption( 'Выбросить оружие', function()
        RunConsoleCommand('lrp_dropweapon')
    end ):SetIcon('icon16/arrow_right.png')
    
    if IsValid(wep) and wep.LRPGuns then
        local checkammo = gunSub:AddOption( 'Проверить магазин', function()
            RunConsoleCommand('say', '/me проверяет магазин')
            timer.Simple( 0.5, function()
                notification.AddLegacy('В магазине ' .. wep:Clip1() .. ' патрон, а в запасе ' .. wep:Ammo1() .. ' патрон', NOTIFY_GENERIC, 3 )
                surface.PlaySound( "buttons/lightswitch2.wav" )
            end)
        end ):SetIcon('icon16/briefcase.png')
    end

    local checkhp = menu:AddOption( 'Осмотреть себя', function()
        RunConsoleCommand('say', '/me осматривает себя')
        timer.Simple( 1, function()
            notification.AddLegacy('У вас ' .. ply:Health() .. ' процентов здоровья', NOTIFY_GENERIC, 3 )
            surface.PlaySound( "buttons/lightswitch2.wav" )
        end)
    end )
    checkhp:SetIcon('icon16/heart.png')

    if ply:Armor() > 0 then
        local checkhp = menu:AddOption( 'Проверить бронежилет', function()
            RunConsoleCommand('say', '/me проверяет бронежилет')
            timer.Simple( 1, function()
                notification.AddLegacy('У вас ' .. ply:Armor() .. ' процентов прочности бронежилета', NOTIFY_GENERIC, 3 )
                surface.PlaySound( "buttons/lightswitch2.wav" )
            end)
        end )
        checkhp:SetIcon('icon16/shield.png')
    end
    -- local fuck = menu:AddOption( 'Показать фак', function()
    --     RunConsoleCommand('say', '/me показал фак')
    -- end ):SetIcon('icon16/emoticon_wink.png')

    -- anim & act
    menu:AddSpacer()
    local actSub, act = menu:AddSubMenu('Действия:')
    act:SetIcon('icon16/user_orange.png')

    local animSub, anim = menu:AddSubMenu('Анимации:')
    anim:SetIcon('icon16/user_green.png')

    local function act(name, text, icon)
        local name = actSub:AddOption( text, function()
            ply:ConCommand('act ' .. name)
        end ):SetIcon('icon16/' .. icon .. '.png')
    end
    local function anim(name, text, icon, time)
        local name = animSub:AddOption( text, function()
            ply:ConCommand('act ' .. name)
            net.Start('lrp-act')
                net.WriteInt(time, 5)
	        net.SendToServer()
        end ):SetIcon('icon16/' .. icon .. '.png')
    end

    act('agree', 'Поддержать', 'thumb_up')
    act('becon', 'Подозвать', 'bell')
    act('bow', 'Представиться', 'group')
    act('disagree', 'Пригрозить', 'thumb_down')
    act('forward', 'Сигнал: вперед', 'exclamation')
    act('group', 'Сигнал: группировка', 'exclamation')
    act('halt', 'Сигнал: cтоп', 'exclamation')
    act('salute', 'Воинское приветствие', 'award_star_gold_1')
    act('wave', 'Помахать рукой', 'information')

    anim('cheer', 'Радоваться', 'emoticon_smile', 2.75)
    anim('dance', 'Танцевать', 'group', 9)
    anim('laugh', 'Смеяться', 'emoticon_happy', 6)
    anim('muscle', 'Откровенно танцевать', 'eye', 11)
    anim('pers', 'Напугать', 'emoticon_unhappy', 3)
    anim('robot', 'Танцевать как робот', 'group', 11)
    anim('zombie', 'Двигаться как зомби', 'exclamation', 2.75)
    -- nonrp
    menu:AddSpacer()
    local roll = menu:AddOption( 'Получить шанс', function()
        RunConsoleCommand('say', '/roll')
    end )
    roll:SetIcon('icon16/sport_8ball.png')

    local child_nrole, nrole = menu:AddSubMenu('Неролевые действия:')
    nrole:SetIcon('icon16/bricks.png')

    local ostime = child_nrole:AddOption( "Узнать время", function()
        notification.AddLegacy('Время в ОС: ' .. os.date('%X'), NOTIFY_GENERIC, 5 )
        surface.PlaySound( "buttons/lightswitch2.wav" )
    end ):SetIcon('icon16/time.png')

    local lrpsteam = child_nrole:AddOption( 'Сборка LocalRP', function()
        gui.OpenURL('https://steamcommunity.com/sharedfiles/filedetails/?id=2837278729')
    end ):SetIcon('icon16/information.png')
    --options
    menu:AddSpacer()

    if GetConVarNumber('lrp_view_crosshair') == 1 then
        local cross = menu:AddOption( 'Выключить прицел', function() 
            GetConVar( 'lrp_view_crosshair' ):SetInt(0)
            notification.AddLegacy('Прицел выключен', NOTIFY_GENERIC, 3 )
            surface.PlaySound( "buttons/lightswitch2.wav" )
        end )
        cross:SetIcon('icon16/cancel.png')
    else
        local cross = menu:AddOption( 'Включить прицел', function() 
            GetConVar( 'lrp_view_crosshair' ):SetInt(1)
            notification.AddLegacy('Прицел включен', NOTIFY_GENERIC, 3 )
            surface.PlaySound( "buttons/lightswitch2.wav" )
        end )
        cross:SetIcon('icon16/accept.png')
    end
end

hook.Add('OnContextMenuOpen', 'CMenuOpen', function()
    local pl = LocalPlayer()
    local wep = pl:GetActiveWeapon()
    if not pl:Alive() then return false end
    if wep.LRPGuns and wep:GetReady() then return false end
    LRPCMenu()
end)