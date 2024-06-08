CreateClientConVar("hud_type", "2", true, true)

surface.CreateFont( "lrp-hud-font", {
	font = "Calibri",
	size = 25,
	weight = 400,
	antialias = true,
	shadow = false,
	extended = true
})

hook.Add('HUDShouldDraw', 'HUDHide', function(name)
	if GetConVarNumber("hud_type") == 1 then return end
    for k, v in pairs{'CHudHealth', 'CHudBattery', 'CHudAmmo', 'CHudZoom', 'CHudSuitPower', 'CHudDamageIndicator'} do
        if name == v then return false end
    end
end)

local barW = 236
local animationTime = 0.5
local starthp, startar = 0, 0
local oldhp, newhp, oldar, newar = -1, -1, -1, -1

hook.Add('HUDPaint', 'LRPHud', function()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	local x = ScrW() * .5 - 120
	local y = ScrH() - 30

	if GetConVarNumber("hud_type") < 2 then return end
	if not ply:Alive() then return end

	--HEALTH
	local hp = LocalPlayer():Health()
	local maxhp = LocalPlayer():GetMaxHealth()

	-- The values are not initialized yet, do so right now
	if ( oldhp == -1 and newhp == -1 ) then
		oldhp = hp
		newhp = hp
	end

	-- You can use a different smoothing function here
	local smoothHP = Lerp( ( SysTime() - starthp ) / animationTime, oldhp, newhp )

	-- Health was changed, initialize the animation
	if newhp ~= hp then
		-- Old animation is still in progress, adjust
		if ( smoothHP ~= hp ) then
			-- Pretend our current "smooth" position was the target so the animation will
			-- not jump to the old target and start to the new target from there
			newhp = smoothHP
		end

		oldhp = newhp
		starthp = SysTime()
		newhp = hp
	end

	--ARMOR
	local ar = LocalPlayer():Armor()
	local maxar = LocalPlayer():GetMaxArmor()

	if ( oldar == -1 and newar == -1 ) then
		oldar = ar
		newar = ar
	end

	local smoothar = Lerp( ( SysTime() - startar ) / animationTime, oldar, newar )

	if newar ~= ar then
		if ( smoothar ~= ar ) then
			newar = smoothar
		end

		oldar = newar
		startar = SysTime()
		newar = ar
	end

	draw.RoundedBox(10, x, y, 240, 20, Color(0, 185, 150, 200))

	if ply:Health() <= 100 then
		draw.RoundedBox(10, x + 2, y + 2, math.max( 0, smoothHP ) / maxhp * barW, 16, Color(200, 0, 0, 230))
	else
		draw.RoundedBox(10, x + 2, y + 2, 236, 16, Color(200, 0, 0, 230))
	end

	if ply:Armor() <= 100 then
		draw.RoundedBox(10, x + 2, y + 2, math.max( 0, smoothar ) / maxar * barW, 16, Color(0, 70, 160, 230))
	else
		draw.RoundedBox(10, x + 2, y + 2, 236, 16, Color(0, 70, 160, 230))
	end

	if !IsValid(wep) then return end
	if wep:Clip1() == NULL or wep == "Camera" then return end
	local ammo, reserve = wep:Clip1() < 0 and 0 or wep:Clip1(), ply:GetAmmoCount(wep:GetPrimaryAmmoType())
	local disabled = ammo <= 0 and reserve <= 0 and true or false
	if disabled then return end
	if not wep.LRPGuns or GetConVarNumber("lrp_view") == 0 then
		draw.SimpleText(ammo..'/'..reserve, "lrp-hud-font", ScrW() / 2, y + 9, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	--draw.SimpleTextOutlined(wep.Instructions, "lrp-hud-font", 10, ScrH() + 50, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,255))
end)

hook.Add("HUDPaint", "AmmoCheck", function()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))

	if ply:InVehicle() then return end
	if not ply:Alive() then return end
	if not hand then return end
	if GetConVarNumber("hud_type") == 1 then return end
	if GetConVarNumber("lrp_view") == 0 then return end

	if wep.LRPGuns then
		if (wep:GetReloading() or ply:KeyDown(IN_WALK)) then
			local ammo = wep:Clip1()
			local reserve = ply:GetAmmoCount( wep:GetPrimaryAmmoType() )
			
			local x, y = ScrW() / 2.0, ScrH() / 2.0
			
			if wep.Sight == "revolver" or wep.Sight == "pistol" or wep.Sight == "duel" then
				textpos = (hand.Pos + hand.Ang:Forward() * 5 + hand.Ang:Up() * 4.8 + hand.Ang:Right() * -1.1):ToScreen()
			elseif wep.Sight == "ar2" then
				textpos = (hand.Pos + hand.Ang:Forward() * 25 + hand.Ang:Up() * 8.7 + hand.Ang:Right() * -0.3):ToScreen()
			elseif wep.Sight == "smg" then
				textpos = (hand.Pos + hand.Ang:Forward() * 14 + hand.Ang:Up() * 7.2 + hand.Ang:Right() * -1):ToScreen()
			end
			
			--draw.DrawText( "Патроны: " .. ammo, "lrp-hud-font", textpos.x, textpos.y, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			--draw.DrawText( "Запас: " .. reserve, "lrp-hud-font", textpos.x, textpos.y + 25, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			draw.SimpleTextOutlined( ammo, "lrp-hud-font", textpos.x, textpos.y, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255) )
			draw.SimpleTextOutlined( reserve, "lrp-hud-font", textpos.x, textpos.y + 20, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255) )
		end
	end
end)

hook.Add("HUDPaint", "VoiceAndTextIcon", function()
	local ply = LocalPlayer()

	--if GetConVarNumber("hud_type") < 2 then return end
	if !ply:Alive() then return end

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

hook.Add("PlayerStartVoice", "HideVoicePanel", function()
	return false
end)

local e = 0
hook.Add("PostDrawHUD", "PostEffectsHealth", function() 
	local o
	if LocalPlayer():Alive() then
		o = 1 - math.Clamp((LocalPlayer():Health() or 0) / LocalPlayer():GetMaxHealth(), 0, 1)
	else
		o = 1
	end
	local a = (o - e) * (FrameTime() < 1 and FrameTime() or 1)
	if math.abs(a) < .01 then
		a = a > 0 and .01 or -.01
	end
	if o - e < .01 then
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
		local e = (e > .5 and (e - .5) / .5 or 0)
		--DrawBloom(.1, (e ^ (3)) * 1, 6, 6, 1, .25, 1, 1, 1)
		--DrawMotionBlur((1 - (e ^ (.2)) * .8), (e ^ (.2)) * (.8), .01)
	end
	local o = 1
	if e > .8 then
		o = 3 --16
	elseif e > .65 then
		o = 2 --15
	elseif e > .5 then
		o = 1 --14
	end
	LocalPlayer():SetDSP(o)
end)