net.Receive('lrp-chat.sendMsg', function()

    local msg = net.ReadTable()

    chat.AddText(unpack(msg))

end)