function GM:CreateMove(cmd)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if ply:InVehicle() or ply:GetMoveType() == MOVETYPE_NOCLIP then
        if wep.LRPGuns then
            cmd:RemoveKey(IN_ATTACK2)
        end
        return
    end

    if ((ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)) and not ply:KeyDown(IN_FORWARD)) or ply:KeyDown(IN_BACK) then
        cmd:RemoveKey(IN_SPEED)
    end
end

function GM:HUDAmmoPickedUp(itemName, amount)
    return false
end

function GM:HUDItemPickedUp(itemName)
    return false
end

function GM:HUDWeaponPickedUp(weapon)
    return false
end

hook.Add('DrawPhysgunBeam', 'lrp-physgunclr', function(ply, wep, enabled, target, bone, deltaPos)
    if enabled then
        ply:SetWeaponColor(ply:IsAdmin() and Vector(1, 0, 0) or Vector(1, 1, 1))
    else
        ply:SetWeaponColor(Vector(0, 0, 0))
    end
end)
