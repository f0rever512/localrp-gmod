function GM:AllowPlayerPickup(ply, ent)
    return false
end

function GM:PhysgunPickup(ply, ent)
    if ply:IsAdmin() and ent:IsPlayer() then
        return true
    end
    return true
end

function GM:PlayerNoClip(ply, desiredState)
	if desiredState == false then
        return true
    elseif ply:IsAdmin() then
        return true
    end
end

hook.Add( "PlayerCanPickupWeapon", 'lrp-weaponpickup', function(ply, weapon)
    if (ply:HasWeapon(weapon:GetClass())) then
		return false
	end
end )