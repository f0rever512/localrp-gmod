util.AddNetworkString("ChatCommands") -- В будущем будем инициализировать где-то в другом месте, например: sv(sh)_nets.lua

registeredCmds = registeredCmds or {}
local commands = registeredCmds

function sendMessageCustom(pl, ...)
    local args = {...}
    net.Start("ChatCommands")
    net.WriteTable(args)
    net.Send(pl)
end

local function processChat(pl, str)
    local args = string.Split(str, " ")
    local commandname = string.lower(args[1]:sub(2))
    if not commands[commandname] then return false end

    table.remove(args, 1)
    commands[commandname].cb(pl, args)
    return true
end

hook.Add("PlayerSay", "customChatCommandsRun", function(pl, str, team)
    if string.StartWith(str, "/") then
        local found = processChat(pl, str)
        if found then
            return ""
        end
    end
end)