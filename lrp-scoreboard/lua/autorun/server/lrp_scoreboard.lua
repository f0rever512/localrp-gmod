local ADMIN_COMMANDS = {
    kickuser = {
        description = "кикнул",
        action = function(admin, target)
            target:Kick("Kicked from the server")
        end
    },
    ["5m"] = {
        description = "забанил на 5 минут",
        action = function(admin, target)
            target:Ban(5, true)
        end
    },
    ["15m"] = {
        description = "забанил на 15 минут",
        action = function(admin, target)
            target:Ban(15, true)
        end
    },
    freeze = {
        description = "заморозил",
        action = function(admin, target)
            target:Freeze(true)
        end
    },
    unfreeze = {
        description = "разморозил",
        action = function(admin, target)
            target:Freeze(false)
        end
    },
    ["5sec"] = {
        description = "поджег на 5 секунд",
        action = function(admin, target)
            if target:Alive() then target:Ignite(5) end
        end
    },
    ["10sec"] = {
        description = "поджег на 10 секунд",
        action = function(admin, target)
            if target:Alive() then target:Ignite(10) end
        end
    },
    unignite = {
        description = "потушил",
        action = function(admin, target)
            if target:Alive() then target:Extinguish() end
        end
    },
    ["5hp"] = {
        description = "установил 5 здоровья",
        action = function(admin, target)
            if target:Alive() then target:SetHealth(5) end
        end
    },
    ["25hp"] = {
        description = "установил 25 здоровья",
        action = function(admin, target)
            if target:Alive() then target:SetHealth(25) end
        end
    },
    ["50hp"] = {
        description = "установил 50 здоровья",
        action = function(admin, target)
            if target:Alive() then target:SetHealth(50) end
        end
    },
    ["100hp"] = {
        description = "установил 100 здоровья",
        action = function(admin, target)
            if target:Alive() then target:SetHealth(100) end
        end
    },
    kill = {
        description = "убил",
        action = function(admin, target)
            if target:Alive() then target:Kill() end
        end
    },
    silkill = {
        description = "тихо убил",
        action = function(admin, target)
            if target:Alive() then target:KillSilent() end
        end
    },
    ["0ar"] = {
        description = "установил 0 брони",
        action = function(admin, target)
            if target:Alive() then target:SetArmor(0) end
        end
    },
    ["25ar"] = {
        description = "установил 25 брони",
        action = function(admin, target)
            if target:Alive() then target:SetArmor(25) end
        end
    },
    ["50ar"] = {
        description = "установил 50 брони",
        action = function(admin, target)
            if target:Alive() then target:SetArmor(50) end
        end
    },
    ["100ar"] = {
        description = "установил 100 брони",
        action = function(admin, target)
            if target:Alive() then target:SetArmor(100) end
        end
    },

    teleport_to = {
        description = "телепортировался к",
        action = function(admin, target)
            if not admin:InVehicle() then
                local offset = Vector(0, 0, 50)
                local target_pos = target:GetPos() + offset
                admin:SetPos(target_pos)
                admin:SetEyeAngles(target:EyeAngles())
            else
                admin:ChatPrint("Выйдите из транспорта для телепортации!")
            end
        end,
        icon = "icon16/arrow_merge.png"
    },

    teleport_to_point = {
        description = "телепортировал к точке",
        action = function(admin, target)
            local trace = admin:GetEyeTrace()
            if trace.Hit then
                local safe_pos = util.FindSafePosition(trace.HitPos, 
                    {target}, 500, 30, Vector(16, 16, 64))
                
                if safe_pos then
                    target:SetPos(safe_pos)
                    target:SetVelocity(Vector(0,0,0))
                end
            end
        end,
        icon = "icon16/map_go.png"
    },   
    resp = {
        description = "возродил",
        action = function(admin, target)
            target:Spawn()
        end
    }
}

local function isCommandAllowed(admin)
    return admin:IsAdmin() and admin:IsValid()
end

local function registerAdminCommand(commandName, commandData)
    util.AddNetworkString(commandName)
    
    net.Receive(commandName, function(len, admin)
        if not isCommandAllowed(admin) then return end
        
        local target = net.ReadEntity()
        if not IsValid(target) or not target:IsPlayer() then return end

        print(string.format("[ADMIN] %s %s %s", 
            admin:GetName(), 
            commandData.description, 
            target:GetName()))
        
        -- Выполнение действия с обработкой ошибок
        local success, err = pcall(function()
            commandData.action(admin, target)
        end)
        
        if not success then
            ErrorNoHalt("[TELEPORT ERROR] "..err.."\n")
            admin:ChatPrint("Ошибка телепортации: "..tostring(err))
        end
    end)
end

for commandName, commandData in pairs(ADMIN_COMMANDS) do
    registerAdminCommand(commandName, commandData)
end
