util.AddNetworkString('lrp-chat.sendMsg')

local cfg = lrp_cfg

local function sendMessage(ply, msg, dist)

    if not IsValid(ply) then return end

    local plyPos = ply:GetPos()

    for _, target in pairs(player.GetAll()) do
        -- dont write distance to send msg to everyone
        if dist and target:GetPos():DistToSqr(plyPos) > dist * dist then continue end

        net.Start('lrp-chat.sendMsg')
        net.WriteTable(msg)
        net.Send(target)
    end

end

local chatColor = cfg.chatColor

cfg.chatCmds = cfg.chatCmds or {

    ['me'] = {
        func = function(ply, args)
            local msg = table.concat(args, ' ')
            local spaces = select(2, msg:gsub(' ', ''))
            if #msg == spaces then return end

            local fullMsg = {chatColor.ic, ply:Nick(), ' ', msg}
            sendMessage(ply, fullMsg, 400)
        end,
    },

    ['it'] = {
        func = function(ply, args)
            local msg = table.concat(args, ' ')
            local spaces = select(2, msg:gsub(' ', ''))
            if #msg == spaces then return end

            local fullMsg = {chatColor.ic, msg, ' (', ply:Nick(), ')'}
            sendMessage(ply, fullMsg, 400)
        end,
        allowDead = true,
    },

    ['roll'] = {
        func = function(ply)
            local roll = math.random(1, 100)
            local color = roll >= 50 and Color(100, 255, 150) or Color(255, 100, 100)
            local msg = {
                chatColor.ic, ply:Nick(),
                ply:IsMale() and 'lrp_gm.chat.roll_male' or 'lrp_gm.chat.roll_female',
                color, tostring(roll)
            }
            
            sendMessage(ply, msg, 400)
        end,
    },

    ['/it'] = {
        func = function(ply, args)
            local msg = table.concat(args, ' ')
            local spaces = select(2, msg:gsub(' ', ''))
            if #msg == spaces then return end

            local fullMsg = {chatColor.ic, msg .. ' ', 'lrp_gm.chat.global_it', ply:Nick(), ')'}
            sendMessage(ply, fullMsg)
        end,
    },

    ['w'] = {
        func = function(ply, args)
            local msg = table.concat(args, ' ')
            local spaces = select(2, msg:gsub(' ', ''))
            if #msg == spaces then return end

            local fullMsg = {
                chatColor.ic, ply:Nick(),
                ply:IsMale() and 'lrp_gm.chat.whisper_male' or 'lrp_gm.chat.whisper_female',
                chatColor.main, msg
            }

            sendMessage(ply, fullMsg, 60)
        end,
    },

    ['y'] = {
        func = function(ply, args)
            local msg = table.concat(args, ' ')
            local spaces = select(2, msg:gsub(' ', ''))
            if #msg == spaces then return end

            local fullMsg = {
                chatColor.ic, ply:Nick(),
                ply:IsMale() and 'lrp_gm.chat.yell_male' or 'lrp_gm.chat.yell_female',
                chatColor.main, msg, '!'
            }

            sendMessage(ply, fullMsg, 800)
        end,
    },

    ['looc'] = {
        func = function(ply, args)
            local msg = table.concat(args, ' ')
            local spaces = select(2, msg:gsub(' ', ''))
            if #msg == spaces then return end

            local fullMsg = {chatColor.ooc, '(LOOC) ', ply:Nick(), ': ', chatColor.main, msg}
            sendMessage(ply, fullMsg, 400)
        end,
        allowDead = true,
    },

    ['ooc'] = {
        func = function(ply, args)
            local msg = table.concat(args, ' ')
            local spaces = select(2, msg:gsub(' ', ''))
            if #msg == spaces then return end

            local fullMsg = {chatColor.ooc, '(OOC) ', ply:Nick(), ': ', chatColor.main, msg}
            sendMessage(ply, fullMsg)
        end,
        allowDead = true,
    },

    ['radio'] = {
        func = function(ply, args)
            local msg = table.concat(args, ' ')
            local spaces = select(2, msg:gsub(' ', ''))
            if #msg == spaces then return end

            local dist = 400

            local fullMsg = {
                chatColor.ic, ply:Nick(),
                ply:IsMale() and 'lrp_gm.chat.radio_male' or 'lrp_gm.chat.radio_female',
                chatColor.main, msg
            }

            local speakerIsGov = ply:GetJobTable().gov
            local plyPos = ply:GetPos()

            for _, target in pairs(player.GetAll()) do
                local inRadius = target:GetPos():DistToSqr(plyPos) <= dist * dist
                local targetIsGov = target:GetJobTable().gov

                if (inRadius and ply:GetInfoNum('cl_lrp_radio', 0) == 1) or (speakerIsGov and targetIsGov
                and ply:GetInfoNum('cl_lrp_radio', 0) == 1 and target:GetInfoNum('cl_lrp_radio', 0) == 1) then
                    target:EmitSound('npc/combine_soldier/vo/on2.wav', 55)
                    net.Start('lrp-chat.sendMsg')
                    net.WriteTable(fullMsg)
                    net.Send(target)
                end
            end
        end,
    },

    ['dropweapon'] = {
        func = function(ply)
            ply:DropWeaponAnim()
        end,
    },

    ['panicbutton'] = {
        func = function(ply)
            ply:ConCommand('lrp_panic_button')
        end,
    },

}