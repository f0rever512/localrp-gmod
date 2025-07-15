function GM:StartCommand(ply, cmd)
    if not ply:Alive() then return end

    local wep = ply:GetActiveWeapon()

    if ply:InVehicle() or ply:GetMoveType() == MOVETYPE_NOCLIP then
        if IsValid(wep) and wep.Base == 'localrp_gun_base' then
            cmd:RemoveKey(IN_ATTACK2)
        end

        return
    end

    if ( (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)) and not ply:KeyDown(IN_FORWARD) ) or ply:KeyDown(IN_BACK) then
        cmd:RemoveKey(IN_SPEED)
    end
end