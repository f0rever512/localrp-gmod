commands = {}

function createCommand(name, func)
    commands[name] = {
        cb = func,
        aliases = {name}
    }
    return commands[name]
end

createCommand("roll", function(pl, args)
    local roll = math.random(1, 100)
    local message = pl:Nick() .. " has rolled a " .. roll
    local color = team.GetColor(pl:Team())
    for _, target in pairs(player.GetAll()) do
        if target:GetPos():Distance(pl:GetPos()) <= 400 then
            sendMessageCustom(target, color, pl:Nick(), color_white, " получил шанс: ", Color(255,100,100), tostring(roll))
        end
    end
end)

createCommand("me",function(pl, args)
    local message = table.concat(args, " ")
    local color = team.GetColor(pl:Team())
    for _, target in pairs(player.GetAll()) do
        if target:GetPos():Distance(pl:GetPos()) <= 400 then
            sendMessageCustom(target, color, pl:Nick(), color_white, " " ..  message)
        end
    end   
end)

createCommand("it",function(pl, args)
    local message = table.concat(args, " ")
    local color = team.GetColor(pl:Team())
    for _, target in pairs(player.GetAll()) do
        if target:GetPos():Distance(pl:GetPos()) <= 400 then
            sendMessageCustom(target, color_white, message .. " ", color_white, "(", color, pl:Nick(), color_white, ")")
        end
    end   
end)

createCommand("git",function(pl, args)
    local message = table.concat(args, " ")
    for _, target in pairs(player.GetAll()) do
        if true then
            sendMessageCustom(target, color_white, message .. " ", "(Глобальный it от ", pl:Nick(), ")")
        end
    end   
end)

createCommand("w", function(pl, args)
    local message = table.concat(args, " ")
    local color = team.GetColor(pl:Team())
    for _, target in pairs(player.GetAll()) do
        if target:GetPos():Distance(pl:GetPos()) <= 60 then
            sendMessageCustom(target, color, pl:Nick(), " прошептал:", color_white, " " ..  message)
        end
    end   
end)

createCommand("y", function(pl, args)
    local message = table.concat(args, " ")
    local color = team.GetColor(pl:Team())
    for _, target in pairs(player.GetAll()) do
        if target:GetPos():Distance(pl:GetPos()) <= 800 then
            sendMessageCustom(target, color, pl:Nick(), " крикнул:", color_white, " " ..  message, "!")
        end
    end   
end)

createCommand("looc",function(pl, args)
    local message = table.concat(args, " ")
    local color = team.GetColor(pl:Team())
    for _, target in pairs(player.GetAll()) do
        if target:GetPos():Distance(pl:GetPos()) <= 400 then
            sendMessageCustom(target, Color(255, 200, 40),  "(LOOC) " .. pl:Nick() .. ": " .. message ) --100, 150, 255
        end
    end
end)

createCommand("ooc", function(pl, args)
    local message = table.concat(args, " ")
    for _, target in pairs(player.GetAll()) do
        if true then
            sendMessageCustom(target, Color(255, 200, 40),  "(OOC) " .. pl:Nick() .. ": " .. message )
        end
    end
end)

createCommand('/', function(pl, args)
    local message = table.concat(args, " ")
    for _, target in pairs(player.GetAll()) do
        if true then
            sendMessageCustom(target, Color(255, 200, 40),  "(OOC) " .. pl:Nick() .. ": " .. message )
        end
    end
end)

createCommand("r", function(pl, args)
    local message = table.concat(args, " ")
    local color = team.GetColor(pl:Team())
    for _, target in pairs(player.GetAll()) do
        if true then
            sendMessageCustom(target, color, pl:Nick(), " сказал в рацию:", color_white, " " ..  message)
            target:EmitSound("npc/combine_soldier/vo/on2.wav", 75, 100, 1, CHAN_AUTO )
        end
    end
end)