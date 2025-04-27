lrpConCommands = lrpConCommands or {
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
        desc = 'телепортировался к',
        action = function(admin, target)
            if not admin:InVehicle() then
                local offset = target:GetForward() * 60
                local target_pos = target:GetPos() - offset

                local hullTrace = util.TraceHull({
                    start = target_pos,
                    endpos = target_pos,
                    mins = Vector(-16, -16, 0),
                    maxs = Vector(16, 16, 72),
                    filter = {admin, target}
                })

                if admin:GetMoveType() ~= MOVETYPE_NOCLIP and (hullTrace.Hit or not util.IsInWorld(target_pos)) then
                    admin:ChatPrint('[LRP - Admin] Нет свободного места для телепортации')
                    return
                end

                admin:SetPos(target_pos)
                admin:SetEyeAngles(target:EyeAngles())
            else
                admin:ChatPrint('[LRP - Admin] Телепортироваться, находясь в транспорте нельзя')
            end
        end,
        selfBlock = true,
    },

    ['bring'] = {
        desc = 'телепортировал к себе',
        action = function(admin, target)
            local offset = admin:GetForward() * 80
            local target_pos = admin:GetPos() + offset

            local hullTrace = util.TraceHull({
                start = target_pos,
                endpos = target_pos,
                mins = Vector(-16, -16, 0),
                maxs = Vector(16, 16, 72),
                filter = {admin, target}
            })

            if hullTrace.Hit or not util.IsInWorld(target_pos) then
                admin:ChatPrint('[LRP - Admin] Нет свободного места для телепортации')
                return
            end

            target:SetPos(target_pos)
            target:SetEyeAngles((admin:GetPos() - target:GetPos()):Angle())
            target:SetVelocity(Vector(0, 0, 0))
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