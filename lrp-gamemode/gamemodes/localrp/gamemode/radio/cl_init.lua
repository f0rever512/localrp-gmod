CreateClientConVar('cl_lrp_radio', '0', true, true, 'Enable / Disable walkie-talkie', 0, 1)
CreateClientConVar('cl_lrp_radio_key', KEY_H, true, false, 'Key to toggle walkie-talkie')

local radioPos = Vector(1.3, 0.7, 1)
local radioAng = Angle(-140, -15, 100)

local function radioToggle(ply, state)
    local wep = ply:GetActiveWeapon()

    if state then
        if IsValid(ply) and not IsValid(ply.RadioModel) and wep:GetClass() ~= 'lrp_radio' and GetConVar('lrp_view'):GetBool() then
            local attID = ply:LookupAttachment('anim_attachment_LH')
            if not attID then return end

            local radioProp = ents.CreateClientProp()
            radioProp:SetModel('models/handfield_radio.mdl')
            radioProp:SetParent(ply, attID)
            radioProp:SetLocalPos(radioPos)
            radioProp:SetLocalAngles(radioAng)
            radioProp:SetSkin(1)
            radioProp:Spawn()

            ply.RadioModel = radioProp
        end
    else
        timer.Simple(0.2, function()
            if IsValid(ply) and IsValid(ply.RadioModel) then
                ply.RadioModel:Remove()
                ply.RadioModel = nil
            end
        end)
    end

    permissions.EnableVoiceChat(state)
    net.Start('lrp-radio.toggle')
        net.WriteBool(state)
    net.SendToServer()
end

local usingRadio = false
local lastButtonDown = 0
local lastButtonUp = 0
local radioCooldown = 0.3

hook.Add('Think', 'lrp-radio.logic', function()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if usingRadio and (not IsValid(ply) or not ply:Alive()
    or (IsValid(wep) and wep.Base == 'localrp_gun_base' and (wep:GetReady() or wep:GetReloading()))) then
        usingRadio = false
        radioToggle(ply, usingRadio)
    end

    -- radio anim
    ply.RadioAnimWeight = ply:IsPlayingTaunt() and 0 or math.Approach(
        ply.RadioAnimWeight or 0,
        ply:GetNW2Bool('UsingRadio') and 1 or 0,
        FrameTime() * 5
    )

	if ply.RadioAnimWeight > 0 then
		ply:AnimRestartGesture( GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true )
		ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, ply.RadioAnimWeight )
	end
end)

hook.Add('PlayerButtonDown', 'lrp-radio.key', function(ply, key)
	local bind = GetConVar('cl_lrp_radio_key'):GetInt() or KEY_H
    local wep = ply:GetActiveWeapon()

	if bind == key then
		if not ply:HasWeapon('lrp_radio') or (not GetConVar('cl_lrp_radio'):GetBool()
        or (ply:GetMoveType() ~= MOVETYPE_WALK and not IsValid(ply:GetVehicle())))
        or (IsValid(wep) and wep.Base == 'localrp_gun_base' and (wep:GetReady() or wep:GetReloading())) then return end

		if not usingRadio and CurTime() - lastButtonDown > radioCooldown then
			usingRadio = true
            radioToggle(ply, usingRadio)

            lastButtonDown = CurTime()
		end
	end
end)

hook.Add('PlayerButtonUp', 'lrp-radio.key', function(ply, key)
	local bind = GetConVar('cl_lrp_radio_key'):GetInt() or KEY_H

	if bind == key and usingRadio and CurTime() - lastButtonUp > radioCooldown then
        usingRadio = false
        radioToggle(ply, usingRadio)

        lastButtonDown = CurTime()
        lastButtonUp = CurTime()
	end
end)