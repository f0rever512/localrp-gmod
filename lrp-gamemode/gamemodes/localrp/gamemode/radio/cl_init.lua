CreateClientConVar('cl_lrp_radio', '0', true, true, 'Enable / Disable walkie-talkie', 0, 1)
CreateClientConVar('cl_lrp_radio_key', KEY_G, true, false, 'Key to toggle walkie-talkie')

local usingRadio = false
local lastButtonDown, lastButtonUp = 0, 0
local radioCooldown = 0.3

local radioPos = Vector(1.3, 0.7, 1)
local radioAng = Angle(-140, -15, 100)

function GM:GrabEarAnimation(ply)

    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()

    ply.RadioAnimWeight = ply:IsPlayingTaunt() and 0 or math.Approach(
        ply.RadioAnimWeight or 0,
        ply:GetNW2Bool('UsingRadio') and 1 or 0,
        FrameTime() * 5
    )

	if ply.RadioAnimWeight > 0 then
		ply:AnimRestartGesture( GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true )
		ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, ply.RadioAnimWeight )
	end

    local weight = ply.RadioAnimWeight or 0

    if weight > 0 then
        if not IsValid(ply.RadioModel) and wep:GetClass() ~= 'lrp_radio' then
            local attID = ply:LookupAttachment('anim_attachment_LH')
            if attID <= 0 then return end

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
        if IsValid(ply.RadioModel) then
            ply.RadioModel:Remove()
            ply.RadioModel = nil
        end
    end

end

local function radioToggle(state)

    permissions.EnableVoiceChat(state)
    net.Start('lrp-radio.toggle')
        net.WriteBool(state)
    net.SendToServer()

end

hook.Add('Think', 'lrp-radio.logic', function()

    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if usingRadio and (not IsValid(ply) or not ply:Alive()
    or (IsValid(wep) and wep.Base == 'localrp_gun_base' and (wep:GetReady() or wep:GetReloading()))) then
        usingRadio = false
        radioToggle(usingRadio)
    end

end)

hook.Add('PlayerButtonDown', 'lrp-radio.key', function(ply, key)

	local bind = GetConVar('cl_lrp_radio_key'):GetInt() or KEY_G
    local wep = ply:GetActiveWeapon()

	if bind == key then
		if not ply:HasWeapon('lrp_radio') or (not GetConVar('cl_lrp_radio'):GetBool()
        or (ply:GetMoveType() ~= MOVETYPE_WALK and not IsValid(ply:GetVehicle())))
        or (IsValid(wep) and wep.Base == 'localrp_gun_base' and (wep:GetReady() or wep:GetReloading())) then return end

		if not usingRadio and CurTime() - lastButtonDown > radioCooldown then
			usingRadio = true
            radioToggle(usingRadio)

            lastButtonDown = CurTime()
		end
	end

end)

hook.Add('PlayerButtonUp', 'lrp-radio.key', function(ply, key)

	local bind = GetConVar('cl_lrp_radio_key'):GetInt() or KEY_G

	if bind == key and usingRadio and CurTime() - lastButtonUp > radioCooldown then
        usingRadio = false
        radioToggle(usingRadio)

        lastButtonDown = CurTime()
        lastButtonUp = CurTime()
	end
    
end)