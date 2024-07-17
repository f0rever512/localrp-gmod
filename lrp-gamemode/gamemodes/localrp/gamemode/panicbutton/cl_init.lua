surface.CreateFont( "lrp-panicbutton", {
	font = 'Calibri',
	size = 24,
	weight = 300,
	antialias = true,
	extended = true
})

local button = {}
local Panics = {}
local SeenPanics = {}
local icon = Material('icon16/exclamation.png')
function drawPanicButton(name, pos)
    local pos = pos
    local data2D = pos:ToScreen()
    surface.SetDrawColor(color_white)
    surface.SetMaterial(icon)
    surface.DrawTexturedRect(data2D.x - 20, data2D.y - 6, 16, 16)
    draw.SimpleTextOutlined(name, 'lrp-panicbutton', data2D.x, data2D.y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black )
end

local nextOccurance = 0

concommand.Add("panicbutton", function()
    local pl = LocalPlayer()
    local team = pl:Team()
    if team == 3 or team == 4 or team == 5 then
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
                notification.AddLegacy('Нельзя нажать кнопку паники, будучи мертвым', NOTIFY_GENERIC , 4)
                surface.PlaySound('buttons/lightswitch2.wav')
            end
            nextOccurance = CurTime() + delay
        else
            notification.AddLegacy('Кнопку паники нельзя нажимать еще ' .. math.Round(timeLeft) .. ' с.', NOTIFY_GENERIC , 4)
            surface.PlaySound('buttons/lightswitch2.wav')
        end
    else
        notification.AddLegacy('Только полицейские могут нажимать кнопку паники', NOTIFY_GENERIC , 4)
        surface.PlaySound("buttons/lightswitch2.wav")
    end
end)

net.Receive("PanicButtonConnect", function()
    local pl = LocalPlayer()
    local team = pl:Team()
    if team ~= 3 and team ~= 4 and team ~= 5 then return end
    button = net.ReadTable()
    Panics[#Panics + 1] = button
    local sound = CreateSound(pl, "npc/attack_helicopter/aheli_damaged_alarm1.wav")
    chat.AddText(Color(230, 30, 30), button[1] .. " запрашивает помощь, нажимая кнопку паники")
    sound:Play()
    timer.Simple(2, function()
        sound:Stop()
    end)

    hook.Add("HUDPaint", "PanicButtonPaint", function()
        for k, v in pairs(Panics) do
            if not table.HasValue(SeenPanics, Panics[k][2]) then
                drawPanicButton(Panics[k][1], Panics[k][2])
                if pl:GetPos():Distance(Panics[k][2]) < 400 then
                    SeenPanics[#SeenPanics + 1] = Panics[k][2]
                end
            end
        end
    end)
end)