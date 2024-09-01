playerMeta = FindMetaTable('Player')

function playerMeta:GetRagdoll() -- Находиться ли игрок в рэгдолле
    return IsValid(self:GetNW2Entity('playerRagdollEntity'))
end

hook.Add("PlayerSwitchWeapon", 'lrp-ragdoll.switchBlock', function(ply, _, _)
    if ply:GetRagdoll() then
        return true
    else
        return
    end
end)