hook.Add( "KeyPress", 'lrp-push', function( ply, key )
    if key ~= IN_USE or ply.push then return end

    local ent = ply:GetEyeTrace().Entity
    if not ply:IsValid() or not ent:IsValid() then return end
    if not ply:IsPlayer() or not ent:IsPlayer() then return end
    if not ply:Alive() or not ent:Alive() or ent:GetMoveType() ~= MOVETYPE_WALK then return end

    if ply:GetPos():DistToSqr(ent:GetPos()) <= 70 * 70 then
        ply:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM , 228)

        if SERVER then
            ply:EmitSound( "physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 100, 100 )
        end

        ent:SetVelocity(ply:EyeAngles():Forward() * 400)
        ent:ViewPunch(Angle(math.random(-15, 15), math.random(-15, 15), 0))
        
        ply.push = true
        timer.Simple(3, function() ply.push = false end)
    end	
end)