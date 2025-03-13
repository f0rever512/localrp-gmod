CreateClientConVar('cl_lrp_hud_type', '2', true, true)

surface.CreateFont('lrpHud-font', {
	font = "Calibri",
	size = 25,
	weight = 400,
	antialias = true,
	shadow = false,
	extended = true
})

local barW = 236
local animationTime = 0.5
local startHP, startAR = 0, 0
local oldHP, newHP, oldAR, newAR = -1, -1, -1, -1

hook.Add('HUDPaint', 'lrpHud.paint', function()
	local ply = LocalPlayer()
	
	if GetConVar("cl_lrp_hud_type"):GetInt() < 2 then return end
	if not ply:Alive() then return end

	local hp, maxHP = ply:Health(), ply:GetMaxHealth()
	local ar, maxAR = ply:Armor(), ply:GetMaxArmor()

	-- Initialize values if not already done
	if oldHP == -1 then oldHP, newHP = hp, hp end
	if oldAR == -1 then oldAR, newAR = ar, ar end

	-- Smooth health and armor values
	local smoothHP = Lerp((SysTime() - startHP) / animationTime, oldHP, newHP)
	local smoothAR = Lerp((SysTime() - startAR) / animationTime, oldAR, newAR)

	-- Update health values if changed
	if newHP ~= hp then
		if smoothHP ~= hp then newHP = smoothHP end

		oldHP = newHP
		startHP = SysTime()
		newHP = hp
	end

	-- Update armor values if changed
	if newAR ~= ar then
		if smoothAR ~= ar then newAR = smoothAR end
		oldAR = newAR
		startAR = SysTime()
		newAR = ar
	end

	local x = ScrW() * 0.5 - 120
	local y = ScrH() - 30

	draw.RoundedBox(10, x, y, 240, 20, Color(0, 185, 150, 200))
	draw.RoundedBox(10, x + 2, y + 2, ply:Health() <= 100 and (math.max( 0, smoothHP ) / maxHP * barW) or barW, 16, Color(200, 0, 0, 230))
	draw.RoundedBox(10, x + 2, y + 2, ply:Armor() <= 100 and (math.max( 0, smoothAR ) / maxAR * barW) or barW, 16, Color(0, 70, 160, 230))
	
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and (not wep.LRPGuns and GetConVar("lrp_view"):GetInt() == 1) then
		local ammo = wep:Clip1() < 0 and 0 or wep:Clip1()
		local reserve = ply:GetAmmoCount(wep:GetPrimaryAmmoType())

		if ammo > 0 or reserve > 0 then
			draw.SimpleText(ammo..' / '..reserve, 'lrpHud-font', ScrW() / 2, y + 9, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			--draw.SimpleTextOutlined(wep.Instructions, 'lrpHud-font', 10, ScrH() + 50, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,255))
		end
	end
end)

hook.Add('HUDPaint', 'lrpHud.ammoPaint', function()
	local ply = LocalPlayer()
	local handAtt = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))

	if ply:InVehicle() or not ply:Alive() or not handAtt then return end
	if GetConVar("cl_lrp_hud_type"):GetInt() == 1 or GetConVar("lrp_view"):GetInt() == 0 then return end

	local wep = ply:GetActiveWeapon()
	if wep.LRPGuns and wep.DrawAmmo then
		if wep:GetReloading() or ply:KeyDown(IN_WALK) then
			local sightOffsets = {
				default = {2, 2, -0.5},
				revolver = {5, 4.8, -1.1},
				pistol = {5, 4.8, -1.1},
				duel = {5, 4.8, -1.1},
				ar2 = {25, 8.7, -0.3},
				smg = {14, 7.2, -1},
			}

			local offset = sightOffsets[wep.Sight] or sightOffsets.default
			local textPos = (handAtt.Pos + handAtt.Ang:Forward() * offset[1] + handAtt.Ang:Up() * offset[2] + handAtt.Ang:Right() * offset[3]):ToScreen()
			
			local ammo = wep:Clip1()
			local reserve = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
			
			draw.SimpleTextOutlined( ammo, 'lrpHud-font', textPos.x, textPos.y, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255) )
			draw.SimpleTextOutlined( reserve, 'lrpHud-font', textPos.x, textPos.y + 20, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255) )
		end
	end
end)

hook.Add("HUDPaint", "VoiceAndTextIcon", function()
	local ply = LocalPlayer()

	if not ply:Alive() then return end

	local voice_mat = Material('talkicon/voice.png')
	local text_mat = Material('talkicon/text.png')
	
	if ply:IsSpeaking() then
		surface.SetMaterial(voice_mat)
		surface.SetDrawColor( 0, 185, 150, 220 )
		surface.DrawTexturedRect( ScrW() * .5 - 24, ScrH() - 80, 48, 48)
	elseif ply:GetNW2Bool('ti_istyping') then
		surface.SetMaterial(text_mat)
		surface.SetDrawColor( 0, 185, 150, 220 )
		surface.DrawTexturedRect( ScrW() * .5 - 24, ScrH() - 80, 48, 56)
	end
end)

hook.Add('HUDShouldDraw', 'HideElements', function(name)
	if GetConVar('cl_lrp_hud_type'):GetInt() == 1 then return end
    for _, hidden in pairs{'CHudHealth', 'CHudBattery', 'CHudAmmo', 'CHudZoom', 'CHudSuitPower', 'CHudDamageIndicator'} do
        if name == hidden then return false end
    end
end)

hook.Add("PlayerStartVoice", "HideVoicePanel", function() return false end)

local e = 0
hook.Add("PostDrawHUD", "PostEffectsHealth", function() 
	local ply = LocalPlayer()

	local o
	if ply:Alive() then
		o = 1 - math.Clamp((ply:Health() or 0) / ply:GetMaxHealth(), 0, 1)
	else
		o = 1
	end
	local a = (o - e) * (FrameTime() < 1 and FrameTime() or 1)
	if math.abs(a) < 0.01 then
		a = a > 0 and 0.01 or -0.01
	end
	if o - e < 0.01 then
		a = o - e
	end
	e = e + a
	if e ~= 0 then
		local o = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1 - e * .35, --1 - e * .7
			["$pp_colour_colour"] = 1, --1 - e
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}
		DrawColorModify(o)
		local e = (e > 0.5 and (e - 0.5) / 0.5 or 0)
		--DrawBloom(.1, (e ^ (3)) * 1, 6, 6, 1, .25, 1, 1, 1)
		--DrawMotionBlur((1 - (e ^ (.2)) * .8), (e ^ (.2)) * (.8), .01)
	end
	local o = 1
	if e > 0.8 then
		o = 3 --16
	elseif e > .65 then
		o = 2 --15
	elseif e > .5 then
		o = 1 --14
	end
	ply:SetDSP(o)
end)