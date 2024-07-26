if CLIENT then
    net.Receive("ChatCommands", function()
        message = net.ReadTable()
        for _, arg in ipairs(message) do
            if type(arg) == "table" and arg.r then
                message[_] = Color(arg.r,arg.g, arg.b, 255)
            end
        end
        chat.AddText(unpack(message))
    end)
end