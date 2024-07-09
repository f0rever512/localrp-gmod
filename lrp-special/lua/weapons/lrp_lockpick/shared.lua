if CLIENT then
    SWEP.PrintName = 'Отмычка'
    SWEP.Slot = 5
    SWEP.SlotPos = 0
    SWEP.DrawAmmo = true
    SWEP.DrawCrosshair = false

    surface.CreateFont('dbg-lockpick.normal', {
        font = 'Calibri',
        extended = true,
        size = 24,
        weight = 350,
    })
end

SWEP.Author = 'Octothorp Team'
SWEP.Instructions = 'ЛКМ - Начать взлом'
SWEP.ViewModelFOV = 60
SWEP.ViewModel = 'models/weapons/custom/v_lockpick.mdl'
SWEP.WorldModel = 'models/weapons/custom/w_lockpick.mdl'
SWEP.UseHands = true
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = 'LocalRP - Special'

SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = 'none'

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = 'none'

SWEP.Active = 'revolver'
SWEP.Stand = 'normal'

function SWEP:SetupDataTables()
    self:NetworkVar('Bool', 0, 'Lockpicking')
end

function SWEP:Initialize()
    self:SetLockpicking(false)
    self:SetHoldType(self.Stand)
end

local function LockpickClear()
    hook.Remove('HUDPaint', 'dbg-lockpick')
    hook.Remove('Think', 'dbg-lockpick')
    hook.Remove('RenderScreenspaceEffects', 'dbg-lockpick')
    hook.Remove('InputMouseApply', 'dbg-lockpick')
    hook.Remove('CreateMove', 'dbg-lockpick')
    hook.Remove('dbg-view.chPaint', 'dbg-lockpick')
    timer.Remove('dbg-lockpick')
end

local function LockpickMenu()
    local instruction = ([[Подними все пины[n]и поверни цилиндр[n][n]Мышь - двигать отмычку[n]ЛКМ - повернуть цилиндр[n]ПКМ - отменить взлом]]):gsub('%[n%]', string.char(10))
    local pinBgColor = Color(150, 150, 150)
    local pinColor = Color(50, 50, 50)

    local pins = {}
    local pin = {}
    local pins = '5' -- pins amount
    local pinTime = pins.time or .75 -- Время падения пина
    local pinWidth = pins.width or 25 -- Толщина пина
    local pinSpace = pins.space or 40 -- Пробелы между пинами

    local lockpick_Border = pins * pinSpace / 2 -- Правая стенка коллизии для отмычки
    local r_lockpickBorder = -lockpick_Border -- Левая стенка коллизии для отмычки
    
    local a = 0
    local nextPush = RealTime()
    local canStart = false

    for pins = 1, pins do
        local o = r_lockpickBorder + (pins - 1) * pinSpace + (pinSpace - pinWidth) / 2 -- Расчитывание положения пинов

        pin[pins] = {
            xmin = o, -- Левый(?) хитбокс пина
            xmax = o + pinWidth, -- Правый хитбокс пина
            time = pins * pinTime, -- Время падения пина
            st = 0, -- Положение пина изначально от нуля до одного
        }
    
        for o = 1, pins do -- Рассчитывание времени скорости падения для каждого пина, их универсальность
            local o = pin[pins]
            local pinDown = pin[math.random(pins)]
            pinDown.time, o.time = o.time, pinDown.time
        end
    end

    local function PaintLockPick(x, y) -- Рисование отмычки
        x, y = math.floor(x), math.floor(y)
        draw.NoTexture()
        surface.SetDrawColor(150, 150, 150)
        surface.DrawRect(x - 1, y, 4, 8)
        surface.DrawPoly({
            { x = x - 1, y = y + 10 },
            { x = x - 1, y = y + 6 },
            { x = x + 201, y = y + 4 },
            { x = x + 201, y = y + 12 },
        })
        surface.DrawRect(x + 200, y, 100, 16)
    end -- Конец рисования отмычки

    hook.Add('HUDPaint', 'dbg-lockpick', function() -- Рисуем пины и их бек-граунд
        local r = pins * pinSpace
        local scrw, scrh = ScrW(), ScrH()
        local t = Color(120, 120, 120, 100) -- Настройки всякие, их нет смысла менять. Используются для рисования менюшки
        local o = (scrw - r) / 2 - 5
        local _ = scrh / 2 - 110
        local T = r + 10
        local k = 190 -- тут конец настроечек

        draw.RoundedBox(8, o, _, T, k, t) -- Рисуем бекграунд замка
        
        local c_x = scrw / 2  -- center_x
        local c_y = scrh / 2 -- center_y

        for i=1, pins do
            local pin = pin[i]
            draw.RoundedBox(4, c_x + pin.xmin, c_y - 100, pinWidth, 150, pinBgColor) -- Рисуем бекграунд пина
            draw.RoundedBox(2, c_x + pin.xmin + 1, c_y - pin.st * 98 - 1, pinWidth - 2, 50, pinColor) -- Рисуем пин
        end

        local e = c_y + 60 -- Позиция для отмычки которая используется в качестве аргумента функции PaintLockPick

        if RealTime() < nextPush then
            e = e - (nextPush - RealTime()) / 0.3 * 16 -- Анимация поднятия и опускания отмычки
        end
        
        PaintLockPick(c_x + a, e) -- Рисование отмычки

        draw.DrawText(instruction, 'dbg-lockpick.normal', c_x + r / 2 + 20, c_y - 95, color_white, TEXT_ALIGN_LEFT) -- Показ текста

    end)

    local curtime = nil
    hook.Add('Think', 'dbg-lockpick', function() -- Опускание пина каждый тик. Довольно важная функция
        for i=1, pins do -- Перебор пинов
            local pin = pin[i]
            if pin.st > 0 then
                local curtime = CurTime() - (curtime or CurTime())
                pin.st = math.Approach(pin.st, 0, curtime / pin.time)
            end
        end
        curtime = CurTime()
    end) -- конец, просто пометка.

    local suspicion = 0
    local xSum, ySum = 0, 0
    timer.Create('dbg-lockpick', 0.5, 0, function()
        if (xSum ~= 0 and ySum == 0) or (xSum == 0 and ySum ~= 0) then
            suspicion = suspicion + 1
        elseif xSum ~= 0 or ySum ~= 0 then
            suspicion = math.max(suspicion - 1, 0)
        end

        if suspicion > 3 then
            timer.Simple(0.3, function()
                LockpickClear()
            end)
            print("dbg-lockpick.exploit")
        end

        xSum, ySum = 0, 0
    end)
    
    local sensitivity = GetConVar('sensitivity'):GetFloat()
    hook.Add('InputMouseApply', 'dbg-lockpick', function(cmdinfo, mouseX, r)
        local ply = LocalPlayer()
        local wep = ply:GetActiveWeapon()
        local pushed = false
        if RealTime() > nextPush and canStart then
            local o = FrameTime() * 7500
            a = math.Clamp(a + mouseX * GetConVar('sensitivity'):GetFloat() / 50, r_lockpickBorder, lockpick_Border)
            if -r / FrameTime() > 3000 then
                local o
                for i=1, pins do
                    local pin = pin[i]
                    if a > pin.xmin and a < pin.xmax then -- Если мышка под нужным пином и попадает в его хитбокс
                        o = pin
                        break
                    end
                end
                if not o then -- Если не смогли взломать дверь
                    net.Start('lrp-break')
                    net.SendToServer()

                    notification.AddLegacy(wep:Clip1() > 1 and 'Отмычка сломалась. Осталось: ' .. wep:Clip1() - 1 or 'Все отмычки сломались', NOTIFY_ERROR, 4)
                    hook.Remove('Think', 'dbg-lockpick')
                    hook.Remove('InputMouseApply', 'dbg-lockpick')

                    timer.Simple(0.3, function()
                        LockpickClear()
                    end)
                else
                    if math.random(1, 2) == 2 then
                        net.Start('lrp-pinlifting')
                        net.SendToServer()
                    end
                    o.st = 1
                end
                nextPush = RealTime() + 0.3
                pushed = true
            end
        end
        if math.abs(suspicion) > 1e-4 then
            xSum = xSum + mouseX
        end
        if math.abs(r) > 1e-4 and not pushed then
            ySum = ySum + r
        end
        cmdinfo:SetMouseX(0)
        cmdinfo:SetMouseY(0)
        return true
    end)

    hook.Add('CreateMove', 'dbg-lockpick', function(cmd)
        local wep = LocalPlayer():GetActiveWeapon()
        if not cmd:KeyDown(IN_ATTACK) then
            timer.Simple(0.1, function()
                canStart = true
            end)
        end
        if cmd:KeyDown(IN_ATTACK) and RealTime() > nextPush and canStart then -- Если человек прокручивает пин
            local lockPicked = true -- По умолчанию наш взлом удался.
            for i=1, pins do -- Перед тем, как сказать что наш взлом удался, давай проверим все пины
                local e = pin[i]
                if e.st <= 0 then -- Если пин снизу
                    lockPicked = false -- (?) Взлом не удался
                    net.Start('lrp-break')
                    net.SendToServer()

                    notification.AddLegacy(wep:Clip1() > 1 and 'Отмычка сломалась. Осталось: ' .. wep:Clip1() - 1 or 'Все отмычки сломались', NOTIFY_ERROR, 4)
                    hook.Remove('Think', 'dbg-lockpick')
                    hook.Remove('InputMouseApply', 'dbg-lockpick')

                    timer.Simple(0.3, function()
                        LockpickClear()
                    end)

                    break -- останавливаем цикл
                end
            end

            if lockPicked then -- Если взлом успешный, то..
                net.Start('lrp-unlock')
                net.SendToServer()
                timer.Simple(0.5, function()
                    LockpickClear()
                end)
            end

            nextPush = RealTime() + 0.3
        end
        cmd:RemoveKey(IN_ATTACK)
        cmd:RemoveKey(IN_USE)
        cmd:ClearMovement()
    end)

    local blurMaterial = Material('pp/blurscreen')
    local blurAmount = 0.8
    hook.Add('RenderScreenspaceEffects', 'dbg-lockpick', function()
        if blurAmount > 0 then
            local tab = {
                ['$pp_colour_addr'] = 0,
                ['$pp_colour_addg'] = 0,
                ['$pp_colour_addb'] = 0,
                ['$pp_colour_mulr'] = 0,
                ['$pp_colour_mulg'] = 0,
                ['$pp_colour_mulb'] = 0,
                ['$pp_colour_brightness'] = -blurAmount * 0.2,
                ['$pp_colour_contrast'] = 1 + 0.5 * blurAmount,
                ['$pp_colour_colour'] = 1 - blurAmount,
            }
            
            DrawColorModify(tab)
            surface.SetDrawColor(255, 255, 255, blurAmount * 255)
            surface.SetMaterial(blurMaterial)
            
            for i = 1, 3 do 
                blurMaterial:SetFloat('$blur', blurAmount * i * 2)
                blurMaterial:Recompute() 
                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRect(-1, -1, ScrW() + 2, ScrH() + 2)
            end
        
            draw.NoTexture()
            surface.SetDrawColor(0, 80, 65, blurAmount * 100)
            surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
        end
    end)
end

if SERVER then
    util.AddNetworkString('lrp-break')
    util.AddNetworkString('lrp-unlock')
    util.AddNetworkString('lrp-openmenu')
    util.AddNetworkString('lrp-pinlifting')
else
    net.Receive('lrp-openmenu', function(_, ply)
        timer.Create('dbg-lockpick', 0.1, 0, function()
            LockpickMenu()
        end)
	end)
end

local canLockpicking = {
    ["prop_door_rotating"] = true,
    ["func_door_rotating"] = true,
    ["gmod_sent_vehicle_fphysics_base"] = true,
}

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.8)

    local owner = self.Owner
    local ent = owner:GetEyeTrace().Entity
    if owner:GetPos():DistToSqr(owner:GetEyeTrace().HitPos) > 5500 or self:Clip1() <= 0 then return end

    if canLockpicking[ent:GetClass()] then
        if not self:GetLockpicking() then
            if SERVER then
                if (ent:GetClass() == 'gmod_sent_vehicle_fphysics_base' and ent:GetIsLocked()) or ent:GetInternalVariable("m_bLocked") then
                    self:SetLockpicking(true)
                    net.Start('lrp-openmenu')
                    net.Send(owner)
                end
            end
        end
    else
        return
    end
end

function SWEP:Think()
    if self:GetLockpicking() then
        self:SetHoldType(self.Active)
    else
        self:SetHoldType(self.Stand)
    end

    net.Receive('lrp-unlock', function()
        self.Owner:SetAnimation(PLAYER_ATTACK1)
        self:EmitSound("doors/door_latch1.wav", 60)
        timer.Simple(0.3, function()
            self:SetLockpicking(false)
        end)

        local ent = self.Owner:GetEyeTrace().Entity
        
        if ent:GetClass() == 'gmod_sent_vehicle_fphysics_base' then
            ent:UnLock()
        else
            ent:Fire("unlock", "", 0)
        end
    end)

    net.Receive('lrp-break', function()
        self.Owner:SetAnimation(PLAYER_ATTACK1)
        self:EmitSound('weapons/crowbar/crowbar_impact' .. math.random(1, 2) .. '.wav', 60)
        timer.Simple(0.3, function()
            if IsValid(self) and self:GetClass() == 'lrp_lockpick' then
                self:SetLockpicking(false)
            end
        end)

        self:SetClip1(self:Clip1() - 1)
        if self:Clip1() <= 0 then
            self.Owner:StripWeapon('lrp_lockpick')
        end
    end)

    net.Receive('lrp-pinlifting', function(_, ply)
        self.Owner:SetAnimation(PLAYER_ATTACK1)
        self:EmitSound('weapons/357/357_reload' .. math.random(1, 4) .. '.wav', 50)
    end)
end

function SWEP:Holster()
    self:SetLockpicking(false)
    self:SetHoldType(self.Stand)
    LockpickClear()
    return true
end

function SWEP:SecondaryAttack()
    if self:GetLockpicking() then
        self:SetLockpicking(false)
        LockpickClear()
    end
end