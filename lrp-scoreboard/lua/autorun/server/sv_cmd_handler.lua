util.AddNetworkString('lrpScoreboard.admin.messageMenu')
util.AddNetworkString('lrpScoreboard.admin.messageSend')

net.Receive('lrpScoreboard.admin.messageSend', function()
    local message = net.ReadString()
    local target = net.ReadEntity()
    local admin = net.ReadEntity()
    
    net.Start('lrpScoreboard.admin.messageSend')
    net.WriteString(message)
    net.WriteEntity(admin)
    net.Send(target)
end)