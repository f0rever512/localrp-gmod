registeredCmds = registeredCmds or {}
local commands = registeredCmds

function createCommand(name, func)
    commands[name] = {
        cb = func,
        aliases = {name}
    }
    return commands[name]
end

local function sendMessageToNearbyPlayers(pl, messageParts, distance)
    local plPos = pl:GetPos()
    for _, target in pairs(player.GetAll()) do
        if target:GetPos():Distance(plPos) <= distance then
            sendMessageCustom(target, unpack(messageParts))
        end
    end
end

createCommand('dropweapon', function(pl, args)
    pl:DropWeaponAnim()
end)

createCommand("roll", function(pl, args)
    local roll = math.random(1, 100)
    local color = team.GetColor(pl:Team())
    local messageParts = {color, pl:Nick(), color_white, " получил шанс: ", Color(255, 100, 100), tostring(roll)}
    sendMessageToNearbyPlayers(pl, messageParts, 400)
end)

createCommand("me", function(pl, args)
    local message = table.concat(args, " ")
    local color = team.GetColor(pl:Team())
    local messageParts = {color, pl:Nick(), color_white, " " .. message}
    sendMessageToNearbyPlayers(pl, messageParts, 400)
end)

createCommand("it", function(pl, args)
    local message = table.concat(args, " ")
    local color = team.GetColor(pl:Team())
    local messageParts = {color_white, message .. " ", color_white, "(", color, pl:Nick(), color_white, ")"}
    sendMessageToNearbyPlayers(pl, messageParts, 400)
end)

createCommand("git", function(pl, args)
    local message = table.concat(args, " ")
    local messageParts = {color_white, message .. " ", "(Глобальный it от ", pl:Nick(), ")"}
    for _, target in pairs(player.GetAll()) do
        sendMessageCustom(target, unpack(messageParts))
    end
end)

createCommand("w", function(pl, args)
    local message = table.concat(args, " ")
    local color = team.GetColor(pl:Team())
    local messageParts = {color, pl:Nick(), " прошептал:", color_white, " " .. message}
    sendMessageToNearbyPlayers(pl, messageParts, 60)
end)

createCommand("y", function(pl, args)
    local message = table.concat(args, " ")
    local color = team.GetColor(pl:Team())
    local messageParts = {color, pl:Nick(), " крикнул:", color_white, " " .. message, "!"}
    sendMessageToNearbyPlayers(pl, messageParts, 800)
end)

createCommand("looc", function(pl, args)
    local message = table.concat(args, " ")
    local messageParts = {Color(255, 200, 40), "(LOOC) " .. pl:Nick() .. ": " .. message}
    sendMessageToNearbyPlayers(pl, messageParts, 400)
end)

createCommand("ooc", function(pl, args)
    local message = table.concat(args, " ")
    local messageParts = {Color(255, 200, 40), "(OOC) " .. pl:Nick() .. ": " .. message}
    for _, target in pairs(player.GetAll()) do
        sendMessageCustom(target, unpack(messageParts))
    end
end)

createCommand('/', function(pl, args)
    local message = table.concat(args, " ")
    local messageParts = {Color(255, 200, 40), "(OOC) " .. pl:Nick() .. ": " .. message}
    for _, target in pairs(player.GetAll()) do
        sendMessageCustom(target, unpack(messageParts))
    end
end)

createCommand("r", function(pl, args)
    local message = table.concat(args, " ")
    local color = team.GetColor(pl:Team())
    local messageParts = {color, pl:Nick(), " сказал в рацию:", color_white, " " .. message}
    for _, target in pairs(player.GetAll()) do
        sendMessageCustom(target, unpack(messageParts))
        target:EmitSound("npc/combine_soldier/vo/on2.wav", 75, 100, 1, CHAN_AUTO)
    end
end)
