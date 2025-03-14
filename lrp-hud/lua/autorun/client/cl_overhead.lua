CreateClientConVar("cl_lrp_overhead", "1", true, true)

surface.CreateFont('lrpOverhead-font', {
    font = "Calibri",
    size = 64,
    weight = 400,
    antialias = true,
    extended = true
})

local width = 320
local height = 24
local posY = 32
local offset = 4

local voiceMat = Material('talkicon/voice.png')
local textMat = Material('talkicon/text.png')

hook.Add("PostPlayerDraw", 'lrpOverhead.draw', function(ply)
    if GetConVar('cl_lrp_overhead'):GetInt() < 1 then return end
    if ply:GetPos():DistToSqr(EyePos()) > 400 * 400 then return end
    if ply == LocalPlayer() and GetViewEntity() == LocalPlayer() and not ply:ShouldDrawLocalPlayer() then return end
    if not ply:Alive() or not IsValid(ply) or ply == LocalPlayer() then return end
    
    local eyesAtt = ply:GetAttachment(ply:LookupAttachment('eyes'))
    local pos = eyesAtt and eyesAtt.Pos + Vector(0, 0, 10) or ply:GetPos() + Vector(0, 0, ply:GetModelRadius() + 2)
    local angle = Angle(0, EyeAngles().y, 0)
    angle:RotateAroundAxis(angle:Up(), -90)
    angle:RotateAroundAxis(angle:Forward(), 90)

    cam.Start3D2D( pos, angle, 0.05 )
        draw.SimpleTextOutlined(ply:Nick(), 'lrpOverhead-font', 0, -posY, color_white, TEXT_ALIGN_CENTER, 0, 1, color_black )

        draw.RoundedBox(10, width / -2, posY, width, height, Color(0, 185, 150, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(10, width / -2 + offset / 2, posY + offset / 2, math.Clamp(ply:Health() or 0, 0, 100) * (width - offset) / 100, height - offset, Color(200, 0, 0, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(10, width / -2 + offset / 2, posY + offset / 2, math.Clamp(ply:Armor() or 0, 0, 100) * (width - offset) / 100, height - offset, Color(0, 70, 160, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()

    if ply:IsSpeaking() or ply:GetNW2Bool('ti_istyping') then
        render.SetMaterial(ply:IsSpeaking() and voiceMat or textMat)
        render.DrawSprite(pos + Vector(0, 0, 3), 4.2, 4.2, Color(0, 0, 0, 100))
        render.DrawSprite(pos + Vector(0, 0, 3), 4, 4, Color(0, 185, 150, 240))
    end
end)

hook.Add('StartChat', 'TalkIcon', function(isteam)
    if isteam then return end

    net.Start('TalkIconChat')
        net.WriteBool(true)
    net.SendToServer()
end)

hook.Add('FinishChat', 'TalkIcon', function()
    net.Start('TalkIconChat')
        net.WriteBool(false)
    net.SendToServer()
end)

hook.Add("InitPostEntity", "RemoveChatBubble", function()
    hook.Remove("StartChat", "StartChatIndicator")
    hook.Remove("FinishChat", "EndChatIndicator")

    hook.Remove("PostPlayerDraw", "DarkRP_ChatIndicator")
    hook.Remove("CreateClientsideRagdoll", "DarkRP_ChatIndicator")
    hook.Remove("player_disconnect", "DarkRP_ChatIndicator")
end)