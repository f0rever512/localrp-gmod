local cfg = lrp_cfg

local commands = cfg.chatCmds
local chatColor = cfg.chatColor

local msg

function GM:PlayerSay( ply, text )

    local isPlayer = IsValid(ply)

    if text:StartsWith('/') and isPlayer then
        local args = string.Split(text, ' ')
        local cmdName = string.lower(args[1]:sub(2))

        local cmdTable = commands[cmdName]
        
        if not cmdTable then
            local availableCmds = {}

            for str, _ in pairs(commands) do
                table.insert(availableCmds, str)
            end

            ply:NotifySound('Available commands: ' .. table.concat(availableCmds, '; '), 6, NOTIFY_ERROR)

            return false
        end

        if not ply:Alive() and not cmdTable.allowDead then return false end

        table.remove(args, 1)
        -- run function
        cmdTable.func(ply, args)
    else
        if not ply:Alive() then return false end

        if isPlayer then
            msg = {chatColor.ic, ply:Nick(), ply:IsMale() and ' сказал: ' or ' сказала: ', chatColor.main, text}
        else
            msg = {chatColor.ooc, 'Console: ', chatColor.main, text}
        end

        local dist = cfg.chatDist

        local plyPos = ply:GetPos()

        for _, target in pairs(player.GetAll()) do
            if isPlayer and target:GetPos():DistToSqr(plyPos) > dist * dist then continue end

            net.Start('lrp-chat.sendMsg')
            net.WriteTable(msg)
            net.Send(target)
        end
    end

    return ''

end