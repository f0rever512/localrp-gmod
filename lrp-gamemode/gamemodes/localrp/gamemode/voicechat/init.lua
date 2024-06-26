if SERVER then
    util.AddNetworkString("ChatCommands")

    function sendMessageCustom(pl, ...)
        args = {...}
        net.Start("ChatCommands")
        net.WriteTable(args)
        net.Send(pl)
    end

    local function processChat(pl, str, team)
        local args = string.Split(str, " ")
        local commandname = args[1]:sub(2, #str)
        commandname = string.lower(commandname)
        if not commands[commandname] then --[[ sendMessageCustom(pl, Color(255,10,10), "Invalid command")]] return false end

        table.remove(args,1)
        commands[commandname].cb(pl, args)
        return true
    end


    hook.Add("PlayerSay", "customChatCommandsRun", function(pl, str, team)
        if string.StartWith(str, "/") then
            found = processChat(pl, str, team)
            if found then
                return ""
            end
        end
    end)

    hook.Add( "PlayerCanHearPlayersVoice", "voicedist", function( listener, talker )
        if listener:GetPos():DistToSqr( talker:GetPos() ) > 160000 then
    		return false
    	end
    end )

    hook.Add("PlayerCanSeePlayersChat", "chatdist", function(text, teamOnly, listener, speaker)
    	if listener:GetPos():DistToSqr( speaker:GetPos() ) > 160000 then
    		return false
    	end
    end)
end