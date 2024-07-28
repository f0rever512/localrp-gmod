surface.CreateFont("lrp-panicbutton", {
    font = 'Calibri',
    size = 24,
    weight = 300,
    antialias = true,
    extended = true
})

lrp_jobs = lrp_jobs or {}
local jobs = lrp_jobs -- Кеширование в локальной переменной для ускорения обращения

local Panics = {}
local SeenPanics = {}
local icon = Material('icon16/exclamation.png')

local function drawPanicButton(name, pos)
    local data2D = pos:ToScreen()
    surface.SetDrawColor(color_white)
    surface.SetMaterial(icon)
    surface.DrawTexturedRect(data2D.x - 20, data2D.y - 6, 16, 16)
    draw.SimpleTextOutlined(name, 'lrp-panicbutton', data2D.x, data2D.y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
end

local nextOccurance = 0

concommand.Add("panicbutton", function()
    local pl = LocalPlayer()
    local plJob = pl:GetJob()
    if plJob.panicButton then
        local delay = 10
        local timeLeft = nextOccurance - CurTime()
        if timeLeft < 0 then
            if pl:Alive() then
                RunConsoleCommand('say', '/me нажимает кнопку паники')
                timer.Simple(0.5, function()
                    net.Start("PanicButtonConnect")
                    net.SendToServer()
                end)
            else
                notification.AddLegacy('Нельзя нажать кнопку паники, будучи мертвым', NOTIFY_GENERIC, 4)
                surface.PlaySound('buttons/lightswitch2.wav')
            end
            nextOccurance = CurTime() + delay
        else
            notification.AddLegacy('Кнопку паники нельзя нажимать еще ' .. math.Round(timeLeft) .. ' с.', NOTIFY_GENERIC, 4)
            surface.PlaySound('buttons/lightswitch2.wav')
        end
    else
        notification.AddLegacy('Только полицейские могут нажимать кнопку паники', NOTIFY_GENERIC, 4)
        surface.PlaySound("buttons/lightswitch2.wav")
    end
end)

net.Receive("PanicButtonConnect", function()
    local pl = LocalPlayer()
    local plJob = pl:GetJob()
    if not plJob.panicButton then return end

    local button = net.ReadTable()
    table.insert(Panics, button)

    local sound = CreateSound(pl, "npc/attack_helicopter/aheli_damaged_alarm1.wav")
    chat.AddText(Color(230, 30, 30), button[1] .. " запрашивает помощь, нажимая кнопку паники")
    sound:Play()
    timer.Simple(2, function()
        sound:Stop()
    end)
end)

hook.Add("HUDPaint", "PanicButtonPaint", function()
    local pl = LocalPlayer()
    local plPos = pl:GetPos()
    
    for _, panic in ipairs(Panics) do
        local pos = panic[2]

        if SeenPanics[pos] then return end

        drawPanicButton(panic[1], pos)

        if plPos:DistToSqr(pos) >= 400*400 then return end
        SeenPanics[pos] = true
    end
end)