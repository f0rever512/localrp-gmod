local ScW, ScH = ScrW(), ScrH()

local function removeHUDHooks()
    hook.Remove("HUDPaint", "RespawnTimer")
    hook.Remove("HUDPaint", "RespawnTimerEnd")
end

local function displayRespawnTimer(respTime)
    local deadTime = RealTime()
    hook.Add("HUDPaint", "RespawnTimer", function()
        local timeLeft = math.Round(respTime - RealTime() + deadTime)
        draw.SimpleTextOutlined("Возродиться можно через " .. timeLeft .. " секунд", 'lrp-deathfont', ScW / 2, ScH * 0.975, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    end)

    timer.Create('AfterTimer', respTime, 1, function()
        hook.Add("HUDPaint", "RespawnTimerEnd", function()
            draw.SimpleTextOutlined("Нажмите любую клавишу для возрождения", 'lrp-deathfont', ScW / 2, ScH * 0.975, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
        end)
    end)

    timer.Create('TimerRemoveHudDeath', respTime, 1, removeHUDHooks)
end

net.Receive("RespawnTimer", function()
    local respTime = net.ReadInt(13)
    displayRespawnTimer(respTime)
end)

net.Receive('timerDestroy', function()
    timer.Remove('TimerRemoveHudDeath')
    timer.Remove('AfterTimer')
    removeHUDHooks()
end)