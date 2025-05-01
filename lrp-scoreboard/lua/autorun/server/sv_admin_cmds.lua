include('sv_cmd_list.lua')
AddCSLuaFile('sv_cmd_list.lua')

resource.AddFile('resource/localization/en/lrp_scoreboard.properties')
resource.AddFile('resource/localization/ru/lrp_scoreboard.properties')

local function RunConCommand(ply, cmd, args)
    if not (IsValid(ply) and ply:IsAdmin()) then return end

    local command = args[1]
    local targetName = args[2]
    local amount = args[3]

    if not command or not targetName then
        ply:ChatPrint('[LRP - Admin] Использование: lrp_admin <команда> <ник/SteamID>')
        return
    end

    local cmdData = lrpConCommands[command]
    if not cmdData then
        local availableCommands = {}
        for cmdName, _ in SortedPairs(lrpConCommands) do
            table.insert(availableCommands, cmdName)
        end
        
        ply:ChatPrint('[LRP - Admin] Доступные команды: ' .. table.concat(availableCommands, '; '))
        return
    end

    if cmdData.withArgs then
        -- проверка на наличие 3 аргумента
        if not amount then
            ply:ChatPrint('[LRP - Admin] Использование: lrp_admin ' .. command .. ' <ник/SteamID> <параметр>')
            return
        end

        if not tonumber(amount) then
            ply:ChatPrint('[LRP - Admin] Параметр должен быть числом')
            return
        end
    end

    local target
    for _, v in ipairs(player.GetAll()) do
        if string.find(string.lower(v:Nick()), string.lower(targetName), 1, true)
            or string.lower(v:SteamID()) == string.lower(targetName) then
            target = v
        end
    end

    if not IsValid(target) then
        ply:ChatPrint('[LRP - Admin] Игрок не найден')
        return
    end

    if cmdData.selfBlock and target == ply then
        ply:ChatPrint('[LRP - Admin] Вы не можете использовать эту команду на себе')
        return
    end

    MsgC(Color(100, 220, 100), string.format('[LRP - Admin] %s %s %s\n',
        ply:Nick(),
        amount and string.format(cmdData.desc, amount) or cmdData.desc,
        target:Nick()
    ))

    cmdData.action(ply, target, amount)
end

local function AutoComplete(cmd, args)
    local autoCompletes = {}

    local splitArgs = string.Split(args:Trim(), " ")
    local numArgs = #splitArgs

    if numArgs == 1 then
        local partCmdName = string.lower(splitArgs[1])
        for cmdName, _ in pairs(lrpConCommands) do
            if string.find(string.lower(cmdName), partCmdName, 1) then
                table.insert(autoCompletes, string.format('%s %s', cmd, cmdName))
            end
        end
    elseif numArgs == 2 then
        local partName = string.lower(splitArgs[2])
        for _, ply in ipairs(player.GetAll()) do
            if string.find(string.lower(ply:Nick()), partName, 1) then
                table.insert(autoCompletes, string.format('%s %s "%s"', cmd, splitArgs[1], ply:Nick()))
            end
        end
    end

    return autoCompletes
end

concommand.Add('lrp_admin', RunConCommand, AutoComplete)