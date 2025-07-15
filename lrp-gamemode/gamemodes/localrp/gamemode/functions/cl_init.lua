local lrp = localrp

function lrp.lang(key, ...)
    local text = language.GetPhrase(key)
    local args = {...}

    if #args > 0 then
        return text:format(unpack(args))
    else
        return text
    end
end

local jobs = {}

function lrp.getJobTable()
    return jobs
end

net.Receive('lrp-jobs.sendTable', function()
    jobs = net.ReadTable()

    for id, job in pairs(jobs) do
        team.SetUp(id, job.name, job.color)
    end

    hook.Run('lrp-jobs.init', jobs)
end)

net.Receive('lrp-gamemode.notify', function()
    local text = net.ReadString()
    local duration = net.ReadUInt(4)
    local type = net.ReadUInt(3)
    local sound = net.ReadString()

    notification.AddLegacy(text, type, duration)
    surface.PlaySound(sound)
end)