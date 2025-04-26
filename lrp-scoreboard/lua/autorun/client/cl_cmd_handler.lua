net.Receive('lrpScoreboard.admin.messageMenu', function()
    local admin = net.ReadEntity()
    local target = net.ReadEntity()

    ToggleScoreboard(false)
    Derma_StringRequest(
        'Отправить сообщение', 
        'Введите текст, который будет отправлен игроку ' .. target:Nick(),
        '',
        function(text)
            if text == '' or not target:IsValid() then return end
            net.Start('lrpScoreboard.admin.messageSend')
            net.WriteString('Сообщение от ' .. admin:Nick() ..': ' .. text)
            net.WriteEntity(target)
            net.SendToServer()
        end
    )
end)

net.Receive('lrpScoreboard.admin.messageSend', function()
    local message = net.ReadString()
    notification.AddLegacy(message, NOTIFY_GENERIC, 6)
    surface.PlaySound('buttons/lightswitch2.wav')
end)