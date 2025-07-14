local meta = FindMetaTable('Player')

function meta:GetRagdoll() -- Находиться ли игрок в рэгдолле
    return IsValid(self:GetNW2Entity('playerRagdollEntity'))
end

hook.Add("PlayerSwitchWeapon", 'lrp-ragdoll.switchBlock', function(ply)
    if ply:GetRagdoll() then return true end
end)