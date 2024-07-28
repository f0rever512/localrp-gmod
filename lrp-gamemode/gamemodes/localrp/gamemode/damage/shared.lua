local function handleMovementRestriction(ply, cmd, conditions)
    if not IsValid(ply) or not ply:Alive() then return end
    cmd:RemoveKey(IN_SPEED)
    cmd:RemoveKey(IN_JUMP)
    if conditions and not cmd:KeyDown(IN_DUCK) then
        cmd:SetButtons(cmd:GetButtons() + IN_DUCK)
    end
end

net.Receive('breakleg', function(len, ply)
    local duration = net.ReadInt(5)
    hook.Add('StartCommand', 'breakLegMove', function(ply, cmd)
        handleMovementRestriction(ply, cmd, false)
    end)
    timer.Create('breakLeg', duration, 1, function()
        hook.Remove('StartCommand', 'breakLegMove')
    end)
end)

net.Receive('bleeding', function(len, ply)
    local bleeding = net.ReadBool()
    if bleeding then
        hook.Add('StartCommand', 'bleeding', function(ply, cmd)
            handleMovementRestriction(ply, cmd, true)
        end)
    else
        hook.Remove('StartCommand', 'bleeding')
    end
end)
