function GM:AllowPlayerPickup(ply, ent)
    return false
end

-- function GM:PhysgunPickup(ply, ent)
--     if ply:IsAdmin() and ent:IsPlayer() then
--         return true
--     end
--     return true
-- end

function GM:PlayerNoClip(ply, desiredState)
	if desiredState == false then
        return true
    elseif ply:IsAdmin() then
        return true
    end
end

hook.Add("PlayerDeathSound", 'lrp-deathsound', function(ply)
    if string.find(ply:GetModel(), 'female') then
        ply:EmitSound('vo/coast/odessa/female01/nlo_cubdeath0' .. math.random(1, 2) .. '.wav', SNDLVL_NORM)
    else
        ply:EmitSound('vo/coast/odessa/male01/nlo_cubdeath0' .. math.random(1, 2) .. '.wav', SNDLVL_NORM)
    end
    return true
end)

hook.Add("PlayerCanPickupWeapon", 'lrp-weaponpickup', function(ply, weapon)
    if (ply:HasWeapon(weapon:GetClass())) then
		return false
	end
end)