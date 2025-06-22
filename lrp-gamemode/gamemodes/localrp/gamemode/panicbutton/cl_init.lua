local lrp = lrp
local surface = surface
local LocalPlayer = LocalPlayer
local CurTime = CurTime
local table = table
local net = net

local panicTexts = {}
local icon = Material('icon16/exclamation.png')

hook.Add('HUDPaint', 'lrp-panicButton.paint', function()

    local ply = LocalPlayer()
    local plyPos = ply:GetPos()

    for i = #panicTexts, 1, -1 do
        
        local data = panicTexts[i]
        local pos = data.pos

        if (data.time and data.time < CurTime()) or plyPos:DistToSqr(pos) < 400*400 then
            table.remove(panicTexts, i)

            continue
        end

        local name = data.owner
        local scrPos = pos:ToScreen()

        surface.SetDrawColor(color_white)
        surface.SetMaterial(icon)
        surface.DrawTexturedRect(scrPos.x - 8, scrPos.y, 16, 16)

        draw.SimpleTextOutlined(
            name, 'lrp-panicBtn.font',
            scrPos.x + 12, scrPos.y + 6,
            color_white, TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER, 1, color_black
        )

    end

end)

local nextPanic = 0
local delay = 10

local function activatePanicBtn()

    local ply = LocalPlayer()
    local jobs = lrp.getJobTable()
    local plyJob = jobs[ply:Team()]

    if plyJob.gov then
        if nextPanic <= CurTime() then
            if ply:Alive() then
                RunConsoleCommand('say', '/me нажимает кнопку паники')
                timer.Simple(0.5, function()
                    net.Start('lrp-panicButton')
                    net.SendToServer()
                end)
            else
                ply:NotifySound('Кнопку паники нельзя нажать, будучи мертвым', 4, NOTIFY_ERROR)
            end

            nextPanic = CurTime() + delay
        else
            ply:NotifySound('Кнопку паники нельзя нажимать еще ' .. math.ceil(nextPanic - CurTime()) .. ' с.', 4, NOTIFY_ERROR)
        end
    else
        ply:NotifySound('Ваша профессия не может использовать кнопку паники', 4, NOTIFY_ERROR)
    end

end

concommand.Add('lrp_panic_button', activatePanicBtn)

net.Receive('lrp-panicButton', function()

    local ply = LocalPlayer()
    local jobs = lrp.getJobTable()
    local plyJob = jobs[ply:Team()]

    if not plyJob.gov then return end

    local button = net.ReadTable()
    table.insert(panicTexts, button)

    surface.PlaySound('npc/attack_helicopter/aheli_damaged_alarm1.wav')

    chat.AddText(Color(230, 40, 0), button.owner .. ' запрашивает помощь, активируя кнопку паники')

end)

concommand.Add('lrp_panic_button_clear', function()
    panicTexts = {}
end)