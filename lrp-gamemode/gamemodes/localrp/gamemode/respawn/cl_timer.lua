local lrp = localrp

local posX, posY = ScrW() / 2, ScrH() - 30

local function displayRespawnTimer(respTime)
    local deadTime = RealTime()
    hook.Add("HUDPaint", 'lrp-respawn.timer', function()
        local timeLeft = math.Round(respTime - RealTime() + deadTime)
        draw.SimpleTextOutlined(lrp.lang('lrp_gm.respawn_time', timeLeft), 'lrp-deathfont', posX, posY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    end)

    timer.Create('AfterTimer', respTime, 1, function()
        hook.Add("HUDPaint", 'lrp-respawn.timerEnd', function()
            draw.SimpleTextOutlined(lrp.lang('lrp_gm.respawn_time_end'), 'lrp-deathfont', posX, posY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
        end)
    end)

    timer.Create('TimerRemoveHudDeath', respTime, 1, function ()
        hook.Remove("HUDPaint", 'lrp-respawn.timer')
    end)
end

net.Receive('lrp-respawn.timer', function()
    local respTime = net.ReadInt(13)
    displayRespawnTimer(respTime)
end)

net.Receive('lrp-respawn.timerDestroy', function()
    timer.Remove('TimerRemoveHudDeath')
    timer.Remove('AfterTimer')
    hook.Remove("HUDPaint", 'lrp-respawn.timer')
    hook.Remove("HUDPaint", 'lrp-respawn.timerEnd')
end)