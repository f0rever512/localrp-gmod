net.Receive('lrpScoreboard.admin.messageMenu', function()
    local admin = net.ReadEntity()
    local target = net.ReadEntity()

    ToggleScoreboard(false)
    Derma_StringRequest(
        language.GetPhrase('lrp_sb.input.message_title'), 
        string.format(language.GetPhrase('lrp_sb.input.message_subtitle'), target:Nick()),
        '',
        function(text)
            if text == '' or not target:IsValid() then return end
            net.Start('lrpScoreboard.admin.messageSend')
            net.WriteString(text)
            net.WriteEntity(target)
            net.WriteEntity(admin)
            net.SendToServer()
        end
    )
end)

net.Receive('lrpScoreboard.admin.messageSend', function()
    local message = net.ReadString()
    local admin = net.ReadEntity()

    notification.AddLegacy(string.format(language.GetPhrase('lrp_sb.input.message_from'), admin:Nick(), message), NOTIFY_GENERIC, 6)
    surface.PlaySound('buttons/lightswitch2.wav')
end)

local hintClr = Color(100, 220, 10)
local prefix = '[LRP - Admin] '
net.Receive('lrpScoreboard.admin.hints', function()
    local hint = net.ReadUInt(3)
    local option = net.ReadString()

    if hint == lrpAdminHints.USAGE then
        chat.AddText(hintClr, prefix .. language.GetPhrase('lrp_sb.hints.usage'))
    elseif hint == lrpAdminHints.USAGE_ARGS then
        chat.AddText(hintClr, prefix .. string.format(language.GetPhrase('lrp_sb.hints.usage_args'), option))
    elseif hint == lrpAdminHints.AVAILABLE_COMMANDS then
        chat.AddText(hintClr, prefix .. language.GetPhrase('lrp_sb.hints.available_commands') .. option)
    elseif hint == lrpAdminHints.PARAMETER then
        chat.AddText(hintClr, prefix .. language.GetPhrase('lrp_sb.hints.parameter'))
    elseif hint == lrpAdminHints.PLAYER_NOT_FOUND then
        chat.AddText(hintClr, prefix .. language.GetPhrase('lrp_sb.hints.player_not_found'))
    elseif hint == lrpAdminHints.SELF_BLOCK then
        chat.AddText(hintClr, prefix .. language.GetPhrase('lrp_sb.hints.self_block'))
    end
end)