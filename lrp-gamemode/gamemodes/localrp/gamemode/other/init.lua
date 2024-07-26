function GM:AllowPlayerPickup(ply, ent)
    return false
end

function GM:PlayerNoClip(ply, desiredState)
    return desiredState == false or ply:IsAdmin()
end

hook.Add("PlayerDeathSound", 'lrp-deathsound', function(ply)
    local gender = string.find(ply:GetModel(), 'female') and 'female01' or 'male01'
    ply:EmitSound('vo/coast/odessa/' .. gender .. '/nlo_cubdeath0' .. math.random(1, 2) .. '.wav', SNDLVL_NORM)
    return true
end)

hook.Add("PlayerCanPickupWeapon", 'lrp-weaponpickup', function(ply, weapon)
    return not ply:HasWeapon(weapon:GetClass())
end)
