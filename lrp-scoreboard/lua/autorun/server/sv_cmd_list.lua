local function sendHint(ply, hintName)
    net.Start('lrpScoreboard.admin.hints')
    net.WriteUInt(hintName, 3)
    net.Send(ply)
end

lrpConCommands = lrpConCommands or {
    ['kick'] = {
        desc = 'kicked',
        action = function(admin, target)
            target:Kick('Kicked by ' .. admin:Nick())
        end
    },

    ['ban'] = {
        desc = 'banned for %d minutes',
        action = function(admin, target, amount)
            target:Ban(math.Clamp(tonumber(amount), 0, 1200), true)
        end,
        withArgs = true,
        selfBlock = true,
    },

    ['goto'] = {
        desc = 'teleported to',
        action = function(admin, target)
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
                sendHint(admin, lrpAdminHints.NO_FREE_SPACE)
                return
            end

            admin:ExitVehicle()
            admin:SetPos(target_pos)
            admin:SetEyeAngles(target:EyeAngles())
        end,
        selfBlock = true,
    },

    ['bring'] = {
        desc = 'teleported to himself',
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
                sendHint(admin, lrpAdminHints.NO_FREE_SPACE)
                return
            end

            target:ExitVehicle()
            target:SetPos(target_pos)
            target:SetEyeAngles((admin:GetPos() - target:GetPos()):Angle())
            target:SetVelocity(Vector(0, 0, 0))
        end,
        selfBlock = true,
    },

    ['freeze'] = {
        desc = 'froze',
        action = function(admin, target)
            target:Freeze(true)
        end
    },

    ['unfreeze'] = {
        desc = 'unfroze',
        action = function(admin, target)
            target:Freeze(false)
        end
    },

    ['ignite'] = {
        desc = 'ignited for %d seconds',
        action = function(admin, target, amount)
            if target:Alive() then
                target:Ignite(math.Clamp(tonumber(amount), 1, 60))
            else
                sendHint(admin, lrpAdminHints.DEAD_PLAYER)
            end
        end,
        withArgs = true,
    },

    ['unignite'] = {
        desc = 'extinguished',
        action = function(admin, target)
            if target:Alive() then target:Extinguish() end
        end
    },

    ['message'] = {
        desc = 'sent message',
        action = function(admin, target)
            net.Start('lrpScoreboard.admin.messageMenu')
            net.WriteEntity(admin)
            net.WriteEntity(target)
            net.Send(admin)
        end,
        selfBlock = true,
    },

    ['hp'] = {
        desc = 'set %d health',
        action = function(admin, target, amount)
            if target:Alive() then
                target:SetHealth(math.Clamp(tonumber(amount), 1, target:GetMaxHealth()))
            else
                sendHint(admin, lrpAdminHints.DEAD_PLAYER)
            end
        end,
        withArgs = true,
    },

    ['ar'] = {
        desc = 'set %d armor',
        action = function(admin, target, amount)
            if target:Alive() then
                target:SetArmor(math.Clamp(tonumber(amount), 1, target:GetMaxArmor()))
            else
                sendHint(admin, lrpAdminHints.DEAD_PLAYER)
            end
        end,
        withArgs = true,
    },

    ['kill'] = {
        desc = 'killed',
        action = function(admin, target)
            if target:Alive() then target:Kill() end
        end
    },

    ['killsilent'] = {
        desc = 'silently killed',
        action = function(admin, target)
            if target:Alive() then target:KillSilent() end
        end
    },

	['respawn'] = {
        desc = 'respawned',
        action = function(admin, target)
            target:Spawn()
        end
    },
}