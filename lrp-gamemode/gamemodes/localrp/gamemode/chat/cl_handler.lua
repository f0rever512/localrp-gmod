local lrp = localrp

local function translateMsg(msg)

    for i, msgPart in ipairs(msg) do
        if isstring(msgPart) and msgPart:StartsWith('lrp_gm.chat.') then
            msg[i] = lrp.lang and lrp.lang(msgPart) or msgPart
        end
    end

    return msg

end

net.Receive('lrp-chat.sendMsg', function()

    local msg = translateMsg(net.ReadTable())

    chat.AddText(unpack(msg))

end)