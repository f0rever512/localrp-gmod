net.Receive('breakleg', function( len, ply )
    local duration = net.ReadInt( 5 )
    hook.Add('StartCommand', 'breakLegMove', function(ply, cmd)
        if IsValid(ply) and ply:Alive() then
            if not ply:InVehicle() then
                cmd:RemoveKey(IN_SPEED)
                cmd:RemoveKey(IN_JUMP)
            end
        else
            return
        end
    end)
    timer.Create('breakLeg', duration, 1, function()
        hook.Remove('StartCommand', 'breakLegMove')
    end)
end)

net.Receive('bleeding', function( len, ply )
    local bleeding = net.ReadBool()
    hook.Add('StartCommand', 'bleeding', function(ply, cmd)
        if IsValid(ply) and ply:Alive() then
            cmd:RemoveKey(IN_SPEED)
            cmd:RemoveKey(IN_JUMP)
            if not cmd:KeyDown(IN_DUCK) then
                cmd:SetButtons(cmd:GetButtons() + IN_DUCK)
            end
        else
            return
        end
    end)
    if not bleeding then
        hook.Remove('StartCommand', 'bleeding')
    end
end)