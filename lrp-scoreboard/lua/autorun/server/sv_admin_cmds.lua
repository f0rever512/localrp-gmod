local adminCommands = {
    ['kickUser'] = {
        desc = "кикнул",
        action = function(admin, target)
            target:Kick("Kicked from the server")
        end
    },
    ["5m"] = {
        desc = "забанил на 5 минут",
        action = function(admin, target)
            target:Ban(5, true)
        end
    },
    ["15m"] = {
        desc = "забанил на 15 минут",
        action = function(admin, target)
            target:Ban(15, true)
        end
    },
    freeze = {
        desc = "заморозил",
        action = function(admin, target)
            target:Freeze(true)
        end
    },
    unfreeze = {
        desc = "разморозил",
        action = function(admin, target)
            target:Freeze(false)
        end
    },
    ["5sec"] = {
        desc = "поджег на 5 секунд",
        action = function(admin, target)
            if target:Alive() then target:Ignite(5) end
        end
    },
    ["10sec"] = {
        desc = "поджег на 10 секунд",
        action = function(admin, target)
            if target:Alive() then target:Ignite(10) end
        end
    },
    unignite = {
        desc = "потушил",
        action = function(admin, target)
            if target:Alive() then target:Extinguish() end
        end
    },
    ["5hp"] = {
        desc = "установил 5 здоровья",
        action = function(admin, target)
            if target:Alive() then target:SetHealth(5) end
        end
    },
    ["25hp"] = {
        desc = "установил 25 здоровья",
        action = function(admin, target)
            if target:Alive() then target:SetHealth(25) end
        end
    },
    ["50hp"] = {
        desc = "установил 50 здоровья",
        action = function(admin, target)
            if target:Alive() then target:SetHealth(50) end
        end
    },
    ["100hp"] = {
        desc = "установил 100 здоровья",
        action = function(admin, target)
            if target:Alive() then target:SetHealth(100) end
        end
    },
    ['kill'] = {
        desc = "убил",
        action = function(admin, target)
            if target:Alive() then target:Kill() end
        end
    },
    silkill = {
        desc = "тихо убил",
        action = function(admin, target)
            if target:Alive() then target:KillSilent() end
        end
    },
    ["0ar"] = {
        desc = "установил 0 брони",
        action = function(admin, target)
            if target:Alive() then target:SetArmor(0) end
        end
    },
    ["25ar"] = {
        desc = "установил 25 брони",
        action = function(admin, target)
            if target:Alive() then target:SetArmor(25) end
        end
    },
    ["50ar"] = {
        desc = "установил 50 брони",
        action = function(admin, target)
            if target:Alive() then target:SetArmor(50) end
        end
    },
    ["100ar"] = {
        desc = "установил 100 брони",
        action = function(admin, target)
            if target:Alive() then target:SetArmor(100) end
        end
    },
	resp = {
        desc = "возродил",
        action = function(admin, target)
            target:Spawn()
        end
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
        end
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
        end
    },
}

local function registerAdminCommand(commandName, commandData)
    util.AddNetworkString(commandName)
    
    net.Receive(commandName, function(_, admin)
        if not (admin:IsValid() and admin:IsAdmin()) then return end
        
        local target = net.ReadEntity()
        if not IsValid(target) or not target:IsPlayer() then return end

		MsgC(Color(100, 220, 100, 220), string.format("[LocalRP] %s %s %s\n",
			admin:GetName(),
			commandData.desc,
			target:GetName()))
        
		commandData.action(admin, target)
    end)
end

for commandName, commandData in pairs(adminCommands) do
    registerAdminCommand(commandName, commandData)
end