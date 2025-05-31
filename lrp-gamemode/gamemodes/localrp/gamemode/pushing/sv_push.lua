local cfg = lrp_cfg

local dist = cfg.pushDist
local force = cfg.pushForce
local cooldown = cfg.pushCooldown

hook.Add('KeyPress', 'lrp-gamemode.push', function(ply, key)
    if key ~= IN_USE then return end
    if not ply:Alive() then return end

    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:GetAimVector() * dist,
        filter = ply
    })

    local target = tr.Entity
    if not IsValid(target) or not target:IsPlayer() or target == ply then return end
    if ply:GetPos():DistToSqr(target:GetPos()) > dist * dist then return end

    ply.NextPush = ply.NextPush or 0

    if ply.NextPush > CurTime() then return end
    ply.NextPush = CurTime() + cooldown

    local dir = (target:GetPos() - ply:GetPos()):GetNormalized()

    ply:PlayAnimation(ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND)
    
    target:ViewPunch( Angle( math.random(-15, 15), math.random(-15, 15), math.random(-4, 4) ) )
    target:EmitSound('physics/body/body_medium_impact_soft' .. math.random(1, 7) .. '.wav', 60)
    target:SetVelocity(dir * force + Vector(0, 0, 100))
end)