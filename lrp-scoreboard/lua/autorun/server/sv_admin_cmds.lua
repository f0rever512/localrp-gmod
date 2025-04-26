util.AddNetworkString('lrpScoreboard.admin.messageMenu')
util.AddNetworkString('lrpScoreboard.admin.messageSend')

local cmdList = {
    ['kick'] = {
        desc = 'кикнул',
        action = function(admin, target)
            target:Kick('Кикнут ' .. admin:Nick())
        end
    },

    ['ban'] = {
        desc = 'забанил на %d минут',
        action = function(admin, target, amount)
            target:Ban(math.Clamp(tonumber(amount), 0, 1200), true)
        end,
        withArgs = true,
        selfBlock = true,
    },

    ['goto'] = {
        desc = "телепортировался к",
        action = function(admin, target)
            if not admin:InVehicle() then
                local offset = Vector(0, 0, 80)
                local target_pos = target:GetPos() + offset
                admin:SetPos(target_pos)
                admin:SetEyeAngles(target:EyeAngles())
            end
        end,
        selfBlock = true,
    },

    ['bring'] = {
        desc = 'телепортировал к себе',
        action = function(admin, target)
            local maxDistance = 200
			local trace = admin:GetEyeTrace()
	
			if trace.Hit then
				local distance = admin:GetPos():DistToSqr(trace.HitPos)
				local teleportPos = trace.HitPos
	
				if distance > maxDistance * maxDistance then
					local direction = (trace.HitPos - admin:GetPos()):GetNormalized()
					teleportPos = admin:GetPos() + direction * maxDistance
				end
	
				target:SetPos(teleportPos)
				target:SetVelocity(Vector(0, 0, 0))
			end
        end,
        selfBlock = true,
    },

    ['freeze'] = {
        desc = "заморозил",
        action = function(admin, target)
            target:Freeze(true)
        end
    },

    ['unfreeze'] = {
        desc = "разморозил",
        action = function(admin, target)
            target:Freeze(false)
        end
    },

    ['ignite'] = {
        desc = 'поджег на %d секунд',
        action = function(admin, target, amount)
            if target:Alive() then
                target:Ignite(math.Clamp(tonumber(amount), 1, 60))
            else
                admin:ChatPrint('[LRP - Admin] Выполнить эту команду на мертвом игроке нельзя')
            end
        end,
        withArgs = true,
    },

    ['unignite'] = {
        desc = "потушил",
        action = function(admin, target)
            if target:Alive() then target:Extinguish() end
        end
    },

    ['message'] = {
        desc = 'отправил сообщение',
        action = function(admin, target)
            net.Start('lrpScoreboard.admin.messageMenu')
            net.WriteEntity(admin)
            net.WriteEntity(target)
            net.Send(admin)
        end,
        selfBlock = true,
    },

    ['hp'] = {
        desc = 'установил %d здоровья',
        action = function(admin, target, amount)
            if target:Alive() then
                target:SetHealth(math.Clamp(tonumber(amount), 1, target:GetMaxHealth()))
            else
                admin:ChatPrint('[LRP - Admin] Выполнить эту команду на мертвом игроке нельзя')
            end
        end,
        withArgs = true,
    },

    ['ar'] = {
        desc = 'установил %d брони',
        action = function(admin, target, amount)
            if target:Alive() then
                target:SetArmor(math.Clamp(tonumber(amount), 1, target:GetMaxArmor()))
            else
                admin:ChatPrint('[LRP - Admin] Выполнить эту команду на мертвом игроке нельзя')
            end
        end,
        withArgs = true,
    },

    ['kill'] = {
        desc = "убил",
        action = function(admin, target)
            if target:Alive() then target:Kill() end
        end
    },

    ['killsilent'] = {
        desc = "тихо убил",
        action = function(admin, target)
            if target:Alive() then target:KillSilent() end
        end
    },

	['respawn'] = {
        desc = "возродил",
        action = function(admin, target)
            target:Spawn()
        end
    },
}

net.Receive('lrpScoreboard.admin.messageSend', function()
    local message = net.ReadString()
    local target = net.ReadEntity()
    net.Start('lrpScoreboard.admin.messageSend')
    net.WriteString(message)
    net.Send(target)
end)

local function registerAdminCommand(commandName, commandData)
    util.AddNetworkString(commandName)
    
    net.Receive(commandName, function(_, admin)
        if not (admin:IsValid() and admin:IsAdmin()) then return end
        
        local target = net.ReadEntity()
        if not IsValid(target) or not target:IsPlayer() then return end

		MsgC(Color(100, 220, 100), string.format("[LocalRP] %s %s %s\n",
			admin:GetName(),
			commandData.desc,
			target:GetName()))
        
		commandData.action(admin, target)
    end)
end

for commandName, commandData in pairs(cmdList) do
    registerAdminCommand(commandName, commandData)
end

local function RunConCommand(ply, cmd, args)
    if not (IsValid(ply) and ply:IsAdmin()) then return end

    local command = args[1]
    local targetName = args[2]
    local amount = args[3]

    if not command or not targetName then
        ply:ChatPrint('[LRP - Admin] Использование: lrp_admin <команда> <ник/SteamID>')
        return
    end

    local cmdData = cmdList[command]
    if not cmdData then
        local availableCommands = {}
        for cmdName, _ in SortedPairs(cmdList) do
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
        for cmdName, _ in pairs(cmdList) do
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