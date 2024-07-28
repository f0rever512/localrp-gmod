net.Receive("ChatCommands", function()
    local message = net.ReadTable()
    for i, arg in ipairs(message) do
        if type(arg) == "table" and arg.r then
            message[i] = Color(arg.r, arg.g, arg.b, 255)
        end
    end
    chat.AddText(unpack(message))
end)