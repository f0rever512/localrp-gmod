CreateClientConVar("lrp_overhead", "1", true, true)

if SERVER then
	RunConsoleCommand('mp_show_voice_icons', '0')

	util.AddNetworkString('TalkIconChat')

	net.Receive('TalkIconChat', function(_, ply)
		local bool = net.ReadBool()
		ply:SetNW2Bool('ti_istyping', (bool ~= nil) and bool or false)
	end)
else
	surface.CreateFont("OverheadFont", {
        font = "Calibri",
        size = 30,
        weight = 400,
        antialias = true,
        shadow = true,
        extended = true,
    })
    
	hook.Add("PostPlayerDraw", "Overhead", function(ply)
		if GetConVarNumber("lrp_overhead") < 1 then return end
        if LocalPlayer():GetShootPos():Distance(LocalPlayer():GetEyeTrace().HitPos) > 350 then return end
        if ply == LocalPlayer() and GetViewEntity() == LocalPlayer() and not ply:ShouldDrawLocalPlayer() then return end
        if not ply:Alive() then return end
        if !IsValid(ply) then return end
        if (ply == LocalPlayer()) then return end
        
        local angle = EyeAngles()

        angle = Angle( 0, angle.y, 0 )
        angle:RotateAroundAxis( angle:Up(), -90 )
        angle:RotateAroundAxis( angle:Forward(), 90 )

        local trace = LocalPlayer():GetEyeTrace()

        local pos = ply:GetPos() + Vector(0, 0, ply:GetModelRadius() + 15)

        local attachment = ply:GetAttachment(ply:LookupAttachment('eyes'))
        if attachment then
            pos = ply:GetAttachment(ply:LookupAttachment('eyes')).Pos + Vector(0, 0, 9)
        end

        cam.Start3D2D( pos, angle, 0.1 )
            draw.SimpleTextOutlined(ply:Nick(), "OverheadFont", 0, -15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, 0, 1, Color( 0, 0, 0, 255 ) )

            local minus = -15
            draw.RoundedBox(15, -76 , 0-minus, 150, 10, Color(22, 160, 133, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            if ply:Health() <= 100 then
                draw.RoundedBox(15, -75, 1-minus, math.Clamp(ply:Health() or 0, 0, 180)*1.48, 8, Color(200, 0, 0, 225), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.RoundedBox(15, -75, 1-minus, math.Clamp(ply:Armor() or 0, 0, 180)*1.48, 8, Color(0, 70, 160, 215), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.RoundedBox(15, -75, 1-minus, 148, 8, Color(189, 0, 0,255))
                draw.RoundedBox(15, -75, 1-minus, 148, 8, Color(0, 70, 160, 215))
            end
        cam.End3D2D()
    end)

	local voice_mat = Material('talkicon/voice.png')
	local text_mat = Material('talkicon/text.png')

	hook.Add('PostPlayerDraw', 'TalkIcon', function(ply)
        if GetConVarNumber("lrp_overhead") < 1 then return end
        if LocalPlayer():GetShootPos():Distance(LocalPlayer():GetEyeTrace().HitPos) > 350 then return end
        if ply == LocalPlayer() and GetViewEntity() == LocalPlayer() and not ply:ShouldDrawLocalPlayer() then return end
        if not ply:Alive() then return end
        if !IsValid(ply) then return end
        if (ply == LocalPlayer()) then return end

		if not ply:IsSpeaking() and not ply:GetNW2Bool('ti_istyping') then return end

		local pos = ply:GetPos() + Vector(0, 0, ply:GetModelRadius() + 15)

		local attachment = ply:GetAttachment(ply:LookupAttachment('eyes'))
		if attachment then
			pos = ply:GetAttachment(ply:LookupAttachment('eyes')).Pos + Vector(0, 0, 13)
		end

		render.SetMaterial(ply:IsSpeaking() and voice_mat or text_mat)

		render.DrawSprite(pos, 5, 5, Color(22, 160, 133, 255))
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
end