function GM:CreateMove(cmd)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if ply:InVehicle() then return end

    if ply:GetMoveType() ~= MOVETYPE_NOCLIP then
        if ((ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)) and not ply:KeyDown(IN_FORWARD)) or ply:KeyDown(IN_BACK) then
            if not wep.LRPGuns then
                cmd:RemoveKey(IN_SPEED)
            elseif wep.LRPGuns and wep.GetReady then
                cmd:RemoveKey(IN_SPEED)
            end
        end
    elseif wep.LRPGuns and ply:GetMoveType() == MOVETYPE_NOCLIP then
        cmd:RemoveKey(IN_ATTACK2)
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

hook.Add('DrawPhysgunBeam', 'lrp-physgunclr', function( ply, wep, enabled, target, bone, deltaPos )
    if enabled and not ply:IsAdmin() then
        ply:SetWeaponColor(Vector(1, 1, 1))
    elseif enabled and ply:IsAdmin() then
        ply:SetWeaponColor(Vector(1, 0, 0))
    else
        ply:SetWeaponColor(Vector(0, 0, 0))
    end
end)