local lrp = localrp

local function addOption(parent, text, icon, func)
	local option = parent:AddOption(text, func)

	option:SetIcon(icon)
	return option
end

local function addSubMenu(parent, text, icon)
	local subMenu, subMenuIcon = parent:AddSubMenu(text)

	subMenuIcon:SetIcon(icon)
	return subMenu
end

local nextRagdoll = 0
local switchVarExist, switchConVar = ConVarExists('cl_lrp_silent_switch'), GetConVar('cl_lrp_silent_switch')
local chVarExist, chConVar = ConVarExists('cl_lrp_view_crosshair'), GetConVar('cl_lrp_view_crosshair')

local function actionMenu()

	local menu = vgui.Create('DMenu')
	menu:MakePopup()
	menu:SetAlpha(0)
	menu:AlphaTo(255, 0.25, 0)

	input.SetCursorPos(256, ScrH() * 0.5)

	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()

	local gunSub = addSubMenu(menu, 'Оружие:', 'icon16/gun.png')
	addOption(gunSub, 'Выбросить оружие', 'icon16/arrow_right.png', function()
		RunConsoleCommand('lrp_dropweapon')
	end)

	if IsValid(wep) and (wep:GetMaxClip1() > -1 or wep:GetMaxClip2() > -1) then
		gunSub:AddOption('Проверить магазин', function()
			RunConsoleCommand('say', '/me проверяет магазин')
			timer.Simple(0.5, function()
				notification.AddLegacy('В магазине ' .. wep:Clip1() .. ' патрон, а в запасе ' .. ply:GetAmmoCount(wep:GetPrimaryAmmoType()) .. ' патрон', NOTIFY_GENERIC, 3)
				surface.PlaySound("buttons/lightswitch2.wav")
			end)
		end):SetIcon('icon16/briefcase.png')
	end

	menu:AddOption('Осмотреть себя', function()
		RunConsoleCommand('say', '/me осматривает себя')
		timer.Simple(1, function()
			notification.AddLegacy('У вас ' .. ply:Health() .. ' процентов здоровья', NOTIFY_GENERIC, 3)
			surface.PlaySound("buttons/lightswitch2.wav")
		end)
	end):SetIcon('icon16/heart.png')

	if ply:Armor() > 0 then
		menu:AddOption('Проверить бронежилет', function()
			RunConsoleCommand('say', '/me проверяет бронежилет')
			timer.Simple(1, function()
				notification.AddLegacy('У вас ' .. ply:Armor() .. ' процентов прочности бронежилета', NOTIFY_GENERIC, 3)
				surface.PlaySound("buttons/lightswitch2.wav")
			end)
		end):SetIcon('icon16/shield.png')
	end

	local jobs = lrp.getJobTable()
	local plyJob = jobs[ply:Team()]

	if plyJob.gov then
		addOption(menu, 'Активировать кнопку паники', 'icon16/exclamation.png', function()
			RunConsoleCommand('lrp_panic_button')
		end)
	end

	if switchVarExist then
		addOption(
			menu,
			switchConVar:GetBool() and 'Выкл. тихую смену оружия' or 'Вкл. тихую смену оружия',
			switchConVar:GetBool() and 'icon16/cog_delete.png' or 'icon16/cog_add.png',
			function()
				switchConVar:SetBool(not switchConVar:GetBool())
				ply:NotifySound(switchConVar:GetBool() and 'Тихая смена оружия выключена' or 'Тихая смена оружия включена', 3)
			end
		)
	end

	if ply:GetRagdoll() then
		menu:AddOption('Встать', function()
			if CurTime() >= nextRagdoll then
				net.Start('lrp-ragdoll')
				net.WriteBool(false)
				net.SendToServer()
				nextRagdoll = CurTime() + 4
			else
				notification.AddLegacy('Встать нельзя еще ' .. math.Round(nextRagdoll - CurTime()) .. ' с.', NOTIFY_ERROR, 3)
				surface.PlaySound('buttons/lightswitch2.wav')
			end
		end):SetIcon('icon16/arrow_up.png')
	else
		menu:AddOption('Упасть', function()
			if CurTime() >= nextRagdoll then
				net.Start('lrp-ragdoll')
				net.WriteBool(true)
				net.SendToServer()
				nextRagdoll = CurTime() + 4
			else
				notification.AddLegacy('Лечь нельзя еще ' .. math.Round(nextRagdoll - CurTime()) .. ' с.', NOTIFY_ERROR, 3)
				surface.PlaySound('buttons/lightswitch2.wav')
			end
		end):SetIcon('icon16/arrow_down.png')
	end

	menu:AddSpacer()

	local actSub, act = menu:AddSubMenu('Действия:')
	act:SetIcon('icon16/user_orange.png')

	local animSub, anim = menu:AddSubMenu('Анимации:')
	anim:SetIcon('icon16/user_green.png')

	local function addActOption(name, text, icon)
		actSub:AddOption(text, function()
			ply:ConCommand('act ' .. name)
		end):SetIcon('icon16/' .. icon .. '.png')
	end

	local function addAnimOption(name, text, icon, time)
		animSub:AddOption(text, function()
			ply:ConCommand('act ' .. name)
			net.Start('lrp-act')
			net.WriteInt(time, 5)
			net.SendToServer()
		end):SetIcon('icon16/' .. icon .. '.png')
	end

	addActOption('agree', 'Поддержать', 'thumb_up')
	addActOption('becon', 'Подозвать', 'bell')
	addActOption('bow', 'Представиться', 'group')
	addActOption('disagree', 'Пригрозить', 'thumb_down')
	addActOption('forward', 'Сигнал: вперед', 'exclamation')
	addActOption('group', 'Сигнал: группировка', 'exclamation')
	addActOption('halt', 'Сигнал: cтоп', 'exclamation')
	addActOption('salute', 'Воинское приветствие', 'award_star_gold_1')
	addActOption('wave', 'Помахать рукой', 'information')

	addAnimOption('cheer', 'Радоваться', 'emoticon_smile', 2.75)
	addAnimOption('dance', 'Танцевать', 'group', 9)
	addAnimOption('laugh', 'Смеяться', 'emoticon_happy', 6)
	addAnimOption('muscle', 'Откровенно танцевать', 'eye', 12.5)
	addAnimOption('pers', 'Напугать', 'emoticon_unhappy', 3)
	addAnimOption('robot', 'Танцевать как робот', 'group', 11)
	addAnimOption('zombie', 'Двигаться как зомби', 'exclamation', 2.8)

	menu:AddSpacer()

	menu:AddOption('Получить шанс', function()
		RunConsoleCommand('say', '/roll')
	end):SetIcon('icon16/sport_8ball.png')

	local nonrpSub, nonrp = menu:AddSubMenu('Неролевые действия:')
	nonrp:SetIcon('icon16/bricks.png')

	nonrpSub:AddOption("Узнать время", function()
		ply:NotifySound('Время в ОС: ' .. os.date('%X'), 5)
	end):SetIcon('icon16/time.png')

	addOption(nonrpSub, 'Очистить все кнопки паники', 'icon16/bin.png', function()
		RunConsoleCommand('lrp_panic_button_clear')
	end)

	if chVarExist then
		addOption(
			nonrpSub,
			chConVar:GetBool() and 'Выключить прицел' or 'Включить прицел',
			chConVar:GetBool() and 'icon16/cancel.png' or 'icon16/accept.png',
			function()
				chConVar:SetBool(not chConVar:GetBool())
				ply:NotifySound(chConVar:GetBool() and 'Прицел выключен' or 'Прицел включен', 3)
			end
		)
	end

	local linkSub = addSubMenu(menu, 'Ссылки LocalRP:', 'icon16/attach.png')

	addOption(linkSub, 'Discord', 'icon16/information.png', function()
		gui.OpenURL('https://discord.gg/33Ut7rwu3x')
	end)

	addOption(linkSub, 'Коллекция в Steam', 'icon16/information.png', function()
		gui.OpenURL('https://steamcommunity.com/sharedfiles/filedetails/?id=2837278729')
	end)

	addOption(linkSub, 'Поддержать LocalRP', 'icon16/information.png', function()
		gui.OpenURL('https://yoomoney.ru/to/4100118775242744')
	end)

	timer.Simple(0.01, function()
		if not IsValid(menu) then return end

		local y = ( ScrH() - menu:GetTall() ) * 0.5
		menu:SetPos(0, y)
		menu:MoveTo(8, y, 0.2, 0, 1)
	end)

end

hook.Add('OnContextMenuOpen', 'lrp-gamemode.actionMenu.open', function()

	local ply = LocalPlayer()

	if not ply:Alive() then return false end

	local wep = ply:GetActiveWeapon()

	if wep.Base == 'localrp_gun_base' and wep:GetReady() then return false end

	actionMenu()

end)
